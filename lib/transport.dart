// ignore_for_file: slash_for_doc_comments

import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:json_annotation/json_annotation.dart';

import 'awaitqueue/awaitqueue.dart';
import 'consumer.dart';
import 'dataconsumer.dart';
import 'dataproducer.dart';
import 'enhancedeventemitter.dart';
import 'handlers/handlerinterface.dart';
import 'ortc.dart';
import 'producer.dart';
import 'rtpparameters.dart';
import 'sctpparameters.dart';
import 'utils.dart' as utils;
import 'ortc.dart' as ortc;

part 'transport.g.dart';

class InternalTransportOptions extends TransportOptions {
  String direction; //: 'send' | 'recv';
  Function? handlerFactory; //: HandlerFactory;
  ExtendedRtpCapabilities? extendedRtpCapabilities; //: any;
  CanProduceByKind? canProduceByKind; //: CanProduceByKind;

  @override
  String id; //: string;
  @override
  IceParameters iceParameters; //: IceParameters;
  @override
  List<IceCandidate> iceCandidates; //: IceCandidate[];
  @override
  DtlsParameters dtlsParameters; //: DtlsParameters;
  @override
  SctpParameters? sctpParameters;
  @override
  List<dynamic>? iceServers;

  InternalTransportOptions(
      this.id,
      this.iceParameters,
      this.iceCandidates,
      this.dtlsParameters,
      this.direction,
      this.handlerFactory,
      this.extendedRtpCapabilities,
      this.canProduceByKind,
      {this.sctpParameters,
      this.iceServers})
      : super(
          id,
          iceParameters,
          iceCandidates,
          dtlsParameters,
          sctpParameters: sctpParameters,
          iceServers: iceServers,
        );
}

class TransportOptions {
  String id; //: string;
  IceParameters iceParameters; //: IceParameters;
  List<IceCandidate> iceCandidates; //: IceCandidate[];
  DtlsParameters dtlsParameters; //: DtlsParameters;
  SctpParameters? sctpParameters; //?: SctpParameters;
  List<dynamic>? iceServers; //?: RTCIceServer[];
  String? iceTransportPolicy; //?: RTCIceTransportPolicy;
  Map<String, dynamic>? additionalSettings; //?: any;
  Map<String, dynamic>? proprietaryConstraints; //?: any;
  Map<String, dynamic>? appData; //?: any;

  TransportOptions(
    this.id,
    this.iceParameters,
    this.iceCandidates,
    this.dtlsParameters, {
    this.sctpParameters,
    this.iceServers,
    this.iceTransportPolicy,
    this.additionalSettings,
    this.proprietaryConstraints,
    this.appData,
  });
}

/// 定义服务器和客户端的生产能力
class CanProduceByKind {
  /// 是否能生产音频
  bool audio; //: boolean;
  /// 是否能生产视频
  bool video; //: boolean;
  // [key: string]: boolean;
  Map<String, bool>? keys;
  CanProduceByKind(this.audio, this.video) {
    keys ??= {};
    keys!['audio'] = audio;
    keys!['video'] = video;
  }
}

@JsonSerializable()
class IceParameters {
  /**
	 * ICE username fragment.
	 * */
  String usernameFragment; //: string;
  /**
	 * ICE password.
	 */
  String password; //: string;
  /**
	 * ICE Lite.
	 */
  bool? iceLite; //?: boolean;

  IceParameters(
    this.usernameFragment,
    this.password, {
    this.iceLite,
  });

  factory IceParameters.fromJson(Map<String, dynamic> json) =>
      _$IceParametersFromJson(json);

  Map<String, dynamic> toJson() => _$IceParametersToJson(this);
}

@JsonSerializable()
class IceCandidate {
  /**
	 * Unique identifier that allows ICE to correlate candidates that appear on
	 * multiple transports.
	 */
  String foundation; //: string;
  /**
	 * The assigned priority of the candidate.
	 */
  int priority; //: number;
  /**
	 * The IP address of the candidate.
	 */
  String ip; //: string;
  /**
	 * The protocol of the candidate.
	 */
  String protocol; //: 'udp' | 'tcp';
  /**
	 * The port for the candidate.
	 */
  int port; //: number;
  /**
	 * The type of candidate..
	 */
  String type; //: 'host' | 'srflx' | 'prflx' | 'relay';
  /**
	 * The type of TCP candidate.
	 */
  String? tcpType; //: 'active' | 'passive' | 'so';

  IceCandidate(
    this.foundation,
    this.priority,
    this.ip,
    this.protocol,
    this.port,
    this.type,
    this.tcpType,
  );

  factory IceCandidate.fromJson(Map<String, dynamic> json) =>
      _$IceCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$IceCandidateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DtlsParameters {
  /**
	 * DTLS role. Default 'auto'.
	 */
  String? role; //?: DtlsRole;
  /**
	 * DTLS fingerprints.
	 */
  List<DtlsFingerprint> fingerprints; //: DtlsFingerprint[];

  DtlsParameters(
    this.fingerprints, {
    this.role,
  });

  factory DtlsParameters.fromJson(Map<String, dynamic> json) =>
      _$DtlsParametersFromJson(json);

  Map<String, dynamic> toJson() => _$DtlsParametersToJson(this);
}

/**
 * The hash function algorithm (as defined in the "Hash function Textual Names"
 * registry initially specified in RFC 4572 Section 8) and its corresponding
 * certificate fingerprint value (in lowercase hex string as expressed utilizing
 * the syntax of "fingerprint" in RFC 4572 Section 5).
 */
@JsonSerializable()
class DtlsFingerprint {
  String algorithm; //: string;
  String value; //: string;

  DtlsFingerprint(
    this.algorithm,
    this.value,
  );

  factory DtlsFingerprint.fromJson(Map<String, dynamic> json) =>
      _$DtlsFingerprintFromJson(json);

  Map<String, dynamic> toJson() => _$DtlsFingerprintToJson(this);
}

// export type DtlsRole = 'auto' | 'client' | 'server';

// export type ConnectionState =
// 	| 'new'
// 	| 'connecting'
// 	| 'connected'
// 	| 'failed'
// 	| 'disconnected'
// 	| 'closed';
@JsonSerializable()
class PlainRtpParameters {
  String ip; //: string;
  int ipVersion; //: 4 | 6;
  int port; //: number;

  PlainRtpParameters(this.ip, this.ipVersion, this.port);

  factory PlainRtpParameters.fromJson(Map<String, dynamic> json) =>
      _$PlainRtpParametersFromJson(json);

  Map<String, dynamic> toJson() => _$PlainRtpParametersToJson(this);
}

// const logger = new Logger('Transport');

class Transport extends EnhancedEventEmitter {
  // Id.
  late String _id; //: string;
  // Closed flag.
  bool _closed = false;
  // Direction.
  late String _direction; //: 'send' | 'recv';
  // Extended RTP capabilities.
  dynamic _extendedRtpCapabilities; //: any;
  // Whether we can produce audio/video based on computed extended RTP
  // capabilities.
  late CanProduceByKind _canProduceByKind; //: CanProduceByKind;
  // SCTP max message size if enabled, null otherwise.
  int? _maxSctpMessageSize; //?: number | null;
  // RTC handler isntance.
  late HandlerInterface _handler; //: HandlerInterface;
  // Transport connection state.
  String _connectionState = 'new'; //: ConnectionState = 'new';
  // App custom data.
  Map<String, dynamic>? _appData; //: any;
  // Map of Producers indexed by id.
  final Map<String, Producer> _producers =
      {}; //: Map<string, Producer> = new Map();
  // Map of Consumers indexed by id.
  final Map<String, Consumer> _consumers = {};
  // Map of DataProducers indexed by id.
  final Map<String, DataProducer> _dataProducers = {};
  // Map of DataConsumers indexed by id.
  final Map<String, DataConsumer> _dataConsumers = {};
  // Whether the Consumer for RTP probation has been created.
  bool _probatorConsumerCreated = false;
  // AwaitQueue instance to make async tasks happen sequentially.
  final _awaitQueue = AwaitQueue(/*{ ClosedErrorClass: InvalidStateError }*/);
  // Observer instance.
  // protected readonly _observer = new EnhancedEventEmitter();
  final _observer = EnhancedEventEmitter();

  /**
	 * @emits connect - (transportLocalParameters: any, callback: Function, errback: Function)
	 * @emits connectionstatechange - (connectionState: ConnectionState)
	 * @emits produce - (producerLocalParameters: any, callback: Function, errback: Function)
	 * @emits producedata - (dataProducerLocalParameters: any, callback: Function, errback: Function)
	 */
  Transport(InternalTransportOptions options
      // {
      // 	direction,
      // 	id,
      // 	iceParameters,
      // 	iceCandidates,
      // 	dtlsParameters,
      // 	sctpParameters,
      // 	iceServers,
      // 	iceTransportPolicy,
      // 	additionalSettings,
      // 	proprietaryConstraints,
      // 	appData,
      // 	handlerFactory,
      // 	extendedRtpCapabilities,
      // 	canProduceByKind
      // }: InternalTransportOptions
      )
      : super() {
    // super();

    debugger(
        when: false,
        message:
            'constructor() [id:${options.id}, direction:${options.direction}]');

    _id = options.id;
    _direction = options.direction;
    _extendedRtpCapabilities = options.extendedRtpCapabilities;
    _canProduceByKind = options.canProduceByKind!;
    _maxSctpMessageSize = options.sctpParameters != null
        ? options.sctpParameters!.maxMessageSize
        : null;

    // Clone and sanitize additionalSettings.
    options.additionalSettings = utils.clone(options.additionalSettings, {});
    options.additionalSettings!.remove('iceServers');
    options.additionalSettings!.remove('iceTransportPolicy');
    options.additionalSettings!.remove('bundlePolicy');
    options.additionalSettings!.remove('rtcpMuxPolicy');
    options.additionalSettings!.remove('sdpSemantics');
    // delete additionalSettings.iceServers;
    // delete additionalSettings.iceTransportPolicy;
    // delete additionalSettings.bundlePolicy;
    // delete additionalSettings.rtcpMuxPolicy;
    // delete additionalSettings.sdpSemantics;

    _handler = options.handlerFactory!();

    _handler.run(HandlerRunOptions(
            options.direction,
            options.iceParameters,
            options.iceCandidates,
            options.dtlsParameters,
            options.extendedRtpCapabilities,
            sctpParameters: options.sctpParameters,
            iceServers: options.iceServers,
            iceTransportPolicy: options.iceTransportPolicy,
            additionalSettings: options.additionalSettings,
            proprietaryConstraints: options.proprietaryConstraints)
        // {
        // 	options.direction,
        // 	options.iceParameters,
        // 	options.iceCandidates,
        // 	dtlsParameters,
        // 	sctpParameters,
        // 	iceServers,
        // 	iceTransportPolicy,
        // 	additionalSettings,
        // 	proprietaryConstraints,
        // 	extendedRtpCapabilities
        // }
        );

    _appData = options.appData;

    _handleHandler();
  }

  /**
	 * Transport id.
	 */
  String get id //: string
  {
    return _id;
  }

  /**
	 * Whether the Transport is closed.
	 */
  bool get closed //(): boolean
  {
    return _closed;
  }

  /**
	 * Transport direction.
	 */
  String get direction //(): 'send' | 'recv'
  {
    return _direction;
  }

  /**
	 * RTC handler instance.
	 */
  HandlerInterface get handler //(): HandlerInterface
  {
    return _handler;
  }

  /**
	 * Connection state.
	 */
  String get connectionState //(): ConnectionState
  {
    return _connectionState;
  }

  /**
	 * App custom data.
	 */
  dynamic get appData //(): any
  {
    return _appData;
  }

  /**
	 * Invalid setter.
	 */
  set appData(dynamic appData) // eslint-disable-line no-unused-vars
  {
    // throw new Error('cannot override appData object');
    throw Exception('cannot override appData object');
  }

  /**
	 * Observer.
	 *
	 * @emits close
	 * @emits newproducer - (producer: Producer)
	 * @emits newconsumer - (producer: Producer)
	 * @emits newdataproducer - (dataProducer: DataProducer)
	 * @emits newdataconsumer - (dataProducer: DataProducer)
	 */
  EnhancedEventEmitter get observer //(): EnhancedEventEmitter
  {
    return _observer;
  }

  /**
	 * Close the Transport.
	 */
  void close() //: void
  {
    if (_closed) return;

    debugger(when: false, message: 'close()');

    _closed = true;

    // Close the AwaitQueue.
    _awaitQueue.close();

    // Close the handler.
    _handler.close();

    // Close all Producers.
    for (var producer in _producers.values) {
      producer.transportClosed();
    }
    _producers.clear();

    // Close all Consumers.
    for (var consumer in _consumers.values) {
      consumer.transportClosed();
    }
    _consumers.clear();

    // Close all DataProducers.
    for (var dataProducer in _dataProducers.values) {
      dataProducer.transportClosed();
    }
    _dataProducers.clear();

    // Close all DataConsumers.
    for (var dataConsumer in _dataConsumers.values) {
      dataConsumer.transportClosed();
    }
    _dataConsumers.clear();

    // Emit observer event.
    // this._observer.safeEmit('close');
    _observer.emit('close');
  }

  /**
	 * Get associated Transport (RTCPeerConnection) stats.
	 *
	 * @returns {RTCStatsReport}
	 */
  Future<List<StatsReport>> getStats() async //: Promise<RTCStatsReport>
  {
    if (_closed) {
      throw Exception('closed');
    }

    return _handler.getTransportStats();
  }

  /**
	 * Restart ICE connection.
	 */
  Future<void> restartIce({IceParameters? iceParameters} //:
      // { iceParameters: IceParameters }
      ) async //: Promise<void>
  {
    debugger(when: false, message: 'restartIce()');

    if (_closed) {
      throw Exception('closed');
    } else if (iceParameters != null) {
      throw Exception('missing iceParameters');
    }

    // Enqueue command.
    return _awaitQueue.push(() async => _handler.restartIce(iceParameters!),
        'transport.restartIce()');
    // return Future(() async => _handler.restartIce(iceParameters!));
  }

  /**
	 * Update ICE servers.
	 */
  Future<void> updateIceServers({List<dynamic>? iceServers} //:
      // { iceServers?: RTCIceServer[] } = {}
      ) async //: Promise<void>
  {
    debugger(when: false, message: 'updateIceServers()');

    if (_closed) throw Exception('closed');
    // else if (!Array.isArray(iceServers))
    // 	throw new Exception('missing iceServers');

    // Enqueue command.
    return _awaitQueue.push(() async => _handler.updateIceServers(iceServers!),
        'transport.updateIceServers()');
    // return Future(() async => _handler.updateIceServers(iceServers!));
  }

  /**
	 * Create a Producer.
	 */
  Future<Producer> produce(ProducerOptions options
      // {
      // 	track,
      // 	encodings,
      // 	codecOptions,
      // 	codec,
      // 	stopTracks = true,
      // 	disableTrackOnPause = true,
      // 	zeroRtpOnPause = false,
      // 	appData = null
      // }//: ProducerOptions = {}
      ) async //: Promise<Producer>
  {
    debugger(when: false, message: 'produce() [track:${options.track}]');

    if (options.track == null) {
      throw Exception('missing track');
    } else if (_direction != 'send') {
      throw UnsupportedError('not a sending Transport');
    } else if (!_canProduceByKind.keys![options.track!.kind]!) {
      throw UnsupportedError('cannot produce ${options.track!.kind}');
      // }
      //  else if (options.track.readyState == 'ended') {
      //   throw Exception('track ended');
    } else if (listenerCount('connect') == 0 && _connectionState == 'new') {
      throw Exception('no "connect" listener set into this transport');
    } else if (listenerCount('produce') == 0) {
      throw Exception('no "produce" listener set into this transport');
    }
    // else if (options.appData /*&& typeof appData !== 'object'*/)
    // 	throw new Exception('if given, appData must be an object');
    print('这儿来了么？');
    // Enqueue command.
    return this._awaitQueue.push(() async {
      dynamic normalizedEncodings;

      // if (options.encodings && !Array.isArray(encodings))
      // {
      // 	throw TypeError('encodings must be an array');
      // }
      // else
      if (options.encodings != null && options.encodings!.isEmpty) {
        // normalizedEncodings = undefined;
        normalizedEncodings = null;
      } else if (options.encodings != null) {
        normalizedEncodings = options.encodings!.map((encoding) {
          var normalizedEncoding = RtpEncodingParameters();
          normalizedEncoding.active = true;

          if (encoding.active == false) normalizedEncoding.active = false;
          if (encoding.dtx is bool) normalizedEncoding.dtx = encoding.dtx;
          if (encoding.scalabilityMode is String) {
            normalizedEncoding.scalabilityMode = encoding.scalabilityMode;
          }
          if (encoding.scaleResolutionDownBy is int) {
            normalizedEncoding.scaleResolutionDownBy =
                encoding.scaleResolutionDownBy;
          }
          if (encoding.maxBitrate is int) {
            normalizedEncoding.maxBitrate = encoding.maxBitrate;
          }
          if (encoding.maxFramerate is int) {
            normalizedEncoding.maxFramerate = encoding.maxFramerate;
          }
          if (encoding.adaptivePtime is bool) {
            normalizedEncoding.adaptivePtime = encoding.adaptivePtime;
          }
          if (encoding.priority is String) {
            normalizedEncoding.priority = encoding.priority;
          }
          if (encoding.networkPriority is String) {
            normalizedEncoding.networkPriority = encoding.networkPriority;
          }

          return normalizedEncoding;
        });
      }

      var result = await _handler.send(HandlerSendOptions(
        options.track!,
        encodings: normalizedEncodings,
        codecOptions: options.codecOptions,
        codec: options.codec,
        stream: options.stream,
      ));
// const { localId, rtpParameters, rtpSender }
      var localId = result.localId;
      var rtpParameters = result.rtpParameters;
      var rtpSender = result.rtpSender;

      try {
        // This will fill rtpParameters's missing fields with default values.
        ortc.validateRtpParameters(rtpParameters);

        // const { id }
        var args = Map<String, dynamic>();
        args['kind'] = options.track!.kind;
        args['rtpParameters'] = rtpParameters;
        args['appData'] = options.appData;
        print('生产数据了吗？');
        dynamic safePromise = await safeEmitAsPromise('produce', [args]
            // {
            // 	kind : track.kind,
            // 	rtpParameters,
            // 	appData
            // }
            );
        var id = safePromise.id;

        var producer = Producer(
            id,
            localId,
            rtpSender,
            options.track,
            rtpParameters,
            options.stopTracks!,
            options.disableTrackOnPause!,
            options.zeroRtpOnPause!,
            options.appData);

        // this._producers.set(producer.id, producer);
        _producers[producer.id] = producer;
        _handleProducer(producer);

        // Emit observer event.
        _observer.safeEmit('newproducer', [producer]);

        return producer;
      } catch (error) {
        _handler.stopSending(localId).catchError((_) => {});

        throw error;
      }
    }, 'transport.produce()')
        // This catch is needed to stop the given track if the command above
        // failed due to closed Transport.
        .catchError((error) {
      if (options.stopTracks != null) {
        try {
          options.track!.stop();
        } catch (error2) {}
      }

      throw Exception(error);
    });
  }

  /**
	 * Create a Consumer to consume a remote Producer.
	 */
  Future<Consumer> consume(ConsumerOptions options
      // {
      // 	id,
      // 	producerId,
      // 	kind,
      // 	rtpParameters,
      // 	appData = {}
      // }: ConsumerOptions
      ) async //: Promise<Consumer>
  {
    debugger(when: false, message: 'consume()');

    // options.rtpParameters = utils.clone(options.rtpParameters, null);
    options.rtpParameters =
        RtpParameters.fromJson(options.rtpParameters.toJson());

    if (_closed) {
      throw Exception('closed');
    } else if (_direction != 'recv') {
      throw UnsupportedError('not a receiving Transport');
    } else if (options.kind != 'audio' && options.kind != 'video') {
      throw Exception('invalid kind ${options.kind}');
    } else if (listenerCount('connect') == 0 && _connectionState == 'new') {
      throw Exception('no "connect" listener set into this transport');
    }
    // else if (appData /*&& typeof appData !== 'object'*/)
    // 	throw new Exception('if given, appData must be an object');

    // Enqueue command.
    return _awaitQueue.push(() async {
      // Ensure the device can consume it.
      var canConsume =
          ortc.canReceive(options.rtpParameters, _extendedRtpCapabilities);

      if (!canConsume) {
        throw UnsupportedError('cannot consume this Producer');
      }

      // const { localId, rtpReceiver, track }
      var result = await _handler.receive(HandlerReceiveOptions(
        options.id!,
        options.kind!,
        options.rtpParameters,
      ));
      var localId = result.localId;
      var rtpReceiver = result.rtpReceiver;
      var track = result.track;
      var stream = result.stream;

      var consumer = Consumer(options.id!, localId, options.producerId!, track,
          stream, options.rtpParameters, options.appData,
          rtpReceiver: rtpReceiver);

      // this._consumers.set(consumer.id, consumer);
      _consumers[consumer.id] = consumer;
      _handleConsumer(consumer);

      // If this is the first video Consumer and the Consumer for RTP probation
      // has not yet been created, create it now.
      if (!_probatorConsumerCreated && options.kind == 'video') {
        try {
          var probatorRtpParameters =
              ortc.generateProbatorRtpParameters(consumer.rtpParameters);

          await _handler.receive(HandlerReceiveOptions(
              'probator', 'video', probatorRtpParameters));

          debugger(
              when: false,
              message: 'consume() | Consumer for RTP probation created');

          _probatorConsumerCreated = true;
        } catch (error) {
          debugger(
              when: false,
              message:
                  'consume() | failed to create Consumer for RTP probation:$error');
        }
      }

      // Emit observer event.
      _observer.safeEmit('newconsumer', [consumer]);

      return consumer;
    }, 'transport.consume()');
  }

  /**
	 * Create a DataProducer
	 */
  Future<DataProducer> produceData(DataProducerOptions options
      // {
      // 	ordered = true,
      // 	maxPacketLifeTime,
      // 	maxRetransmits,
      // 	priority = 'low',
      // 	label = '',
      // 	protocol = '',
      // 	appData = {}
      // }//: DataProducerOptions = {}
      ) async //: Promise<DataProducer>
  {
    debugger(when: false, message: 'produceData()');

    if (_direction != 'send') {
      throw UnsupportedError('not a sending Transport');
    } else if (_maxSctpMessageSize == null || _maxSctpMessageSize == 0) {
      throw UnsupportedError('SCTP not enabled by remote Transport');
    } else if (!['very-low', 'low', 'medium', 'high']
        .contains(options.priority)) {
      throw Exception('wrong priority');
    } else if (listenerCount('connect') == 0 && _connectionState == 'new') {
      throw Exception('no "connect" listener set into this transport');
    } else if (listenerCount('producedata') == 0) {
      throw Exception('no "producedata" listener set into this transport');
    }
    // else if (appData && typeof appData !== 'object')
    // 	throw new TypeError('if given, appData must be an object');

    if (options.maxPacketLifeTime == null || options.maxRetransmits == null) {
      options.ordered = false;
    }

    // Enqueue command.
    return _awaitQueue.push(() async {
      // const {
      // 	dataChannel,
      // 	sctpStreamParameters
      // }
      var result = await _handler.sendDataChannel(HandlerSendDataChannelOptions(
        ordered: options.ordered,
        maxPacketLifeTime: options.maxPacketLifeTime,
        maxRetransmits: options.maxRetransmits,
        priority: options.priority,
        label: options.label,
        protocol: options.protocol,
      )
          // {
          // 	ordered,
          // 	maxPacketLifeTime,
          // 	maxRetransmits,
          // 	priority,
          // 	label,
          // 	protocol
          // }
          );
      var dataChannel = result.dataChannel;
      var sctpStreamParameters = result.sctpStreamParameters;

      // This will fill sctpStreamParameters's missing fields with default values.
      ortc.validateSctpStreamParameters(sctpStreamParameters);

      // const { id }
      dynamic p1 = Object();
      p1.sctpStreamParameters = sctpStreamParameters;
      p1.label = options.label;
      p1.protocol = options.protocol;
      p1.appData = options.appData;
      var ident = await safeEmitAsPromise('producedata', [p1]);
      var id = ident.id;

      var dataProducer =
          DataProducer(id, dataChannel, sctpStreamParameters, options.appData);

      // this._dataProducers.set(dataProducer.id, dataProducer);
      _dataProducers[dataProducer.id] = dataProducer;
      _handleDataProducer(dataProducer);

      // Emit observer event.
      _observer.safeEmit('newdataproducer', [dataProducer]);

      return dataProducer;
    }, 'transport.produceData()');
  }

  /**
	 * Create a DataConsumer
	 */
  Future<DataConsumer> consumeData(DataConsumerOptions options
      // {
      // 	id,
      // 	dataProducerId,
      // 	sctpStreamParameters,
      // 	label = '',
      // 	protocol = '',
      // 	appData = {}
      // }//: DataConsumerOptions
      ) async //: Promise<DataConsumer>
  {
    debugger(when: false, message: 'consumeData()');

    // options.sctpStreamParameters =
    //     utils.clone(options.sctpStreamParameters, null);
    options.sctpStreamParameters =
        SctpStreamParameters.fromJson(options.sctpStreamParameters.toJson());

    if (_closed) {
      throw Exception('closed');
    } else if (_direction != 'recv') {
      throw UnsupportedError('not a receiving Transport');
    } else if (_maxSctpMessageSize == null || _maxSctpMessageSize == 0) {
      throw UnsupportedError('SCTP not enabled by remote Transport');
    } else if (listenerCount('connect') == 0 && _connectionState == 'new') {
      throw Exception('no "connect" listener set into this transport');
    }
    // else if (appData && typeof appData !== 'object')
    // 	throw new TypeError('if given, appData must be an object');

    // This may throw.
    ortc.validateSctpStreamParameters(options.sctpStreamParameters);

    // Enqueue command.
    return _awaitQueue.push(() async {
      // const {
      // 	dataChannel
      // }
      var r1 = await _handler.receiveDataChannel(
          HandlerReceiveDataChannelOptions(options.sctpStreamParameters,
              label: options.label, protocol: options.protocol));

      var dataConsumer = DataConsumer(options.id!, options.dataProducerId!,
          r1.dataChannel, options.sctpStreamParameters, options.appData);

      // this._dataConsumers.set(dataConsumer.id, dataConsumer);
      _dataConsumers[dataConsumer.id] = dataConsumer;
      _handleDataConsumer(dataConsumer);

      // Emit observer event.
      _observer.safeEmit('newdataconsumer', [dataConsumer]);

      return dataConsumer;
    }, 'transport.consumeData()');
  }

  void _handleHandler() //: void
  {
    var handler = _handler;

    void fun(
        params, //{ DtlsParameters dtlsParameters },//: { dtlsParameters: DtlsParameters },
        Function callback, //: Function,
        Function errback //: Function
        ) {
      if (_closed) {
        errback(Exception('closed'));

        return;
      }

      safeEmit('connect', [params, callback, errback]);
    }

    handler.on('@connect', fun);

    handler.on('@connectionstatechange', (String connectionState) {
      if (connectionState == _connectionState) return;

      debugger(
          when: false, message: 'connection state changed to $connectionState');

      _connectionState = connectionState;

      if (!_closed) safeEmit('connectionstatechange', [connectionState]);
    });
  }

  void _handleProducer(Producer producer) //: void
  {
    producer.on('@close', () {
      _producers.remove(producer.id);

      if (_closed) return;

      _awaitQueue
          .push(() async => _handler.stopSending(producer.localId),
              'producer @close event')
          .catchError((error) =>
              debugger(when: false, message: 'producer.close() failed:$error'));
    });

    producer.on('@replacetrack', (track, callback, errback) {
      _awaitQueue
          .push(
              () async => _handler.replaceTrack(producer.localId, track: track),
              'producer @replacetrack event')
          .then(callback)
          .catchError(errback);
    });

    producer.on('@setmaxspatiallayer', (spatialLayer, callback, errback) {
      _awaitQueue
          .push(
              () async =>
                  (_handler.setMaxSpatialLayer(producer.localId, spatialLayer)),
              'producer @setmaxspatiallayer event')
          .then(callback)
          .catchError(errback);
    });

    producer.on('@setrtpencodingparameters', (params, callback, errback) {
      _awaitQueue
          .push(
              () async =>
                  (_handler.setRtpEncodingParameters(producer.localId, params)),
              'producer @setrtpencodingparameters event')
          .then(callback)
          .catchError(errback);
    });

    producer.on('@getstats', (callback, errback) {
      if (_closed) return errback(Exception('closed'));

      _handler
          .getSenderStats(producer.localId)
          .then(callback)
          .catchError(errback);
    });
  }

  void _handleConsumer(Consumer consumer) //: void
  {
    consumer.on('@close', () {
      _consumers.remove(consumer.id);

      if (_closed) return;

      _awaitQueue
          .push(() async => _handler.stopReceiving(consumer.localId),
              'consumer @close event')
          .catchError((_) => {});
    });

    consumer.on('@getstats', (callback, errback) {
      if (_closed) return errback(Exception('closed'));

      _handler
          .getReceiverStats(consumer.localId)
          .then(callback)
          .catchError(errback);
    });
  }

  void _handleDataProducer(DataProducer dataProducer) //: void
  {
    dataProducer.on('@close', () {
      _dataProducers.remove(dataProducer.id);
    });
  }

  void _handleDataConsumer(DataConsumer dataConsumer) //: void
  {
    dataConsumer.on('@close', () {
      _dataConsumers.remove(dataConsumer.id);
    });
  }
}
