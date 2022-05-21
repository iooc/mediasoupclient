import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'enhancedeventemitter.dart';
import 'sctpparameters.dart';

class DataConsumerOptions {
  String? id; //?: string;
  String? dataProducerId; //?: string;
  SctpStreamParameters sctpStreamParameters; //: SctpStreamParameters;
  String? label; //?: string;
  String? protocol; //?: string;
  var appData; //?: any;

  DataConsumerOptions(
    this.sctpStreamParameters, {
    this.id,
    this.dataProducerId,
    this.label,
    this.protocol,
    this.appData,
  });
}

// const logger = new Logger('DataConsumer');
/// 多媒体消费者
class DataConsumer extends EnhancedEventEmitter {
  // Id.
  late String _id; //: string;
  // Associated DataProducer Id.
  late String _dataProducerId; //: string;
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
	 * @emits message - (message: any)
	 * @emits @close
	 */
  DataConsumer(
      // {
      String id,
      String dataProducerId,
      RTCDataChannel dataChannel,
      SctpStreamParameters sctpStreamParameters,
      appData
      //}:
      // {
      // 	id: string;
      // 	dataProducerId: string;
      // 	dataChannel: RTCDataChannel;
      // 	sctpStreamParameters: SctpStreamParameters;
      // 	appData: any;
      // }
      )
      : super() {
    // super();

    debugger(when: false, message: 'constructor()');

    this._id = id;
    this._dataProducerId = dataProducerId;
    this._dataChannel = dataChannel;
    this._sctpStreamParameters = sctpStreamParameters;
    this._appData = appData;

    this._handleDataChannel();
  }

  /**
	 * DataConsumer id.
	 */
  String get id //(): string
  {
    return this._id;
  }

  /**
	 * Associated DataProducer id.
	 */
  String get dataProducerId //(): string
  {
    return this._dataProducerId;
  }

  /**
	 * Whether the DataConsumer is closed.
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
	 * DataChannel binaryType.
	 */
  String get binaryType //(): string
  {
    dynamic channel = this._dataChannel;
    return channel.binaryType;
  }

  /**
	 * Set DataChannel binaryType.
	 */
  set binaryType(String binaryType) {
    dynamic channel = this._dataChannel;
    channel.binaryType = binaryType;
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
  set appData(appData) // eslint-disable-line @typescript-eslint/no-unused-vars
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
	 * Closes the DataConsumer.
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

  void _handleDataChannel() //: void
  {
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
    // this._dataChannel.addEventListener('open', () =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	debugger(message:'DataChannel "open" event');

    // 	this.safeEmit('open');
    // });

    // this._dataChannel.addEventListener('error', (event: any) =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	let { error } = event;

    // 	if (!error)
    // 		error = new Error('unknown DataChannel error');

    // 	if (error.errorDetail == 'sctp-failure')
    // 	{
    // 		logger.error(
    // 			'DataChannel SCTP error [sctpCauseCode:%s]: %s',
    // 			error.sctpCauseCode, error.message);
    // 	}
    // 	else
    // 	{
    // 		logger.error('DataChannel "error" event: %o', error);
    // 	}

    // 	this.safeEmit('error', error);
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

    // this._dataChannel.addEventListener('message', (event: any) =>
    // {
    // 	if (this._closed)
    // 		return;

    // 	this.safeEmit('message', event.data);
    // });
    //
    _dataChannel.onMessage = (event) {
      if (_closed) return;
      safeEmit('event', {'event': event});
    };
  }
}
