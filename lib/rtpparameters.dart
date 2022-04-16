// ignore: slash_for_doc_comments
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rtpparameters.g.dart';

/**
 * The RTP capabilities define what mediasoup or an endpoint can receive at
 * media level.
 */
@JsonSerializable(explicitToJson: true)
class RtpCapabilities {
  // ignore: slash_for_doc_comments
  /**
	 * Supported media and RTX codecs.
	 */
  List<RtpCodecCapability>? codecs;
  // ignore: slash_for_doc_comments
  /**
	 * Supported RTP header extensions.
	 */
  List<RtpHeaderExtension>? headerExtensions;
  // ignore: slash_for_doc_comments
  /**
	 * Supported FEC mechanisms.
	 */
  List<String>? fecMechanisms;

  RtpCapabilities({
    this.codecs = const [],
    this.headerExtensions = const [],
    this.fecMechanisms = const [],
  });

  factory RtpCapabilities.fromJson(Map<String, dynamic> json) =>
      _$RtpCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$RtpCapabilitiesToJson(this);
}

/**
 * Media kind ('audio' or 'video').
 */
// String MediaKind = 'audio' | 'video';

// ignore: slash_for_doc_comments
/**
 * Provides information on the capabilities of a codec within the RTP
 * capabilities. The list of media codecs supported by mediasoup and their
 * settings is defined in the supportedRtpCapabilities.ts file.
 *
 * Exactly one RtpCodecCapability will be present for each supported combination
 * of parameters that requires a distinct value of preferredPayloadType. For
 * example:
 *
 * - Multiple H264 codecs, each with their own distinct 'packetization-mode' and
 *   'profile-level-id' values.
 * - Multiple VP9 codecs, each with their own distinct 'profile-id' value.
 *
 * RtpCodecCapability entries in the mediaCodecs array of RouterOptions do not
 * require preferredPayloadType field (if unset, mediasoup will choose a random
 * one). If given, make sure it's in the 96-127 range.
 */
@JsonSerializable(explicitToJson: true)
class RtpCodecCapability {
  // ignore: slash_for_doc_comments
  /**
	 * Media kind.
	 */
  String kind; //MediaKind type
  // ignore: slash_for_doc_comments
  /**
	 * The codec MIME media type/subtype (e.g. 'audio/opus', 'video/VP8').
	 */
  String mimeType;
  // ignore: slash_for_doc_comments
  /**
	 * The preferred RTP payload type.
	 */
  int? preferredPayloadType; //?: number;
  // ignore: slash_for_doc_comments
  /**
	 * Codec clock rate expressed in Hertz.
	 */
  int clockRate; //: number;
  // ignore: slash_for_doc_comments
  /**
	 * The number of channels supported (e.g. two for stereo). Just for audio.
	 * Default 1.
	 */
  int? channels; //?: number;
  // ignore: slash_for_doc_comments
  /**
	 * Codec specific parameters. Some parameters (such as 'packetization-mode'
	 * and 'profile-level-id' in H264 or 'profile-id' in VP9) are critical for
	 * codec matching.
	 */
  Map<String, dynamic>? parameters; //?: any;
  // ignore: slash_for_doc_comments
  /**
	 * Transport layer and codec-specific feedback messages for this codec.
	 */
  List<RtcpFeedback>? rtcpFeedback; //?: RtcpFeedback[];

  RtpCodecCapability(
    this.kind,
    this.mimeType,
    this.clockRate, {
    this.preferredPayloadType,
    this.channels = 1,
    this.parameters = const {},
    this.rtcpFeedback = const [],
  });

  factory RtpCodecCapability.fromJson(Map<String, dynamic> json) =>
      _$RtpCodecCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$RtpCodecCapabilityToJson(this);
}

/// Direction of RTP header extension.
// String RtpHeaderExtensionDirection = 'sendrecv' | 'sendonly' | 'recvonly' | 'inactive';
enum RtpHeaderDirection {
  sendrecv,
  sendonly,
  recvonly,
  inactive,
}

// ignore: slash_for_doc_comments
/**
 * Provides information relating to supported header extensions. The list of
 * RTP header extensions supported by mediasoup is defined in the
 * supportedRtpCapabilities.ts file.
 *
 * mediasoup does not currently support encrypted RTP header extensions. The
 * direction field is just present in mediasoup RTP capabilities (retrieved via
 * router.rtpCapabilities or mediasoup.getSupportedRtpCapabilities()). It's
 * ignored if present in endpoints' RTP capabilities.
 */
@JsonSerializable()
class RtpHeaderExtension {
  // ignore: slash_for_doc_comments
  /**
	 * Media kind. If empty string, it's valid for all kinds.
	 * Default any media kind.
	 */
  String? kind; //?: MediaKind | '';
  /*
	 * The URI of the RTP header extension, as defined in RFC 5285.
	 */
  String uri; //: string;
  // ignore: slash_for_doc_comments
  /**
	 * The preferred numeric identifier that goes in the RTP packet. Must be
	 * unique.
	 */
  int preferredId; //: number;
  // ignore: slash_for_doc_comments
  /**
	 * If true, it is preferred that the value in the header be encrypted as per
	 * RFC 6904. Default false.
	 */
  bool? preferredEncrypt; //?: boolean;
  // ignore: slash_for_doc_comments
  /**
	 * If 'sendrecv', mediasoup supports sending and receiving this RTP extension.
	 * 'sendonly' means that mediasoup can send (but not receive) it. 'recvonly'
	 * means that mediasoup can receive (but not send) it.
	 */
  String? direction; //?: RtpHeaderExtensionDirection;

  RtpHeaderExtension(
    this.uri,
    this.preferredId, {
    this.kind,
    this.preferredEncrypt,
    this.direction,
  });

  factory RtpHeaderExtension.fromJson(Map<String, dynamic> json) =>
      _$RtpHeaderExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$RtpHeaderExtensionToJson(this);
}

// ignore: slash_for_doc_comments
/**
 * The RTP send parameters describe a media stream received by mediasoup from
 * an endpoint through its corresponding mediasoup Producer. These parameters
 * may include a mid value that the mediasoup transport will use to match
 * received RTP packets based on their MID RTP extension value.
 *
 * mediasoup allows RTP send parameters with a single encoding and with multiple
 * encodings (simulcast). In the latter case, each entry in the encodings array
 * must include a ssrc field or a rid field (the RID RTP extension value). Check
 * the Simulcast and SVC sections for more information.
 *
 * The RTP receive parameters describe a media stream as sent by mediasoup to
 * an endpoint through its corresponding mediasoup Consumer. The mid value is
 * unset (mediasoup does not include the MID RTP extension into RTP packets
 * being sent to endpoints).
 *
 * There is a single entry in the encodings array (even if the corresponding
 * producer uses simulcast). The consumer sends a single and continuous RTP
 * stream to the endpoint and spatial/temporal layer selection is possible via
 * consumer.setPreferredLayers().
 *
 * As an exception, previous bullet is not true when consuming a stream over a
 * PipeTransport, in which all RTP streams from the associated producer are
 * forwarded verbatim through the consumer.
 *
 * The RTP receive parameters will always have their ssrc values randomly
 * generated for all of its  encodings (and optional rtx: { ssrc: XXXX } if the
 * endpoint supports RTX), regardless of the original RTP send parameters in
 * the associated producer. This applies even if the producer's encodings have
 * rid set.
 */
@JsonSerializable(explicitToJson: true)
class RtpParameters {
  // ignore: slash_for_doc_comments
  /**
	 * The MID RTP extension value as defined in the BUNDLE specification.
	 */
  String? mid; //?: string;
  // ignore: slash_for_doc_comments
  /**
	 * Media and RTX codecs in use.
	 */
  List<RtpCodecParameters> codecs; //: RtpCodecParameters[];
  // ignore: slash_for_doc_comments
  /**
	 * RTP header extensions in use.
	 */
  List<RtpHeaderExtensionParameters>?
      headerExtensions; //?: RtpHeaderExtensionParameters[];
  // ignore: slash_for_doc_comments
  /**
	 * Transmitted RTP streams and their settings.
	 */
  List<RtpEncodingParameters>? encodings; //?: RtpEncodingParameters[];
  // ignore: slash_for_doc_comments
  /**
	 * Parameters used for RTCP.
	 */
  RtcpParameters? rtcp; //?: RtcpParameters;

  RtpParameters(
    this.codecs, {
    @required this.mid,
    this.headerExtensions,
    this.encodings,
    this.rtcp,
  });

  factory RtpParameters.fromJson(Map<String, dynamic> json) =>
      _$RtpParametersFromJson(json);

  Map<String, dynamic> toJson() => _$RtpParametersToJson(this);
}

// ignore: slash_for_doc_comments
/**
 * Provides information on codec settings within the RTP parameters. The list
 * of media codecs supported by mediasoup and their settings is defined in the
 * supportedRtpCapabilities.ts file.
 */
@JsonSerializable(explicitToJson: true)
class RtpCodecParameters {
  // ignore: slash_for_doc_comments
  /**
	 * The codec MIME media type/subtype (e.g. 'audio/opus', 'video/VP8').
	 */
  String mimeType; //: string;
  // ignore: slash_for_doc_comments
  /**
	 * The value that goes in the RTP Payload Type Field. Must be unique.
	 */
  int payloadType; //: number;
  // ignore: slash_for_doc_comments
  /**
	 * Codec clock rate expressed in Hertz.
	 */
  int clockRate; //: number;
  // ignore: slash_for_doc_comments
  /**
	 * The number of channels supported (e.g. two for stereo). Just for audio.
	 * Default 1.
	 */
  int? channels; //?: number;
  // ignore: slash_for_doc_comments
  /**
	 * Codec-specific parameters available for signaling. Some parameters (such
	 * as 'packetization-mode' and 'profile-level-id' in H264 or 'profile-id' in
	 * VP9) are critical for codec matching.
	 */
  Map<String, dynamic>? parameters; //?: any;
  // ignore: slash_for_doc_comments
  /**
	 * Transport layer and codec-specific feedback messages for this codec.
	 */
  List<RtcpFeedback>? rtcpFeedback; //?: RtcpFeedback[];

  RtpCodecParameters(
    this.mimeType,
    this.payloadType,
    this.clockRate, {
    this.channels,
    this.parameters,
    this.rtcpFeedback,
  });

  factory RtpCodecParameters.fromJson(Map<String, dynamic> json) =>
      _$RtpCodecParametersFromJson(json);

  Map<String, dynamic> toJson() => _$RtpCodecParametersToJson(this);
}

// ignore: slash_for_doc_comments
/**
 * Provides information on RTCP feedback messages for a specific codec. Those
 * messages can be transport layer feedback messages or codec-specific feedback
 * messages. The list of RTCP feedbacks supported by mediasoup is defined in the
 * supportedRtpCapabilities.ts file.
 */
@JsonSerializable()
class RtcpFeedback {
  // ignore: slash_for_doc_comments
  /**
	 * RTCP feedback type.
	 */
  String type; //: string;
  // ignore: slash_for_doc_comments
  /**
	 * RTCP feedback parameter.
	 */
  String? parameter; //?: string;

  RtcpFeedback(
    this.type, {
    this.parameter,
  });

  factory RtcpFeedback.fromJson(Map<String, dynamic> json) =>
      _$RtcpFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$RtcpFeedbackToJson(this);
}

// ignore: slash_for_doc_comments
/**
 * Provides information relating to an encoding, which represents a media RTP
 * stream and its associated RTX stream (if any).
 */
@JsonSerializable()
class RtpEncodingParameters {
  // ignore: slash_for_doc_comments
  /**
	 * The media SSRC.
	 */
  int? ssrc; //?: number;
  // ignore: slash_for_doc_comments
  /**
	 * The RID RTP extension value. Must be unique.
	 */
  String? rid; //?: string;
  // ignore: slash_for_doc_comments
  /**
	 * Codec payload type this encoding affects. If unset, first media codec is
	 * chosen.
	 */
  int? codecPayloadType; //?: number;
  // ignore: slash_for_doc_comments
  /**
	 * RTX stream information. It must contain a numeric ssrc field indicating
	 * the RTX SSRC.
	 */
  Map<String, int>? rtx; //?: { ssrc: number };
  // ignore: slash_for_doc_comments
  /**
	 * It indicates whether discontinuous RTP transmission will be used. Useful
	 * for audio (if the codec supports it) and for video screen sharing (when
	 * static content is being transmitted, this option disables the RTP
	 * inactivity checks in mediasoup). Default false.
	 */
  bool? dtx; //?: boolean;
  // ignore: slash_for_doc_comments
  /**
	 * Number of spatial and temporal layers in the RTP stream (e.g. 'L1T3').
	 * See webrtc-svc.
	 */
  String? scalabilityMode; //?: string;
  // ignore: slash_for_doc_comments
  /**
	 * Others.
	 */
  double? scaleResolutionDownBy; //?: number;
  int? maxBitrate; //?: number;
  int? maxFramerate; //?: number;
  bool? adaptivePtime; //?: boolean;
  String? priority; //?: 'very-low' | 'low' | 'medium' | 'high';
  String? networkPriority; //?: 'very-low' | 'low' | 'medium' | 'high';

  RtpEncodingParameters({
    this.ssrc,
    this.rid,
    this.codecPayloadType,
    this.rtx,
    this.dtx,
    this.scalabilityMode,
    this.scaleResolutionDownBy,
    this.maxBitrate,
    this.maxFramerate,
    this.adaptivePtime,
    this.priority,
    this.networkPriority,
  });

  factory RtpEncodingParameters.fromJson(Map<String, dynamic> json) =>
      _$RtpEncodingParametersFromJson(json);

  Map<String, dynamic> toJson() => _$RtpEncodingParametersToJson(this);
}

// ignore: slash_for_doc_comments
/**
 * Defines a RTP header extension within the RTP parameters. The list of RTP
 * header extensions supported by mediasoup is defined in the
 * supportedRtpCapabilities.ts file.
 *
 * mediasoup does not currently support encrypted RTP header extensions and no
 * parameters are currently considered.
 */
@JsonSerializable()
class RtpHeaderExtensionParameters {
  // ignore: slash_for_doc_comments
  /**
	 * The URI of the RTP header extension, as defined in RFC 5285.
	 */
  String uri; //: string;
  // ignore: slash_for_doc_comments
  /**
	 * The numeric identifier that goes in the RTP packet. Must be unique.
	 */
  int id; //: number;
  // ignore: slash_for_doc_comments
  /**
	 * If true, the value in the header is encrypted as per RFC 6904. Default false.
	 */
  bool? encrypt; //?: boolean;
  // ignore: slash_for_doc_comments
  /**
	 * Configuration parameters for the header extension.
	 */
  Map<String, dynamic>? parameters; //?: any;

  RtpHeaderExtensionParameters(
    this.uri,
    this.id, {
    this.encrypt,
    this.parameters,
  });

  factory RtpHeaderExtensionParameters.fromJson(Map<String, dynamic> json) =>
      _$RtpHeaderExtensionParametersFromJson(json);

  Map<String, dynamic> toJson() => _$RtpHeaderExtensionParametersToJson(this);
}

// ignore: slash_for_doc_comments
/**
 * Provides information on RTCP settings within the RTP parameters.
 *
 * If no cname is given in a producer's RTP parameters, the mediasoup transport
 * will choose a random one that will be used into RTCP SDES messages sent to
 * all its associated consumers.
 *
 * mediasoup assumes reducedSize to always be true.
 */
@JsonSerializable()
class RtcpParameters {
  // ignore: slash_for_doc_comments
  /**
	 * The Canonical Name (CNAME) used by RTCP (e.g. in SDES messages).
	 */
  String? cname; //?: string;
  // ignore: slash_for_doc_comments
  /**
	 * Whether reduced size RTCP RFC 5506 is configured (if true) or compound RTCP
	 * as specified in RFC 3550 (if false). Default true.
	 */
  bool? reducedSize; //?: boolean;
  // ignore: slash_for_doc_comments
  /**
	 * Whether RTCP-mux is used. Default true.
	 */
  bool? mux; //?: boolean;

  RtcpParameters({
    this.cname,
    this.reducedSize,
    this.mux,
  });

  factory RtcpParameters.fromJson(Map<String, dynamic> json) =>
      _$RtcpParametersFromJson(json);

  Map<String, dynamic> toJson() => _$RtcpParametersToJson(this);
}

class ExtendedRtpCodec extends RtpCodecCapability {
  int? localPayloadType;
  int? localRtxPayloadType;
  int? remotePayloadType;
  int? remoteRtxPayloadType;
  Map<String, dynamic> localParameters;
  Map<String, dynamic> remoteParameters;

  ExtendedRtpCodec({
    required String kind,
    required String mimeType,
    required int clockRate,
    int channels = 1,
    List<RtcpFeedback> rtcpFeedback = const [],
    this.localPayloadType,
    this.localRtxPayloadType,
    this.remotePayloadType,
    this.remoteRtxPayloadType,
    required this.localParameters,
    required this.remoteParameters,
  }) : super(
          kind,
          mimeType,
          clockRate,
          channels: channels,
          rtcpFeedback: rtcpFeedback,
        );
}

class ExtendedRtpHeaderExtension extends RtpHeaderExtension {
  final int sendId;
  final int recvId;
  final bool encrypt;

  ExtendedRtpHeaderExtension({
    required String kind,
    required String uri,
    required this.sendId,
    required this.recvId,
    required this.encrypt,
    required String direction,
  }) : super(
          uri,
          0,
          kind: kind,
          direction: direction,
        );
}
