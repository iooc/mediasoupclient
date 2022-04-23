import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../enhancedeventemitter.dart';
import '../ortc.dart';
import '../producer.dart';
import '../rtpparameters.dart';
import '../sctpparameters.dart';
import '../transport.dart';

Function HandlerFactory = () => HandlerInterface;

class HandlerRunOptions {
  String direction; //: 'send' | 'recv';
  IceParameters iceParameters; //: IceParameters;
  List<IceCandidate> iceCandidates; //: IceCandidate[];
  DtlsParameters dtlsParameters; //: DtlsParameters;
  SctpParameters? sctpParameters; //?: SctpParameters;
  List<dynamic>? iceServers; //?: RTCIceServer[];
  String? iceTransportPolicy; //?: RTCIceTransportPolicy;
  Map<String, dynamic>? additionalSettings; //?: any;
  dynamic proprietaryConstraints; //?: any;
  ExtendedRtpCapabilities? extendedRtpCapabilities; //: any;

  HandlerRunOptions(
    this.direction,
    this.iceParameters,
    this.iceCandidates,
    this.dtlsParameters,
    this.extendedRtpCapabilities, {
    this.sctpParameters,
    this.iceServers,
    this.iceTransportPolicy,
    this.additionalSettings,
    this.proprietaryConstraints,
  });
}

class HandlerSendOptions {
  MediaStreamTrack track; //: MediaStreamTrack;
  List<RtpEncodingParameters>? encodings; //?: RtpEncodingParameters[];
  ProducerCodecOptions? codecOptions; //?: ProducerCodecOptions;
  RtpCodecCapability? codec; //?: RtpCodecCapability;
  MediaStream? stream;

  HandlerSendOptions(
    this.track, {
    this.encodings,
    this.codecOptions,
    this.codec,
    required this.stream,
  });
}

class HandlerSendResult {
  String localId; //: string;
  RtpParameters rtpParameters; //: RtpParameters;
  RTCRtpSender? rtpSender; //?: RTCRtpSender;

  HandlerSendResult(
    this.localId,
    this.rtpParameters, {
    this.rtpSender,
  });
}

class HandlerReceiveOptions {
  String trackId; //: string;
  String kind; //: 'audio' | 'video';
  RtpParameters rtpParameters; //: RtpParameters;

  HandlerReceiveOptions(
    this.trackId,
    this.kind,
    this.rtpParameters,
  );
}

/// 接收结果处理
class HandlerReceiveResult {
  String localId; //: string;
  MediaStreamTrack track; //: MediaStreamTrack;
  RTCRtpReceiver? rtpReceiver; //?: RTCRtpReceiver;
  MediaStream stream;

  HandlerReceiveResult(
    this.localId,
    this.track,
    this.stream, {
    this.rtpReceiver,
  });
}

class HandlerSendDataChannelOptions extends SctpStreamParameters {
  HandlerSendDataChannelOptions({
    this.streamId,
    this.ordered,
    this.maxPacketLifeTime,
    this.maxRetransmits,
    this.priority,
    this.label,
    this.protocol,
  }) : super(
          streamId: streamId,
          label: label,
          maxPacketLifeTime: maxPacketLifeTime,
          maxRetransmits: maxRetransmits,
          ordered: ordered,
          priority: priority,
          protocol: protocol,
        );

  @override
  String? label;

  @override
  int? maxPacketLifeTime;

  @override
  int? maxRetransmits;

  @override
  bool? ordered;

  @override
  var priority;

  @override
  String? protocol;

  @override
  int? streamId;
}

class HandlerSendDataChannelResult {
  RTCDataChannel dataChannel; //: RTCDataChannel;
  SctpStreamParameters sctpStreamParameters; //: SctpStreamParameters;

  HandlerSendDataChannelResult(
    this.dataChannel,
    this.sctpStreamParameters,
  );
}

class HandlerReceiveDataChannelOptions {
  SctpStreamParameters sctpStreamParameters; //: SctpStreamParameters;
  String? label; //?: string;
  String? protocol; //?: string;

  HandlerReceiveDataChannelOptions(
    this.sctpStreamParameters, {
    this.label,
    this.protocol,
  });
}

class HandlerReceiveDataChannelResult {
  RTCDataChannel dataChannel; //: RTCDataChannel;
  HandlerReceiveDataChannelResult(this.dataChannel);
}

abstract class HandlerInterface extends EnhancedEventEmitter {
  /**
	 * @emits @connect - (
	 *     { dtlsParameters: DtlsParameters },
	 *     callback: Function,
	 *     errback: Function
	 *   )
	 * @emits @connectionstatechange - (connectionState: ConnectionState)
	 */
  HandlerInterface() : super();
  // {
  // 	super();
  // }

  String get name; //: string;

  void close(); //: void;

  Future<RtpCapabilities>
      getNativeRtpCapabilities(); //: Promise<RtpCapabilities>;

  Future<SctpCapabilities>
      getNativeSctpCapabilities(); //: Promise<SctpCapabilities>;

  void run(HandlerRunOptions options); //: void;

  Future<void> updateIceServers(
      List<dynamic /*RTCIceServer*/ > iceServers); //: Promise<void>;

  Future<void> restartIce(IceParameters iceParameters); //: Promise<void>;

  Future<List<StatsReport>> getTransportStats(); //: Promise<RTCStatsReport>;

  Future<HandlerSendResult> send(
      HandlerSendOptions options); //: Promise<HandlerSendResult>;

  Future<void> stopSending(String localId); //: Promise<void>;

  Future<void> replaceTrack(String localId,
      {MediaStreamTrack track}); //: Promise<void>;

  Future<void> setMaxSpatialLayer(
    String localId,
    int spatialLayer, //: number
  ); //: Promise<void>;

  Future<void> setRtpEncodingParameters(
      String localId, dynamic params); //: Promise<void>;

  Future<List<StatsReport>> getSenderStats(
      String localId); //: Promise<RTCStatsReport>;

  Future<HandlerSendDataChannelResult> sendDataChannel(
      HandlerSendDataChannelOptions options //: HandlerSendDataChannelOptions
      ); //: Promise<HandlerSendDataChannelResult>;

  Future<HandlerReceiveResult> receive(
      HandlerReceiveOptions options //: HandlerReceiveOptions
      ); //: Promise<HandlerReceiveResult>;

  Future<void> stopReceiving(String localId); //: Promise<void>;

  Future<List<StatsReport>> getReceiverStats(
      String localId); //: Promise<RTCStatsReport>;

  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
      HandlerReceiveDataChannelOptions
          options //: HandlerReceiveDataChannelOptions
      ); //: Promise<HandlerReceiveDataChannelResult>;
}
