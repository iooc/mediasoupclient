// ignore_for_file: slash_for_doc_comments

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'sctpparameters.g.dart';

@JsonSerializable(explicitToJson: true)
class SctpCapabilities {
  NumSctpStreams? numStreams; //: NumSctpStreams;

  SctpCapabilities(this.numStreams);
  factory SctpCapabilities.fromJson(Map<String, dynamic> json) =>
      _$SctpCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$SctpCapabilitiesToJson(this);
}

@JsonSerializable()
class NumSctpStreams {
  /**
	 * Initially requested number of outgoing SCTP streams.
	 */
  int OS; //: number;
  /**
	 * Maximum number of incoming SCTP streams.
	 */
  int MIS; //: number;

  NumSctpStreams(
    this.OS,
    this.MIS,
  );
  factory NumSctpStreams.fromJson(Map<String, dynamic> json) =>
      _$NumSctpStreamsFromJson(json);

  Map<String, dynamic> toJson() => _$NumSctpStreamsToJson(this);
}

@JsonSerializable()
class SctpParameters {
  /**
	 * Must always equal 5000.
	 */
  int port; //: number;
  /**
	 * Initially requested number of outgoing SCTP streams.
	 */
  int OS; //: number;
  /**
	 * Maximum number of incoming SCTP streams.
	 */
  int MIS; //: number;
  /**
	 * Maximum allowed size for SCTP messages.
	 */
  int maxMessageSize; //: number;

  SctpParameters(
    this.port,
    this.OS,
    this.MIS,
    this.maxMessageSize,
  );
  factory SctpParameters.fromJson(Map<String, dynamic> json) =>
      _$SctpParametersFromJson(json);

  Map<String, dynamic> toJson() => _$SctpParametersToJson(this);
}

/**
 * SCTP stream parameters describe the reliability of a certain SCTP stream.
 * If ordered is true then maxPacketLifeTime and maxRetransmits must be
 * false.
 * If ordered if false, only one of maxPacketLifeTime or maxRetransmits
 * can be true.
 */
class SctpStreamParameters {
  /**
	 * SCTP stream id.
	 */
  int? streamId; //?: number;
  /**
	 * Whether data messages must be received in order. if true the messages will
	 * be sent reliably. Default true.
	 */
  bool? ordered; //?: boolean;
  /**
	 * When ordered is false indicates the time (in milliseconds) after which a
	 * SCTP packet will stop being retransmitted.
	 */
  int? maxPacketLifeTime; //?: number;
  /**
	 * When ordered is false indicates the maximum number of times a packet will
	 * be retransmitted.
	 */
  int? maxRetransmits; //?: number;
  /**
	 * DataChannel priority.
	 */
  String? priority; //?: RTCPriorityType;
  /**
	 * A label which can be used to distinguish this DataChannel from others.
	 */
  String? label; //?: string;
  /**
	 * Name of the sub-protocol used by this DataChannel.
	 */
  String? protocol; //?: string;

  SctpStreamParameters({
    this.streamId,
    this.ordered,
    this.maxPacketLifeTime,
    this.maxRetransmits,
    this.priority,
    this.label,
    this.protocol,
  });

  factory SctpStreamParameters.fromJson(String json) {
    var map = jsonDecode(json);

    var sctpStream = SctpStreamParameters();
    if (map['streamId'] != null) sctpStream.streamId = map['streamId'];
    if (map['ordered'] != null) sctpStream.ordered = map['ordered'];
    if (map['maxPacketLifeTime'] != null) {
      sctpStream.maxPacketLifeTime = map['maxPacketLifeTime'];
    }
    if (map['maxRetransmits'] != null) {
      sctpStream.maxRetransmits = map['maxRetransmits'];
    }
    if (map['priority'] != null) {
      sctpStream.priority = jsonDecode(map['priority']);
    }
    if (map['label'] != null) sctpStream.label = map['label'];
    if (map['protocol'] != null) sctpStream.protocol = map['protocol'];

    return sctpStream;
  }

  String toJson() {
    var map = <String, dynamic>{};

    if (streamId != null) map['streamId'] = streamId;
    if (ordered != null) map['ordered'] = ordered;
    if (maxPacketLifeTime != null) map['maxPacketLifeTime'] = maxPacketLifeTime;
    if (maxRetransmits != null) map['maxRetransmits'] = maxRetransmits;
    if (priority != null) map['priority'] = jsonEncode(priority);
    if (label != null) map['label'] = label;
    if (protocol != null) map['protocol'] = protocol;

    return jsonEncode(map);
  }
}
