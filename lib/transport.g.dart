// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IceParameters _$IceParametersFromJson(Map<String, dynamic> json) =>
    IceParameters(
      json['usernameFragment'] as String,
      json['password'] as String,
      iceLite: json['iceLite'] as bool?,
    );

Map<String, dynamic> _$IceParametersToJson(IceParameters instance) =>
    <String, dynamic>{
      'usernameFragment': instance.usernameFragment,
      'password': instance.password,
      'iceLite': instance.iceLite,
    };

IceCandidate _$IceCandidateFromJson(Map<String, dynamic> json) => IceCandidate(
      json['foundation'].toString(),
      json['priority'] as int,
      json['ip'] as String,
      json['protocol'] as String,
      json['port'] as int,
      json['type'] as String,
      json['tcpType'] as String?,
    );

Map<String, dynamic> _$IceCandidateToJson(IceCandidate instance) =>
    <String, dynamic>{
      'foundation': instance.foundation,
      'priority': instance.priority,
      'ip': instance.ip,
      'protocol': instance.protocol,
      'port': instance.port,
      'type': instance.type,
      'tcpType': instance.tcpType,
    };

DtlsParameters _$DtlsParametersFromJson(Map<String, dynamic> json) =>
    DtlsParameters(
      (json['fingerprints'] as List<dynamic>)
          .map((e) => DtlsFingerprint.fromJson(e as Map<String, dynamic>))
          .toList(),
      role: json['role'] as String?,
    );

Map<String, dynamic> _$DtlsParametersToJson(DtlsParameters instance) =>
    <String, dynamic>{
      'role': instance.role,
      'fingerprints': instance.fingerprints.map((e) => e.toJson()).toList(),
    };

DtlsFingerprint _$DtlsFingerprintFromJson(Map<String, dynamic> json) =>
    DtlsFingerprint(
      json['algorithm'] as String,
      json['value'] as String,
    );

Map<String, dynamic> _$DtlsFingerprintToJson(DtlsFingerprint instance) =>
    <String, dynamic>{
      'algorithm': instance.algorithm,
      'value': instance.value,
    };

PlainRtpParameters _$PlainRtpParametersFromJson(Map<String, dynamic> json) =>
    PlainRtpParameters(
      json['ip'] as String,
      json['ipVersion'] as int,
      json['port'] as int,
    );

Map<String, dynamic> _$PlainRtpParametersToJson(PlainRtpParameters instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'ipVersion': instance.ipVersion,
      'port': instance.port,
    };
