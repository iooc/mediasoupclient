import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../rtpparameters.dart';
import '../../utils.dart' as utils;

/**
 * Normalize ORTC based Edge's RTCRtpReceiver.getCapabilities() to produce a full
 * compliant ORTC RTCRtpCapabilities.
 */
RtpCapabilities getCapabilities() //: RtpCapabilities
{
  var nativeCaps = (RTCRtpReceiver as dynamic).getCapabilities();
  var caps = utils.clone(nativeCaps, {});

  for (var codec in caps.codecs) {
    // Rename numChannels to channels.
    codec.channels = codec.numChannels;
    // delete codec.numChannels;

    // Add mimeType.
    // codec.mimeType = codec.mimeType || '${codec.kind}/${codec.name}';
    if (codec.mimeType == null) codec.mimeType = '${codec.kind}/${codec.name}';

    // NOTE: Edge sets some numeric parameters as string rather than number. Fix them.
    if (codec.parameters) {
      var parameters = codec.parameters;

      if (parameters.apt) parameters.apt = parameters.apt;

      if (parameters['packetization-mode'])
        // parameters['packetization-mode'] = Number(parameters['packetization-mode']);
        parameters['packetization-mode'] = parameters['packetization-mode'];
    }

    // Delete emty parameter String in rtcpFeedback.
    for (var feedback in codec.rtcpFeedback /* || []*/) {
      if (!feedback.parameter) feedback.parameter = '';
    }
  }

  return caps;
}

/**
 * Generate RTCRtpParameters as ORTC based Edge likes.
 */
RtpParameters mangleRtpParameters(RtpParameters rtpParameters) //: RtpParameters
{
  var params = utils.clone(rtpParameters, {});

  // Rename mid to muxId.
  if (params.mid != null) {
    params.muxId = params.mid;
    // delete params.mid;
  }

  for (var codec in params.codecs) {
    // Rename channels to numChannels.
    if (codec.channels != null) {
      codec.numChannels = codec.channels;
      // delete codec.channels;
    }

    // Add codec.name (requried by Edge).
    if (codec.mimeType != null && codec.name == null)
      codec.name = codec.mimeType.split('/')[1];

    // Remove mimeType.
    // delete codec.mimeType;
  }

  return params;
}
