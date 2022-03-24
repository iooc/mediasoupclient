// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sctpparameters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SctpCapabilities _$SctpCapabilitiesFromJson(Map<String, dynamic> json) =>
    SctpCapabilities(
      json['numStreams'] == null
          ? null
          : NumSctpStreams.fromJson(json['numStreams'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SctpCapabilitiesToJson(SctpCapabilities instance) =>
    <String, dynamic>{
      'numStreams': instance.numStreams?.toJson(),
    };

NumSctpStreams _$NumSctpStreamsFromJson(Map<String, dynamic> json) =>
    NumSctpStreams(
      json['OS'] as int,
      json['MIS'] as int,
    );

Map<String, dynamic> _$NumSctpStreamsToJson(NumSctpStreams instance) =>
    <String, dynamic>{
      'OS': instance.OS,
      'MIS': instance.MIS,
    };

SctpParameters _$SctpParametersFromJson(Map<String, dynamic> json) =>
    SctpParameters(
      json['port'] as int,
      json['OS'] as int,
      json['MIS'] as int,
      json['maxMessageSize'] as int,
    );

Map<String, dynamic> _$SctpParametersToJson(SctpParameters instance) =>
    <String, dynamic>{
      'port': instance.port,
      'OS': instance.OS,
      'MIS': instance.MIS,
      'maxMessageSize': instance.maxMessageSize,
    };
