// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IceCandidate _$IceCandidateFromJson(Map<String, dynamic> json) => IceCandidate(
      json['foundation'] as String,
      json['priority'] as int,
      json['ip'] as String,
      json['protocol'] as String,
      json['port'] as int,
      json['type'] as String,
      json['tcpType'] as String,
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
