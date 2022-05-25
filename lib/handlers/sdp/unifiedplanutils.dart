import '../../utils.dart';

import '../../rtpparameters.dart';
import 'sdpobject.dart';

List<RtpEncodingParameters> getRtpEncodings(MediaObject offerMediaObject //:
    // { offerMediaObject: any }
    ) //: RtpEncodingParameters[]
{
  // const ssrcs = new Set();
  List<int?> ssrcs = [];
  for (Ssrc line in offerMediaObject.ssrcs ?? []) {
    var ssrc = line.id;

    ssrcs.add(ssrc);
  }

  if (ssrcs.isEmpty) throw Exception('no a=ssrc lines found');

  var ssrcToRtxSsrc = <dynamic, int?>{};
  // First assume RTX is used.
  for (SsrcGroup line in offerMediaObject.ssrcGroups ?? []) {
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

    if (rtxSsrc != null) encoding.rtx = {ssrc: rtxSsrc};

    encodings.add(encoding);
  });

  return encodings;
}

/**
 * Adds multi-ssrc based simulcast into the given SDP media section offer.
 */
void addLegacySimulcast({MediaObject? offerMediaObject, int? numStreams} //:
    // {
    // 	offerMediaObject: any;
    // 	numStreams: number;
    // }
    ) //: void
{
  if (numStreams! <= 1) throw Exception('numStreams must be greater than 1');

  // Get the SSRC.
  var ssrcMsidLine = (offerMediaObject!.ssrcs ?? [] /*|| []*/)
      .firstWhereOrNull((line) => line.attribute == 'msid');

  if (ssrcMsidLine == null) {
    throw Exception('a=ssrc line with msid information not found');
  }

  // const [ streamId, trackId ] = ssrcMsidLine.value.split(' ')[0];
  var streamtrack = ssrcMsidLine.value.split(' ')[0];
  var streamId = streamtrack[0];
  var trackId = streamtrack[1];

  var firstSsrc = ssrcMsidLine.id;
  String? firstRtxSsrc;

  // Get the SSRC for RTX.
  (offerMediaObject.ssrcGroups ?? []).any((line) {
    if (line.semantics != 'FID') return false;

    var ssrcs = line.ssrcs.split(RegExp(r'\s+'));

    if (ssrcs[0] == firstSsrc.toString()) {
      firstRtxSsrc = ssrcs[1];

      return true;
    } else {
      return false;
    }
  });

  var ssrcCnameLine = offerMediaObject.ssrcs
      ?.firstWhereOrNull((line) => line.attribute == 'cname');

  if (ssrcCnameLine == null) {
    throw Exception('a=ssrc line with cname information not found');
  }

  var cname = ssrcCnameLine.value;
  var ssrcs = [];
  var rtxSsrcs = [];

  for (var i = 0; i < numStreams; ++i) {
    ssrcs.add(firstSsrc! + i);

    if (firstRtxSsrc != null) rtxSsrcs.add(int.parse(firstRtxSsrc!) + i);
  }

  offerMediaObject.ssrcGroups = [];
  offerMediaObject.ssrcs = [];

  offerMediaObject.ssrcGroups!
      .add(SsrcGroup(semantics: 'SIM', ssrcs: ssrcs.join(' ')));

  for (var i = 0; i < ssrcs.length; ++i) {
    var ssrc = ssrcs[i];

    offerMediaObject.ssrcs!
        .add(Ssrc(id: ssrc, attribute: 'cname', value: cname));

    offerMediaObject.ssrcs!
        .add(Ssrc(id: ssrc, attribute: 'msid', value: '$streamId $trackId'));
  }

  for (var i = 0; i < rtxSsrcs.length; ++i) {
    var ssrc = ssrcs[i];
    var rtxSsrc = rtxSsrcs[i];

    offerMediaObject.ssrcs!
        .add(Ssrc(id: rtxSsrc, attribute: 'cname', value: cname));

    offerMediaObject.ssrcs!
        .add(Ssrc(id: rtxSsrc, attribute: 'msid', value: '$streamId $trackId'));

    offerMediaObject.ssrcGroups!
        .add(SsrcGroup(semantics: 'FID', ssrcs: '$ssrc $rtxSsrc'));
  }
}
