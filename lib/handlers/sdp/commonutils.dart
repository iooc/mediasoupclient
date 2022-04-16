import '../../rtpparameters.dart';
import '../../transport.dart';
import 'package:sdp_transform/sdp_transform.dart' as sdpTransform;

import 'sdpobject.dart';

RtpCapabilities extractRtpCapabilities(SdpObject sdpObject //:
    //{ sdpObject: any }
    ) //: RtpCapabilities
{
  // Map of RtpCodecParameters indexed by payload type.
  Map<int, RtpCodecCapability> codecsMap = {};
  // Array of RtpHeaderExtensions.
  List<RtpHeaderExtension> headerExtensions = [];
  // Whether a m=audio/video section has been already found.
  var gotAudio = false;
  var gotVideo = false;

  for (var m in sdpObject.media) {
    String kind = m.type!;
    // print('kind:' + kind);
    switch (kind) {
      case 'audio':
        {
          if (gotAudio) continue;

          gotAudio = true;

          break;
        }
      case 'video':
        {
          if (gotVideo) continue;

          gotVideo = true;

          break;
        }
      default:
        {
          continue;
        }
    }

    // Get codecs.
    for (var rtp in m.rtp!) {
      // print('codec:' + rtp['codec']);
      RtpCodecCapability codec = RtpCodecCapability(
        kind,
        '$kind/${rtp.codec}',
        rtp.rate,
        preferredPayloadType: rtp.payload,
        channels: rtp.encoding,
        parameters: {},
        rtcpFeedback: [],
      );
      // {
      // 	kind                 : kind,
      // 	mimeType             : `${kind}/${rtp.codec}`,
      // 	preferredPayloadType : rtp.payload,
      // 	clockRate            : rtp.rate,
      // 	channels             : rtp.encoding,
      // 	parameters           : {},
      // 	rtcpFeedback         : []
      // };

      // codecsMap.set(codec.preferredPayloadType, codec);
      codecsMap[codec.preferredPayloadType!] = codec;
    }

    // Get codec parameters.
    for (var fmtp in m.fmtp! /*|| []*/) {
      var parameters =
          sdpTransform.parseParams(fmtp.config) as Map<String, dynamic>;
      // var codec = codecsMap.get(fmtp.payload);
      var codec = codecsMap[fmtp.payload];

      if (codec == null) continue;

      // Specials case to convert parameter value to string.
      if (parameters.isNotEmpty && parameters['profile-level-id'] != null) {
        parameters['profile-level-id'] =
            parameters['profile-level-id'].toString();
      }

      codec.parameters = parameters;
    }

    // Get RTCP feedback for each codec.
    for (var fb in m.rtcpFb! /* || []*/) {
      var codec = codecsMap[fb.payload];

      if (codec == null) continue;

      RtcpFeedback feedback = RtcpFeedback(fb.type, parameter: fb.subtype);
      // {
      // 	type      : fb.type,
      // 	parameter : fb.subtype
      // };

      // if (!feedback.parameter)
      // 	delete feedback.parameter;

      codec.rtcpFeedback!.add(feedback);
    }

    // Get RTP header extensions.
    for (var ext in m.ext! /*|| []*/) {
      // Ignore encrypted extensions (not yet supported in mediasoup).
      if (ext.encryptUri != null) continue;

      RtpHeaderExtension headerExtension = RtpHeaderExtension(
        ext.uri!,
        ext.value!,
        kind: kind,
      );
      // {
      // 	kind        : kind,
      // 	uri         : ext.uri,
      // 	preferredId : ext.value
      // };

      headerExtensions.add(headerExtension);
    }
  }

  RtpCapabilities rtpCapabilities = RtpCapabilities(
    codecs: codecsMap.values.toList(),
    headerExtensions: headerExtensions,
  );
  // {
  // 	codecs           : Array.from(codecsMap.values()),
  // 	headerExtensions : headerExtensions
  // };

  return rtpCapabilities;
}

DtlsParameters extractDtlsParameters({Map<String, dynamic>? sdpObject} //:
    //{ sdpObject: any }
    ) //: DtlsParameters
{
  var mediaObject = (sdpObject!['media'] /*|| []*/).find(
      (m /*: { iceUfrag: string; port: number }*/) =>
          (m.iceUfrag && m.port != 0));

  if (mediaObject == null) throw Exception('no active media section found');

  // var fingerprint = mediaObject.fingerprint || sdpObject.fingerprint;
  var fingerprint = mediaObject.fingerprint;
  if (mediaObject.fingerprint == null) fingerprint = sdpObject['fingerprint'];
  String role; //: DtlsRole | undefined;

  switch (mediaObject.setup) {
    case 'active':
      role = 'client';
      break;
    case 'passive':
      role = 'server';
      break;
    case 'actpass':
      role = 'auto';
      break;
  }

  DtlsParameters dtlsParameters =
      DtlsParameters([DtlsFingerprint(fingerprint.type, fingerprint.hash)]);
  // {
  // 	role,
  // 	fingerprints :
  // 	[
  // 		{
  // 			algorithm : fingerprint.type,
  // 			value     : fingerprint.hash
  // 		}
  // 	]
  // };

  return dtlsParameters;
}

String getCname({offerMediaObject} //:
    //{ offerMediaObject: any }
    ) //: string
{
  var ssrcCnameLine = (offerMediaObject.ssrcs /*|| []*/)
      .find((line /*: { attribute: string }*/) => line.attribute == 'cname');

  if (!ssrcCnameLine) return '';

  return ssrcCnameLine.value;
}

/**
 * Apply codec parameters in the given SDP m= section answer based on the
 * given RTP parameters of an offer.
 */
void applyCodecParameters(
    {RtpParameters? offerRtpParameters, answerMediaObject} //:
    // {
    // 	offerRtpParameters: RtpParameters;
    // 	answerMediaObject: any;
    // }
    ) //: void
{
  for (var codec in offerRtpParameters!.codecs) {
    var mimeType = codec.mimeType.toLowerCase();

    // Avoid parsing codec parameters for unhandled codecs.
    if (mimeType != 'audio/opus') continue;

    var rtp = (answerMediaObject.rtp /*|| []*/)
        .find((r /*: { payload: number }*/) => r.payload == codec.payloadType);

    if (!rtp) continue;

    // Just in case.
    // answerMediaObject.fmtp = answerMediaObject.fmtp || [];
    answerMediaObject.fmtp =
        answerMediaObject.fmtp == null ? [] : answerMediaObject.fmtp;

    var fmtp = answerMediaObject.fmtp
        .find((f /*: { payload: number }*/) => f.payload == codec.payloadType);

    if (fmtp == null) {
      fmtp = {'payload': codec.payloadType, 'config': ''};
      answerMediaObject.fmtp.add(fmtp);
    }

    var parameters = sdpTransform.parseParams(fmtp.config);

    switch (mimeType) {
      case 'audio/opus':
        {
          var spropStereo = codec.parameters!['sprop-stereo'];

          if (spropStereo != null) parameters['stereo'] = spropStereo ? 1 : 0;

          break;
        }
    }

    // Write the codec fmtp.config back.
    fmtp.config = '';

    var sortParams = parameters.keys.toList();
    sortParams.sort();
    for (var key in sortParams /*Object.keys(parameters)*/) {
      if (fmtp.config) fmtp.config += ';';

      fmtp.config += '$key=${parameters[key]}';
    }
  }
}
