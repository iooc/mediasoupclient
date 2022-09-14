// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rtpparameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RtpCapabilities _$RtpCapabilitiesFromJson(Map<String, dynamic> json) =>
    RtpCapabilities(
      codecs: (json['codecs'] as List<dynamic>?)
              ?.map(
                  (e) => RtpCodecCapability.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      headerExtensions: (json['headerExtensions'] as List<dynamic>?)
              ?.map(
                  (e) => RtpHeaderExtension.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fecMechanisms: (json['fecMechanisms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RtpCapabilitiesToJson(RtpCapabilities instance) =>
    <String, dynamic>{
      'codecs': instance.codecs?.map((e) => e.toJson()).toList(),
      'headerExtensions':
          instance.headerExtensions?.map((e) => e.toJson()).toList(),
      'fecMechanisms': instance.fecMechanisms,
    };

RtpCodecCapability _$RtpCodecCapabilityFromJson(Map<String, dynamic> json) =>
    RtpCodecCapability(
      json['kind'] as String,
      json['mimeType'] as String,
      json['clockRate'] as int,
      preferredPayloadType: json['preferredPayloadType'] as int?,
      channels: json['channels'] as int? ?? 1,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      rtcpFeedback: (json['rtcpFeedback'] as List<dynamic>?)
              ?.map((e) => RtcpFeedback.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RtpCodecCapabilityToJson(RtpCodecCapability instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'mimeType': instance.mimeType,
      'preferredPayloadType': instance.preferredPayloadType,
      'clockRate': instance.clockRate,
      'channels': instance.channels,
      'parameters': instance.parameters,
      'rtcpFeedback': instance.rtcpFeedback?.map((e) => e.toJson()).toList(),
    };

RtpHeaderExtension _$RtpHeaderExtensionFromJson(Map<String, dynamic> json) =>
    RtpHeaderExtension(
      json['uri'] as String,
      json['preferredId'] as int,
      kind: json['kind'] as String?,
      preferredEncrypt: json['preferredEncrypt'] as bool?,
      direction: json['direction'] as String?,
    );

Map<String, dynamic> _$RtpHeaderExtensionToJson(RtpHeaderExtension instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'uri': instance.uri,
      'preferredId': instance.preferredId,
      'preferredEncrypt': instance.preferredEncrypt,
      'direction': instance.direction,
    };

RtpParameters _$RtpParametersFromJson(Map<String, dynamic> json) =>
    RtpParameters(
      (json['codecs'] as List<dynamic>)
          .map((e) => RtpCodecParameters.fromJson(e as Map<String, dynamic>))
          .toList(),
      mid: json['mid'] as String?,
      headerExtensions: (json['headerExtensions'] as List<dynamic>?)
          ?.map((e) =>
              RtpHeaderExtensionParameters.fromJson(e as Map<String, dynamic>))
          .toList(),
      encodings: (json['encodings'] as List<dynamic>?)
          ?.map(
              (e) => RtpEncodingParameters.fromJson(e as Map<String, dynamic>))
          .toList(),
      rtcp: json['rtcp'] == null
          ? null
          : RtcpParameters.fromJson(json['rtcp'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RtpParametersToJson(RtpParameters instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'codecs': instance.codecs.map((e) => e.toJson()).toList(),
      'headerExtensions':
          instance.headerExtensions?.map((e) => e.toJson()).toList(),
      'encodings': instance.encodings?.map((e) => e.toJson()).toList(),
      'rtcp': instance.rtcp?.toJson(),
    };

RtpCodecParameters _$RtpCodecParametersFromJson(Map<String, dynamic> json) =>
    RtpCodecParameters(
      json['mimeType'] as String,
      json['payloadType'] as int,
      json['clockRate'] as int,
      channels: json['channels'] as int?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      rtcpFeedback: (json['rtcpFeedback'] as List<dynamic>?)
          ?.map((e) => RtcpFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RtpCodecParametersToJson(RtpCodecParameters instance) =>
    <String, dynamic>{
      'mimeType': instance.mimeType,
      'payloadType': instance.payloadType,
      'clockRate': instance.clockRate,
      'channels': instance.channels,
      'parameters': instance.parameters,
      'rtcpFeedback': instance.rtcpFeedback?.map((e) => e.toJson()).toList(),
    };

RtcpFeedback _$RtcpFeedbackFromJson(Map<String, dynamic> json) => RtcpFeedback(
      json['type'] as String,
      parameter: json['parameter'] as String?,
    );

Map<String, dynamic> _$RtcpFeedbackToJson(RtcpFeedback instance) =>
    <String, dynamic>{
      'type': instance.type,
      'parameter': instance.parameter,
    };

RtpEncodingParameters _$RtpEncodingParametersFromJson(
        Map<String, dynamic> json) =>
    RtpEncodingParameters(
      ssrc: json['ssrc'] as int?,
      rid: json['rid'] as String?,
      codecPayloadType: json['codecPayloadType'] as int?,
      rtx: (json['rtx'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as int),
      ),
      dtx: json['dtx'] as bool?,
      scalabilityMode: json['scalabilityMode'] as String?,
      scaleResolutionDownBy:
          (json['scaleResolutionDownBy'] as num?)?.toDouble(),
      maxBitrate: json['maxBitrate'] as int?,
      maxFramerate: json['maxFramerate'] as int?,
      minBitrate: json['minBitrate'] as int?,
      adaptivePtime: json['adaptivePtime'] as bool?,
      priority: json['priority'] as String?,
      networkPriority: json['networkPriority'] as String?,
    );

Map<String, dynamic> _$RtpEncodingParametersToJson(
        RtpEncodingParameters instance) =>
    <String, dynamic>{
      'ssrc': instance.ssrc,
      'rid': instance.rid,
      'codecPayloadType': instance.codecPayloadType,
      'rtx': instance.rtx,
      'dtx': instance.dtx,
      'scalabilityMode': instance.scalabilityMode,
      'scaleResolutionDownBy': instance.scaleResolutionDownBy,
      'maxBitrate': instance.maxBitrate,
      'maxFramerate': instance.maxFramerate,
      'minBitrate': instance.minBitrate,
      'adaptivePtime': instance.adaptivePtime,
      'priority': instance.priority,
      'networkPriority': instance.networkPriority,
    };

RtpHeaderExtensionParameters _$RtpHeaderExtensionParametersFromJson(
        Map<String, dynamic> json) =>
    RtpHeaderExtensionParameters(
      json['uri'] as String,
      json['id'] as int,
      encrypt: json['encrypt'] as bool?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RtpHeaderExtensionParametersToJson(
        RtpHeaderExtensionParameters instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'id': instance.id,
      'encrypt': instance.encrypt,
      'parameters': instance.parameters,
    };

RtcpParameters _$RtcpParametersFromJson(Map<String, dynamic> json) =>
    RtcpParameters(
      cname: json['cname'] as String?,
      reducedSize: json['reducedSize'] as bool?,
      mux: json['mux'] as bool?,
    );

Map<String, dynamic> _$RtcpParametersToJson(RtcpParameters instance) =>
    <String, dynamic>{
      'cname': instance.cname,
      'reducedSize': instance.reducedSize,
      'mux': instance.mux,
    };
