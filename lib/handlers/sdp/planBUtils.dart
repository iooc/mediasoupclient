import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../rtpparameters.dart';

List<RtpEncodingParameters> getRtpEncodings(
    {offerMediaObject, MediaStreamTrack? track} //:
    // {
    // 	offerMediaObject: any;
    // 	track: MediaStreamTrack;
    // }
    ) //: RtpEncodingParameters[]
{
  // First media SSRC (or the only one).
  var firstSsrc;
  var ssrcs = [];

  for (var line in offerMediaObject.ssrcs /* || []*/) {
    if (line.attribute != 'msid') continue;

    var trackId = line.value.split(' ')[1];

    if (trackId == track!.id) {
      var ssrc = line.id;

      ssrcs.add(ssrc);

      firstSsrc ??= ssrc;
    }
  }

  if (ssrcs.isEmpty) {
    throw Exception(
        'a=ssrc line with msid information not found [track.id:${track!.id}]');
  }

  var ssrcToRtxSsrc = Map();

  // First assume RTX is used.
  for (var line in offerMediaObject.ssrcGroups /*|| []*/) {
    if (line.semantics != 'FID') continue;

    var arr = line.ssrcs.split(RegExp(r'\s+'));

    var ssrc = int.parse(arr[0]); //Number(ssrc);
    var rtxSsrc = int.parse(arr[1]); //Number(rtxSsrc);

    if (ssrcs.contains(ssrc)) {
      // Remove both the SSRC and RTX SSRC from the set so later we know that they
      // are already handled.
      ssrcs.remove(ssrc);
      ssrcs.remove(rtxSsrc);

      // Add to the map.
      ssrcToRtxSsrc[ssrc] = rtxSsrc;
    }
  }

  // If the set of SSRCs is not empty it means that RTX is not being used, so take
  // media SSRCs from there.
  for (var ssrc in ssrcs) {
    // Add to the map.
    ssrcToRtxSsrc[ssrc] = null;
  }

  List<RtpEncodingParameters> encodings = [];

  // for (var [ ssrc, rtxSsrc ] in ssrcToRtxSsrc)
  ssrcToRtxSsrc.forEach((ssrc, rtxSsrc) {
    var encoding = RtpEncodingParameters(ssrc: ssrc);

    if (rtxSsrc != null) encoding.rtx = {ssrc: rtxSsrc};

    encodings.add(encoding);
  });

  return encodings;
}

/**
 * Adds multi-ssrc based simulcast into the given SDP media section offer.
 */
void addLegacySimulcast(
    {@required offerMediaObject,
    @required MediaStreamTrack? track,
    @required int? numStreams} //:
    // {
    // 	offerMediaObject: any;
    // 	track: MediaStreamTrack;
    // 	numStreams: number;
    // }
    ) //: void
{
  if (numStreams! <= 1) throw Exception('numStreams must be greater than 1');

  var firstSsrc;
  var firstRtxSsrc;
  var streamId;

  // Get the SSRC.
  var ssrcMsidLine = (offerMediaObject.ssrcs /*|| []*/).firstWhere((line) {
    if (line.attribute != 'msid') return false;

    var trackId = line.value.split(' ')[1];

    if (trackId == track!.id) {
      firstSsrc = line.id;
      streamId = line.value.split(' ')[0];

      return true;
    } else {
      return false;
    }
  });

  if (ssrcMsidLine == null) {
    throw Exception(
        'a=ssrc line with msid information not found [track.id:${track!.id}]');
  }

  // Get the SSRC for RTX.
  ((offerMediaObject.ssrcGroups as List) /*|| []*/).contains((line) {
    if (line.semantics != 'FID') return false;

    var ssrcs = line.ssrcs.split(RegExp(r'\s+'));

    if (ssrcs[0] == firstSsrc) {
      firstRtxSsrc = ssrcs[1];

      return true;
    } else {
      return false;
    }
  });

  var ssrcCnameLine = offerMediaObject.ssrcs.firstWhere(
      (line) => (line.attribute == 'cname' && line.id == firstSsrc));

  if (ssrcCnameLine == null) {
    throw Exception(
        'a=ssrc line with cname information not found [track.id:${track!.id}]');
  }

  var cname = ssrcCnameLine.value;
  var ssrcs = [];
  var rtxSsrcs = [];

  for (var i = 0; i < numStreams; ++i) {
    ssrcs.add(firstSsrc + i);

    if (firstRtxSsrc != null) rtxSsrcs.add(firstRtxSsrc + i);
  }

  offerMediaObject.ssrcGroups = offerMediaObject.ssrcGroups /*|| []*/;
  offerMediaObject.ssrcs = offerMediaObject.ssrcs /*|| []*/;

  offerMediaObject.ssrcGroups
      .add({'semantics': 'SIM', 'ssrcs': ssrcs.join(' ')});

  for (var i = 0; i < ssrcs.length; ++i) {
    var ssrc = ssrcs[i];

    (offerMediaObject.ssrcs as List)
        .add({'id': ssrc, 'attribute': 'cname', 'value': cname});

    (offerMediaObject.ssrcs as List).add(
        {'id': ssrc, 'attribute': 'msid', 'value': '$streamId ${track!.id}'});
  }

  for (var i = 0; i < rtxSsrcs.length; ++i) {
    var ssrc = ssrcs[i];
    var rtxSsrc = rtxSsrcs[i];

    (offerMediaObject.ssrcs as List)
        .add({'id': rtxSsrc, 'attribute': 'cname', 'value': cname});

    (offerMediaObject.ssrcs as List).add({
      'id': rtxSsrc,
      'attribute': 'msid',
      'value': '$streamId ${track!.id}'
    });

    (offerMediaObject.ssrcGroups as List)
        .add({'semantics': 'FID', 'ssrcs': '$ssrc $rtxSsrc'});
  }
}
