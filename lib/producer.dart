import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'enhancedeventemitter.dart';
import 'rtpparameters.dart';

class ProducerOptions {
  MediaStreamTrack? track; //?: MediaStreamTrack;
  MediaStream? stream;
  List<RtpEncodingParameters>? encodings; //?: RtpEncodingParameters[];
  ProducerCodecOptions? codecOptions; //?: ProducerCodecOptions;
  RtpCodecCapability? codec; //?: RtpCodecCapability;
  bool? stopTracks; //?: boolean;
  bool? disableTrackOnPause; //?: boolean;
  bool? zeroRtpOnPause; //?: boolean;
  dynamic appData; //?: any;

  ProducerOptions({
    this.track,
    required this.stream,
    this.encodings,
    this.codecOptions,
    this.codec,
    this.stopTracks,
    this.disableTrackOnPause,
    this.zeroRtpOnPause,
    this.appData,
  });
}

// https://mediasoup.org/documentation/v3/mediasoup-client/api/#ProducerCodecOptions
class ProducerCodecOptions {
  bool? opusStereo; //?: boolean;
  bool? opusFec; //?: boolean;
  bool? opusDtx; //?: boolean;
  int? opusMaxPlaybackRate; //?: number;
  int? opusMaxAverageBitrate; //?: number;
  int? opusPtime; //?: number;
  int? videoGoogleStartBitrate; //?: number;
  int? videoGoogleMaxBitrate; //?: number;
  int? videoGoogleMinBitrate; //?: number;

  ProducerCodecOptions({
    this.opusStereo,
    this.opusFec,
    this.opusDtx,
    this.opusMaxPlaybackRate,
    this.opusMaxAverageBitrate,
    this.opusPtime,
    this.videoGoogleStartBitrate,
    this.videoGoogleMaxBitrate,
    this.videoGoogleMinBitrate,
  });
}

// const logger = new Logger('Producer');
/// 多媒体生产者
class Producer extends EnhancedEventEmitter {
  // Id.
  final String _id; //: string;
  // Local id.
  final String _localId; //: string;
  // Closed flag.
  bool _closed = false;
  // Associated RTCRtpSender.
  final RTCRtpSender? _rtpSender; //?: RTCRtpSender;
  // Local track.
  MediaStreamTrack? _track; //: MediaStreamTrack | null;
  // Producer kind.
  late String _kind; //: MediaKind;
  // RTP parameters.
  final RtpParameters _rtpParameters; //: RtpParameters;
  // Paused flag.
  late bool _paused; //: boolean;
  // Video max spatial layer.
  int? _maxSpatialLayer; //: number | undefined;
  // Whether the Producer should call stop() in given tracks.
  final bool _stopTracks; //: boolean;
  // Whether the Producer should set track.enabled = false when paused.
  final bool _disableTrackOnPause; //: boolean;
  // Whether we should replace the RTCRtpSender.track with null when paused.
  final bool _zeroRtpOnPause; //: boolean;
  // App custom data.
  final Map<String, dynamic>? _appData; //: any;
  // Observer instance.
  var _observer = EnhancedEventEmitter();

  /**
	 * @emits transportclose
	 * @emits trackended
	 * @emits @replacetrack - (track: MediaStreamTrack | null)
	 * @emits @setmaxspatiallayer - (spatialLayer: string)
	 * @emits @setrtpencodingparameters - (params: any)
	 * @emits @getstats
	 * @emits @close
	 */
  Producer(
    this._id,
    this._localId,
    this._rtpSender,
    this._track,
    this._rtpParameters,
    this._stopTracks,
    this._disableTrackOnPause,
    this._zeroRtpOnPause,
    this._appData,
    // {
    // 	id,
    // 	localId,
    // 	rtpSender,
    // 	track,
    // 	rtpParameters,
    // 	stopTracks,
    // 	disableTrackOnPause,
    // 	zeroRtpOnPause,
    // 	appData
    //}:
    // 	{
    // 		id: string;
    // 		localId: string;
    // 		rtpSender?: RTCRtpSender;
    // 		track: MediaStreamTrack;
    // 		rtpParameters: RtpParameters;
    // 		stopTracks: boolean;
    // 		disableTrackOnPause: boolean;
    // 		zeroRtpOnPause: boolean;
    // 		appData: any;
    // 	}
  ) : super() {
    // super();

    debugger(when: false, message: 'constructor()');

    // this._id = id;
    // this._localId = localId;
    // this._rtpSender = rtpSender;
    // this._track = track;
    // this._kind = track.kind as MediaKind;
    // this._rtpParameters = rtpParameters;
    // this._paused = disableTrackOnPause ? !track.enabled : false;
    // this._maxSpatialLayer = undefined;
    // this._stopTracks = stopTracks;
    // this._disableTrackOnPause = disableTrackOnPause;
    // this._zeroRtpOnPause = zeroRtpOnPause;
    // this._appData = appData;

    // dart 似乎无需进行 this 绑定
    // this._onTrackEnded = this._onTrackEnded.bind(this);

    // NOTE: Minor issue. If zeroRtpOnPause is true, we cannot emit the
    // '@replacetrack' event here, so RTCRtpSender.track won't be null.

    _handleTrack();
  }

  /**
	 * Producer id.
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
	 * Whether the Producer is closed.
	 */
  bool get closed //(): boolean
  {
    return _closed;
  }

  /**
	 * Media kind.
	 */
  String get kind //(): string
  {
    return _kind;
  }

  /**
	 * Associated RTCRtpSender.
	 */
  RTCRtpSender? get rtpSender //(): RTCRtpSender | undefined
  {
    return _rtpSender;
  }

  /**
	 * The associated track.
	 */
  MediaStreamTrack? get track //(): MediaStreamTrack | null
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
	 * Whether the Producer is paused.
	 */
  bool get paused //(): boolean
  {
    return _paused;
  }

  /**
	 * Max spatial layer.
	 *
	 * @type {Number | undefined}
	 */
  int? get maxSpatialLayer //(): number | undefined
  {
    return _maxSpatialLayer;
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
  set appData(appData) // eslint-disable-line @typescript-eslint/no-unused-vars
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
	 * Closes the Producer.
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
	 * Get associated RTCRtpSender stats.
	 */
  Future getStats() //: Promise<RTCStatsReport>
  {
    if (_closed) {
      throw Exception('closed');
    }

    return safeEmitAsPromise('@getstats');
  }

  /**
	 * Pauses sending media.
	 */
  void pause() //: void
  {
    debugger(when: false, message: 'pause()');

    if (_closed) {
      debugger(when: false, message: 'pause() | Producer closed');

      return;
    }

    _paused = true;

    if (_track != null && _disableTrackOnPause) {
      _track!.enabled = false;
    }

    if (_zeroRtpOnPause) {
      safeEmitAsPromise('@replacetrack', null).catchError((_) => {});
    }

    // Emit observer event.
    _observer.safeEmit('pause');
  }

  /**
	 * Resumes sending media.
	 */
  void resume() //: void
  {
    debugger(when: false, message: 'resume()');

    if (_closed) {
      debugger(when: false, message: 'resume() | Producer closed');

      return;
    }

    _paused = false;

    if (_track != null && _disableTrackOnPause) {
      _track!.enabled = true;
    }

    if (_zeroRtpOnPause) {
      safeEmitAsPromise('@replacetrack', [_track]).catchError((_) => {});
    }

    // Emit observer event.
    _observer.safeEmit('resume');
  }

  /**
	 * Replaces the current track with a new one or null.
	 */
  Future<void> replaceTrack(
      MediaStreamTrack
          track) async //: { track: MediaStreamTrack | null })//: Promise<void>
  {
    debugger(when: false, message: 'replaceTrack() [track:$track]');

    if (_closed) {
      // This must be done here. Otherwise there is no chance to stop the given
      // track.
      if (track != null && _stopTracks) {
        try {
          track.stop();
        } catch (error) {}
      }

      throw Exception('closed');
    } else if (track != null && (track as dynamic).readyState == 'ended') {
      throw Exception('track ended');
    }

    // Do nothing if this is the same track as the current handled one.
    if (track == _track) {
      debugger(when: false, message: 'replaceTrack() | same track, ignored');

      return;
    }

    if (!_zeroRtpOnPause || !_paused) {
      await safeEmitAsPromise('@replacetrack', [track]);
    }

    // Destroy the previous track.
    _destroyTrack();

    // Set the new track.
    _track = track;

    // If this Producer was paused/resumed and the state of the new
    // track does not match, fix it.
    if (_track != null && _disableTrackOnPause) {
      if (!_paused) {
        _track!.enabled = true;
      } else if (_paused) {
        _track!.enabled = false;
      }
    }

    // Handle the effective track.
    _handleTrack();
  }

  /**
	 * Sets the video max spatial layer to be sent.
	 */
  Future<void> setMaxSpatialLayer(int spatialLayer) async //: Promise<void>
  {
    if (_closed) {
      throw Exception('closed');
    } else if (_kind != 'video') {
      throw UnsupportedError('not a video Producer');
    }
    // else if (spatialLayer !== 'number')
    // 	throw new TypeError('invalid spatialLayer');

    if (spatialLayer == _maxSpatialLayer) return;

    await safeEmitAsPromise('@setmaxspatiallayer', [spatialLayer]);

    _maxSpatialLayer = spatialLayer;
  }

  /**
	 * Sets the DSCP value.
	 */
  Future<void> setRtpEncodingParameters(params //: RTCRtpEncodingParameters
      ) async //: Promise<void>
  {
    if (_closed) throw Exception('closed');
    // else if (typeof params !== 'object')
    // 	throw new TypeError('invalid params');

    await safeEmitAsPromise('@setrtpencodingparameters', params);
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
    if (_track == null) return;

    // this._track.addEventListener('ended', this._onTrackEnded);
    _track!.onEnded = _onTrackEnded;
  }

  void _destroyTrack() //: void
  {
    if (_track == null) return;

    try {
      // this._track.removeEventListener('ended', this._onTrackEnded);
      _track!.onEnded = null;

      // Just stop the track unless the app set stopTracks: false.
      if (_stopTracks) _track!.stop();
    } catch (error) {}
  }
}
