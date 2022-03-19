import '../../rtpparameters.dart';

List<RtpEncodingParameters> getRtpEncodings({offerMediaObject} //:
    // { offerMediaObject: any }
    ) //: RtpEncodingParameters[]
{
  // const ssrcs = new Set();
  List<dynamic> ssrcs = [];

  for (var line in offerMediaObject.ssrcs /* || []*/) {
    var ssrc = line.id;

    ssrcs.add(ssrc);
  }

  if (ssrcs.length == 0) throw Exception('no a=ssrc lines found');

  var ssrcToRtxSsrc = Map();

  // First assume RTX is used.
  for (var line in offerMediaObject.ssrcGroups /*|| []*/) {
    if (line.semantics != 'FID') continue;

    // var [ ssrc, rtxSsrc ] = line.ssrcs.split(/\s+/);
    var arr = line.ssrcs.split(RegExp(r'\s+'));

    var ssrc = int.tryParse(arr[0]); //Number(ssrc);
    var rtxSsrc = int.tryParse(arr[1]); //Number(rtxSsrc);

    if (ssrcs.contains(ssrc)) {
      // Remove both the SSRC and RTX SSRC from the set so later we know that they
      // are already handled.
      ssrcs.remove(ssrc);
      ssrcs.remove(rtxSsrc);

      // Add to the map.
      // ssrcToRtxSsrc.set(ssrc, rtxSsrc);
      ssrcToRtxSsrc[ssrc] = rtxSsrc;
    }
  }

  // If the set of SSRCs is not empty it means that RTX is not being used, so take
  // media SSRCs from there.
  for (var ssrc in ssrcs) {
    // Add to the map.
    // ssrcToRtxSsrc.set(ssrc, null);
    ssrcToRtxSsrc[ssrc] = null;
  }

  List<RtpEncodingParameters> encodings = [];

  // for (var [ ssrc, rtxSsrc ] in ssrcToRtxSsrc)
  ssrcToRtxSsrc.forEach((ssrc, rtxSsrc) {
    RtpEncodingParameters encoding = RtpEncodingParameters(ssrc: ssrc);

    if (rtxSsrc) encoding.rtx = {ssrc: rtxSsrc};

    encodings.add(encoding);
  });

  return encodings;
}

/**
 * Adds multi-ssrc based simulcast into the given SDP media section offer.
 */
void addLegacySimulcast({offerMediaObject, int? numStreams} //:
    // {
    // 	offerMediaObject: any;
    // 	numStreams: number;
    // }
    ) //: void
{
  if (numStreams! <= 1) throw Exception('numStreams must be greater than 1');

  // Get the SSRC.
  var ssrcMsidLine = (offerMediaObject.ssrcs /*|| []*/)
      .firstWhere((line) => line.attribute == 'msid');

  if (ssrcMsidLine == null) {
    throw Exception('a=ssrc line with msid information not found');
  }

  // const [ streamId, trackId ] = ssrcMsidLine.value.split(' ')[0];
  var streamtrack = ssrcMsidLine.value.split(' ')[0];
  var streamId = streamtrack[0];
  var trackId = streamtrack[1];

  var firstSsrc = ssrcMsidLine.id;
  var firstRtxSsrc;

  // Get the SSRC for RTX.
  (offerMediaObject.ssrcGroups as List /*|| []*/).any((line) {
    if (line.semantics != 'FID') return false;

    var ssrcs = line.ssrcs.split(RegExp(r'\s+'));

    if (ssrcs[0] == firstSsrc) {
      firstRtxSsrc = ssrcs[1];

      return true;
    } else {
      return false;
    }
  });

  var ssrcCnameLine =
      offerMediaObject.ssrcs.firstWhere((line) => line.attribute == 'cname');

  if (ssrcCnameLine == null) {
    throw Exception('a=ssrc line with cname information not found');
  }

  var cname = ssrcCnameLine.value;
  var ssrcs = [];
  var rtxSsrcs = [];

  for (var i = 0; i < numStreams; ++i) {
    ssrcs.add(firstSsrc + i);

    if (firstRtxSsrc != null) rtxSsrcs.add(firstRtxSsrc + i);
  }

  offerMediaObject.ssrcGroups = [];
  offerMediaObject.ssrcs = [];

  offerMediaObject.ssrcGroups
      .add({'semantics': 'SIM', 'ssrcs': ssrcs.join(' ')});

  for (var i = 0; i < ssrcs.length; ++i) {
    var ssrc = ssrcs[i];

    offerMediaObject.ssrcs
        .add({'id': ssrc, 'attribute': 'cname', 'value': cname});

    offerMediaObject.ssrcs
        .add({'id': ssrc, 'attribute': 'msid', 'value': '$streamId $trackId'});
  }

  for (var i = 0; i < rtxSsrcs.length; ++i) {
    var ssrc = ssrcs[i];
    var rtxSsrc = rtxSsrcs[i];

    offerMediaObject.ssrcs
        .add({'id': rtxSsrc, 'attribute': 'cname', 'value': cname});

    offerMediaObject.ssrcs.add(
        {'id': rtxSsrc, 'attribute': 'msid', 'value': '$streamId $trackId'});

    offerMediaObject.ssrcGroups
        .add({'semantics': 'FID', 'ssrcs': '$ssrc $rtxSsrc'});
  }
}
