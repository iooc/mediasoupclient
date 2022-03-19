import 'package:flutter/cupertino.dart';

import '../../rtpparameters.dart';

Map<String, dynamic> extractPlainRtpParameters(
    {@required sdpObject, @required String? kind} //:
    // {
    // 	sdpObject: any;
    // 	kind: MediaKind;
    // }
    ) //:
// {
// 	ip: string;
// 	ipVersion: 4 | 6;
// 	port: number;
// }
{
  var mediaObject =
      (sdpObject.media /*|| []*/).firstWhere((m) => m.type == kind);

  if (mediaObject == null) throw Exception('m=$kind section not found');

  var connectionObject = mediaObject.connection ?? sdpObject.connection;

  return {
    'ip': connectionObject.ip,
    'ipVersion': connectionObject.version,
    'port': mediaObject.port
  };
}

List<RtpEncodingParameters> getRtpEncodings(
    {@required sdpObject, @required String? kind} //:
    // {
    // 	sdpObject: any;
    // 	kind: MediaKind;
    // }
    ) //: RtpEncodingParameters[]
{
  var mediaObject =
      (sdpObject.media /*|| []*/).firstWhere((m) => m.type == kind);

  if (mediaObject == null) throw Exception('m=$kind section not found');

  var ssrcCnameLine = (mediaObject.ssrcs /*|| []*/)[0];
  var ssrc = ssrcCnameLine?.id;

  if (ssrc) {
    return [RtpEncodingParameters(ssrc: ssrc)];
  } else {
    return [];
  }
}
