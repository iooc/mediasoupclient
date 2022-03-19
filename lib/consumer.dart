// ignore_for_file: slash_for_doc_comments

import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'enhancedeventemitter.dart';
import 'rtpparameters.dart';

class ConsumerOptions {
  String? id; //?: string;
  String? producerId; //?: string;
  String? kind; //?: 'audio' | 'video';
  RtpParameters rtpParameters; //: RtpParameters;
  dynamic appData; //?: any;

  ConsumerOptions(
    this.rtpParameters, {
    this.id,
    this.producerId,
    this.kind,
    this.appData,
  });
}

// const logger = new Logger('Consumer');
/// 多媒体消费者
class Consumer extends EnhancedEventEmitter {
  // Id.
  late String _id; //: string;
  // Local id.
  late String _localId; //: string;
  // Associated Producer id.
  late String _producerId; //: string;
  // Closed flag.
  bool _closed = false;
  // Associated RTCRtpReceiver.
  RTCRtpReceiver? _rtpReceiver; //?: RTCRtpReceiver;
  // Remote track.
  late MediaStreamTrack _track; //: MediaStreamTrack;
  // RTP parameters.
  late RtpParameters _rtpParameters; //: RtpParameters;
  // Paused flag.
  late bool _paused; //: boolean;
  // App custom data.
  dynamic _appData; //: any;
  // Observer instance.
  var _observer = EnhancedEventEmitter();

  /**
	 * @emits transportclose
	 * @emits trackended
	 * @emits @getstats
	 * @emits @close
	 */
  Consumer(
    String id,
    String localId,
    String producerId,
    MediaStreamTrack track,
    RtpParameters rtpParameters,
    appData, {
    RTCRtpReceiver? rtpReceiver,
  } //:
      // {
      // 	id: string;
      // 	localId: string;
      // 	producerId: string;
      // 	rtpReceiver?: RTCRtpReceiver;
      // 	track: MediaStreamTrack;
      // 	rtpParameters: RtpParameters;
      // 	appData: any;
      // }
      ) : super() {
    // super();

    debugger(when: false, message: 'constructor()');

    _id = id;
    _localId = localId;
    _producerId = producerId;
    _rtpReceiver = rtpReceiver;
    _track = track;
    _rtpParameters = rtpParameters;
    _paused = !track.enabled;
    _appData = appData;
    // this._onTrackEnded = this._onTrackEnded.bind(this);

    _handleTrack();
  }

  /**
	 * Consumer id.
	 */
  String get id //(): string
  {
    return _id;
  }

  /**
	 * Local id.
	 */
  String get localId //(): string
  {
    return _localId;
  }

  /**
	 * Associated Producer id.
	 */
  String get producerId //(): string
  {
    return _producerId;
  }

  /**
	 * Whether the Consumer is closed.
	 */
  bool get closed //(): boolean
  {
    return _closed;
  }

  /**
	 * Media kind.
	 */
  String? get kind //(): string
  {
    return _track.kind;
  }

  /**
	 * Associated RTCRtpReceiver.
	 */
  RTCRtpReceiver? get rtpReceiver //(): RTCRtpReceiver | undefined
  {
    return _rtpReceiver;
  }

  /**
	 * The associated track.
	 */
  MediaStreamTrack get track //(): MediaStreamTrack
  {
    return _track;
  }

  /**
	 * RTP parameters.
	 */
  RtpParameters get rtpParameters //(): RtpParameters
  {
    return _rtpParameters;
  }

  /**
	 * Whether the Consumer is paused.
	 */
  bool get paused //(): boolean
  {
    return _paused;
  }

  /**
	 * App custom data.
	 */
  get appData //(): any
  {
    return _appData;
  }

  /**
	 * Invalid setter.
	 */
  set appData(appData) // eslint-disable-line no-unused-vars
  {
    throw Exception('cannot override appData object');
  }

  /**
	 * Observer.
	 *
	 * @emits close
	 * @emits pause
	 * @emits resume
	 * @emits trackended
	 */
  EnhancedEventEmitter get observer //(): EnhancedEventEmitter
  {
    return _observer;
  }

  /**
	 * Closes the Consumer.
	 */
  void close() //: void
  {
    if (_closed) return;

    debugger(when: false, message: 'close()');

    _closed = true;

    _destroyTrack();

    emit('@close');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /**
	 * Transport was closed.
	 */
  void transportClosed() //: void
  {
    if (_closed) return;

    debugger(when: false, message: 'transportClosed()');

    _closed = true;

    _destroyTrack();

    safeEmit('transportclose');

    // Emit observer event.
    _observer.safeEmit('close');
  }

  /**
	 * Get associated RTCRtpReceiver stats.
	 */
  Future getStats() async //: Promise<RTCStatsReport>
  {
    if (_closed) throw Exception('closed');

    return safeEmitAsPromise('@getstats');
  }

  /**
	 * Pauses receiving media.
	 */
  void pause() //: void
  {
    debugger(when: false, message: 'pause()');

    if (_closed) {
      debugger(when: false, message: 'pause() | Consumer closed');

      return;
    }

    _paused = true;
    _track.enabled = false;

    // Emit observer event.
    _observer.safeEmit('pause');
  }

  /**
	 * Resumes receiving media.
	 */
  void resume() //: void
  {
    debugger(when: false, message: 'resume()');

    if (_closed) {
      debugger(when: false, message: 'resume() | Consumer closed');

      return;
    }

    _paused = false;
    _track.enabled = true;

    // Emit observer event.
    _observer.safeEmit('resume');
  }

  void _onTrackEnded() //: void
  {
    debugger(when: false, message: 'track "ended" event');

    safeEmit('trackended');

    // Emit observer event.
    _observer.safeEmit('trackended');
  }

  void _handleTrack() //: void
  {
    // this._track.addEventListener('ended', this._onTrackEnded);
    _track.onEnded = _onTrackEnded;
  }

  void _destroyTrack() //: void
  {
    try {
      // this._track.removeEventListener('ended', this._onTrackEnded);
      _track.onEnded = null;
      _track.stop();
    } catch (error) {}
  }
}
