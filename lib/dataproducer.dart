import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'enhancedeventemitter.dart';
import 'sctpparameters.dart';

class DataProducerOptions {
  bool? ordered; //?: boolean;
  int? maxPacketLifeTime; //?: number;
  int? maxRetransmits; //?: number;
  String? priority; //?: RTCPriorityType;
  String? label; //?: string;
  String? protocol; //?: string;
  var appData; //?: any;

  DataProducerOptions(
      {this.ordered,
      this.maxPacketLifeTime,
      this.maxRetransmits,
      this.priority,
      this.label,
      this.protocol,
      this.appData});
}

// const logger = new Logger('DataProducer');
/// 数据生产者
class DataProducer extends EnhancedEventEmitter {
  // Id.
  late String _id; //: string;
  // The underlying RTCDataChannel instance.
  late RTCDataChannel _dataChannel; //: RTCDataChannel;
  // Closed flag.
  bool _closed = false;
  // SCTP stream parameters.
  late SctpStreamParameters _sctpStreamParameters; //: SctpStreamParameters;
  // App custom data.
  var _appData; //: any;
  // Observer instance.
  var _observer = EnhancedEventEmitter();

  /**
	 * @emits transportclose
	 * @emits open
	 * @emits error - (error: Error)
	 * @emits close
	 * @emits bufferedamountlow
	 * @emits @close
	 */
  DataProducer(
      // {
      String id,
      RTCDataChannel dataChannel,
      SctpStreamParameters sctpStreamParameters,
      appData
      // }:
      // {
      // 	id: string;
      // 	dataChannel: RTCDataChannel;
      // 	sctpStreamParameters: SctpStreamParameters;
      // 	appData: any;
      // }
      )
      : super() {
    // super();

    debugger(when: false, message: 'constructor()');

    this._id = id;
    this._dataChannel = dataChannel;
    this._sctpStreamParameters = sctpStreamParameters;
    this._appData = appData;

    this._handleDataChannel();
  }

  /**
	 * DataProducer id.
	 */
  String get id //(): string
  {
    return this._id;
  }

  /**
	 * Whether the DataProducer is closed.
	 */
  bool get closed //(): boolean
  {
    return this._closed;
  }

  /**
	 * SCTP stream parameters.
	 */
  SctpStreamParameters get sctpStreamParameters //(): SctpStreamParameters
  {
    return this._sctpStreamParameters;
  }

  /**
	 * DataChannel readyState.
	 */
  RTCDataChannelState get readyState //(): RTCDataChannelState
  {
    dynamic channel = this._dataChannel;
    return channel.readyState;
  }

  /**
	 * DataChannel label.
	 */
  String get label //(): string
  {
    dynamic channel = this._dataChannel;
    return channel.label;
  }

  /**
	 * DataChannel protocol.
	 */
  String get protocol //(): string
  {
    dynamic channel = this._dataChannel;
    return channel.protocol;
  }

  /**
	 * DataChannel bufferedAmount.
	 */
  int get bufferedAmount //(): number
  {
    dynamic channel = this._dataChannel;
    return channel.bufferedAmount;
  }

  /**
	 * DataChannel bufferedAmountLowThreshold.
	 */
  int get bufferedAmountLowThreshold //(): number
  {
    dynamic channel = this._dataChannel;
    return channel.bufferedAmountLowThreshold;
  }

  /**
	 * Set DataChannel bufferedAmountLowThreshold.
	 */
  set bufferedAmountLowThreshold(int bufferedAmountLowThreshold) {
    dynamic channel = this._dataChannel;
    channel.bufferedAmountLowThreshold = bufferedAmountLowThreshold;
  }

  /**
	 * App custom data.
	 */
  get appData //(): any
  {
    return this._appData;
  }

  /**
	 * Invalid setter.
	 */
  set appData(appData) // eslint-disable-line no-unused-vars
  {
    throw new Exception('cannot override appData object');
  }

  /**
	 * Observer.
	 *
	 * @emits close
	 */
  EnhancedEventEmitter get observer //(): EnhancedEventEmitter
  {
    return this._observer;
  }

  /**
	 * Closes the DataProducer.
	 */
  void close() //: void
  {
    if (this._closed) return;

    debugger(when: false, message: 'close()');

    this._closed = true;

    this._dataChannel.close();

    this.emit('@close');

    // Emit observer event.
    this._observer.safeEmit('close');
  }

  /**
	 * Transport was closed.
	 */
  void transportClosed() //: void
  {
    if (this._closed) return;

    debugger(when: false, message: 'transportClosed()');

    this._closed = true;

    this._dataChannel.close();

    this.safeEmit('transportclose');

    // Emit observer event.
    this._observer.safeEmit('close');
  }

  /**
	 * Send a message.
	 *
	 * @param {String|Blob|ArrayBuffer|ArrayBufferView} data.
	 */
  void send(data) //: void
  {
    debugger(when: false, message: 'send()');

    if (this._closed) throw new Exception('closed');

    this._dataChannel.send(data);
  }

  void _handleDataChannel() //: void
  {
    // this._dataChannel.addEventListener('open', () =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	debugger(when: false,message:'DataChannel "open" event');

    // 	this.safeEmit('open');
    // });

    this._dataChannel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        if (this._closed) return;

        debugger(when: false, message: 'DataChannel "open" event');

        this.safeEmit('open');
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        if (this._closed) return;

        debugger(when: false, message: 'DataChannel "close" event');

        this._closed = true;

        this.emit('@close');
        this.safeEmit('close');
      }
    };

    // this._dataChannel.addEventListener('error', (event)
    // {
    // 	if (this._closed)
    // 		return;

    // 	let { error } = event;

    // 	if (!error)
    // 		error = new Error('unknown DataChannel error');

    // 	if (error.errorDetail === 'sctp-failure')
    // 	{
    // 		logger.error(
    // 			'DataChannel SCTP error [sctpCauseCode:%s]: %s',
    // 			error.sctpCauseCode, error.message);
    // 	}
    // 	else
    // 	{
    // 		debugger(message:'DataChannel "error" event: $error');
    // 	}

    // 	this.safeEmit('error', [error]);
    // });

    // this._dataChannel.addEventListener('close', () =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	debugger(message:'DataChannel "close" event');

    // 	this._closed = true;

    // 	this.emit('@close');
    // 	this.safeEmit('close');
    // });

    // this._dataChannel.addEventListener('message', () =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	debugger(message:
    // 		'DataChannel "message" event in a DataProducer, message discarded');
    // });

    // this._dataChannel.addEventListener('bufferedamountlow', () =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	this.safeEmit('bufferedamountlow');
    // });
    this._dataChannel.onMessage = (event) {
      if (this._closed) return;
      debugger(
          when: false,
          message:
              'DataChannel "message" event in a DataProducer, message discarded');
    };
  }
}
