// ignore_for_file: slash_for_doc_comments

import 'dart:developer';

import 'enhancedeventemitter.dart';
import 'handlers/flutter.dart';
import 'handlers/handlerinterface.dart';
import 'rtpparameters.dart';
import 'sctpparameters.dart';
import 'transport.dart';
import 'utils.dart' as utils;
import 'ortc.dart' as ortc;

var BuiltinHandlerName = 'Chrome74';
// | 'Chrome74'
// | 'Chrome70'
// | 'Chrome67'
// | 'Chrome55'
// | 'Firefox60'
// | 'Safari12'
// | 'Safari11'
// | 'Edge11'
// | 'ReactNative';

class DeviceOptions {
  /**
	 * The name of one of the builtin handlers.
	 */
  String? handlerName; //?: BuiltinHandlerName;
  /**
	 * Custom handler factory.
	 */
  Function? handlerFactory; //?: HandlerFactory;
  /**
	 * DEPRECATED!
	 * The name of one of the builtin handlers.
	 */
  String? handler; //?: string;

  DeviceOptions({
    this.handlerName,
    this.handlerFactory,
    @Deprecated('此参数已被丢弃') this.handler,
  });
}

String detectDevice() //: BuiltinHandlerName | undefined
{
  // React-Native.
  // NOTE: react-native-webrtc >= 1.75.0 is required.
  // if (typeof navigator === 'object' && navigator.product === 'ReactNative')
  // {
  // 	if (typeof RTCPeerConnection === 'undefined')
  // 	{
  // 		logger.warn(
  // 			'this._detectDevice() | unsupported ReactNative without RTCPeerConnection');

  // 		return undefined;
  // 	}

  // 	logger.debug('this._detectDevice() | ReactNative handler chosen');

  // 	return 'ReactNative';
  // }
  // Browser.
  // if (typeof navigator === 'object' && typeof navigator.userAgent === 'string')
  // {
  // 	const ua = navigator.userAgent;
  // 	const browser = bowser.getParser(ua);
  // 	const engine = browser.getEngine();

  // 	// Chrome and Chromium.
  // 	if (browser.satisfies({ chrome: '>=74', chromium: '>=74' }))
  // 	{
  // 		return 'Chrome74';
  // 	}
  // 	else if (browser.satisfies({ chrome: '>=70', chromium: '>=70' }))
  // 	{
  // 		return 'Chrome70';
  // 	}
  // 	else if (browser.satisfies({ chrome: '>=67', chromium: '>=67' }))
  // 	{
  // 		return 'Chrome67';
  // 	}
  // 	else if (browser.satisfies({ chrome: '>=55', chromium: '>=55' }))
  // 	{
  // 		return 'Chrome55';
  // 	}
  // 	// Firefox.
  // 	else if (browser.satisfies({ firefox: '>=60' }))
  // 	{
  // 		return 'Firefox60';
  // 	}
  // 	// Safari with Unified-Plan support enabled.
  // 	else if (
  // 		browser.satisfies({ safari: '>=12.0' }) &&
  // 		typeof RTCRtpTransceiver !== 'undefined' &&
  // 		RTCRtpTransceiver.prototype.hasOwnProperty('currentDirection')
  // 	)
  // 	{
  // 		return 'Safari12';
  // 	}
  // 	// Safari with Plab-B support.
  // 	else if (browser.satisfies({ safari: '>=11' }))
  // 	{
  // 		return 'Safari11';
  // 	}
  // 	// Old Edge with ORTC support.
  // 	else if (
  // 		browser.satisfies({ 'microsoft edge': '>=11' }) &&
  // 		browser.satisfies({ 'microsoft edge': '<=18' })
  // 	)
  // 	{
  // 		return 'Edge11';
  // 	}
  // 	// Best effort for Chromium based browsers.
  // 	else if (engine.name && engine.name.toLowerCase() === 'blink')
  // 	{
  // 		const match = ua.match(/(?:(?:Chrome|Chromium))[ /](\w+)/i);

  // 		if (match)
  // 		{
  // 			const version = Number(match[1]);

  // 			if (version >= 74)
  // 			{
  // 				return 'Chrome74';
  // 			}
  // 			else if (version >= 70)
  // 			{
  // 				return 'Chrome70';
  // 			}
  // 			else if (version >= 67)
  // 			{
  // 				return 'Chrome67';
  // 			}
  // 			else
  // 			{
  // 				return 'Chrome55';
  // 			}
  // 		}
  // 		else
  // 		{
  // 			return 'Chrome74';
  // 		}
  // 	}
  // 	// Unsupported browser.
  // 	else
  // 	{
  // 		logger.warn(
  // 			'this._detectDevice() | browser not supported [name:%s, version:%s]',
  // 			browser.getBrowserName(), browser.getBrowserVersion());

  // 		return undefined;
  // 	}
  // }
  // // Unknown device.
  // else
  // {
  // 	logger.warn('this._detectDevice() | unknown device');

  // 	return undefined;
  // }

  return 'Chrome74';
}

class Device {
  // RTC handler factory.
  late Function _handlerFactory; //: HandlerFactory;
  // Handler name.
  late String _handlerName; //: string;
  // Loaded flag.
  bool _loaded = false;
  // Extended RTP capabilities.
  RtpCapabilities? _extendedRtpCapabilities; //?: any;
  // Local RTP capabilities for receiving media.
  RtpCapabilities? _recvRtpCapabilities; //?: RtpCapabilities;
  // Whether we can produce audio/video based on computed extended RTP
  // capabilities.
  late CanProduceByKind _canProduceByKind; //: CanProduceByKind;
  // Local SCTP capabilities.
  SctpCapabilities? _sctpCapabilities; //?: SctpCapabilities;
  // Observer instance.
  final _observer = EnhancedEventEmitter();

  /**
	 * Create a new Device to connect to mediasoup server.
	 *
	 * @throws {UnsupportedError} if device is not supported.
	 */
  Device(
      DeviceOptions
          options) //{ String handlerName, handlerFactory, Handler })//: DeviceOptions = {})
  {
    debugger(when: false, message: 'constructor()');

    // Handle deprecated option.
    if (options.handler != null) {
      debugger(
          when: false,
          message:
              'constructor() | Handler option is DEPRECATED, use handlerName or handlerFactory instead');

      // if (typeof Handler === 'string')
      // 	handlerName = Handler as BuiltinHandlerName;
      // else
      // 	throw new TypeError(
      // 		'non string Handler option no longer supported, use handlerFactory instead');
    }

    if ((options.handlerName != null && options.handlerName!.isNotEmpty) &&
        options.handlerFactory != null) {
      throw Exception(
          'just one of handlerName or handlerInterface can be given');
    }
    // print('laileme');
    if (options.handlerFactory != null) {
      _handlerFactory = options.handlerFactory!;
    } else {
      if (options.handlerName != null && options.handlerName!.isNotEmpty) {
        debugger(
            when: false,
            message: 'constructor() | handler given: ${options.handlerName}');
      } else {
        options.handlerName = detectDevice();

        if (options.handlerName != null && options.handlerName!.isNotEmpty) {
          debugger(
              when: false,
              message:
                  'constructor() | detected handler: ${options.handlerName}');
        } else {
          throw UnsupportedError('device not supported');
        }
      }

      _handlerFactory = Chrome74.createFactory();

      // 	switch (options.handlerName)
      // 	{
      // 		case 'Chrome74':
      // 			this._handlerFactory = Chrome74.createFactory();
      // 			break;
      // 		case 'Chrome70':
      // 			this._handlerFactory = Chrome70.createFactory();
      // 			break;
      // 		case 'Chrome67':
      // 			this._handlerFactory = Chrome67.createFactory();
      // 			break;
      // 		case 'Chrome55':
      // 			this._handlerFactory = Chrome55.createFactory();
      // 			break;
      // 		case 'Firefox60':
      // 			this._handlerFactory = Firefox60.createFactory();
      // 			break;
      // 		case 'Safari12':
      // 			this._handlerFactory = Safari12.createFactory();
      // 			break;
      // 		case 'Safari11':
      // 			this._handlerFactory = Safari11.createFactory();
      // 			break;
      // 		case 'Edge11':
      // 			this._handlerFactory = Edge11.createFactory();
      // 			break;
      // 		case 'ReactNative':
      // 			this._handlerFactory = ReactNative.createFactory();
      // 			break;
      // 		default:
      // 			throw new TypeError(`unknown handlerName "${handlerName}"`);
      // 	}
    }

    // Create a temporal handler to get its name.
    var handler = _handlerFactory();

    _handlerName = handler.name;

    handler.close();

    _extendedRtpCapabilities = null;
    _recvRtpCapabilities = null;
    _canProduceByKind = CanProduceByKind(false, false);
    // {
    // 	audio : false,
    // 	video : false
    // };
    _sctpCapabilities = null;
  }

  // ignore: slash_for_doc_comments
  /**
	 * The RTC handler name.
	 */
  String get handlerName => _handlerName; //: string
  // {
  // 	return this._handlerName;
  // }

  /**
	 * Whether the Device is loaded.
	 */
  bool get loaded //(): boolean
  {
    return _loaded;
  }

  // ignore: slash_for_doc_comments
  /**
	 * RTP capabilities of the Device for receiving media.
	 *
	 * @throws {InvalidStateError} if not loaded.
	 */
  RtpCapabilities? get rtpCapabilities //(): RtpCapabilities
  {
    if (!_loaded) throw Exception('not loaded');

    return _recvRtpCapabilities;
  }

  // ignore: slash_for_doc_comments
  /**
	 * SCTP capabilities of the Device.
	 *
	 * @throws {InvalidStateError} if not loaded.
	 */
  SctpCapabilities? get sctpCapabilities //(): SctpCapabilities
  {
    if (!_loaded) throw Exception('not loaded');

    return _sctpCapabilities;
  }

  /**
	 * Observer.
	 *
	 * @emits newtransport - (transport: Transport)
	 */
  EnhancedEventEmitter get observer //(): EnhancedEventEmitter
  {
    return _observer;
  }

  /**
	 * Initialize the Device.
	 */
  Future<void> load({RtpCapabilities? routerRtpCapabilities} //:
      //{ routerRtpCapabilities: RtpCapabilities }
      ) async //: Promise<void>
  {
    debugger(
        when: false,
        message: 'load() [routerRtpCapabilities:$routerRtpCapabilities]');

    // routerRtpCapabilities = utils.clone(routerRtpCapabilities, null);
    routerRtpCapabilities =
        RtpCapabilities.fromJson(routerRtpCapabilities!.toJson());

    // Temporal handler to get its capabilities.
    HandlerInterface handler; //: HandlerInterface | undefined;

    // try {
    if (_loaded) throw Exception('already loaded');

    // This may throw.
    ortc.validateRtpCapabilities(routerRtpCapabilities);

    handler = _handlerFactory();

    var nativeRtpCapabilities = await handler.getNativeRtpCapabilities();

    debugger(
        when: false,
        message: 'load() | got native RTP capabilities:$nativeRtpCapabilities');

    // This may throw.
    ortc.validateRtpCapabilities(nativeRtpCapabilities);

    // Get extended RTP capabilities.
    _extendedRtpCapabilities = ortc.getExtendedRtpCapabilities(
        nativeRtpCapabilities, routerRtpCapabilities);

    debugger(
        when: false,
        message:
            'load() | got extended RTP capabilities:$_extendedRtpCapabilities');

    // Check whether we can produce audio/video.
    _canProduceByKind.audio = ortc.canSend('audio', _extendedRtpCapabilities);
    _canProduceByKind.video = ortc.canSend('video', _extendedRtpCapabilities);

    // Generate our receiving RTP capabilities for receiving media.
    _recvRtpCapabilities =
        ortc.getRecvRtpCapabilities(_extendedRtpCapabilities);

    // This may throw.
    ortc.validateRtpCapabilities(_recvRtpCapabilities!);

    debugger(
        when: false,
        message:
            'load() | got receiving RTP capabilities:$_recvRtpCapabilities');

    // Generate our SCTP capabilities.
    _sctpCapabilities = await handler.getNativeSctpCapabilities();

    debugger(
        when: false,
        message: 'load() | got native SCTP capabilities:$_sctpCapabilities');

    // This may throw.
    ortc.validateSctpCapabilities(_sctpCapabilities!);

    debugger(when: false, message: 'load() succeeded');

    _loaded = true;

    handler.close();
    // } catch (error) {
    //   // if (handler != null)
    //   // handler.close();

    //   throw error;
    // }
  }

  /**
	 * Whether we can produce audio/video.
	 *
	 * @throws {InvalidStateError} if not loaded.
	 * @throws {TypeError} if wrong arguments.
	 */
  bool canProduce(String kind /*: MediaKind*/) //: boolean
  {
    if (!_loaded)
      throw Exception('not loaded');
    else if (kind != 'audio' && kind != 'video')
      throw Exception('invalid kind "$kind"');

    return _canProduceByKind.keys![kind]!;
  }

  /**
	 * Creates a Transport for sending media.
	 *
	 * @throws {InvalidStateError} if not loaded.
	 * @throws {TypeError} if wrong arguments.
	 */
  Transport createSendTransport(TransportOptions options
      // {
      // 	id,
      // 	iceParameters,
      // 	iceCandidates,
      // 	dtlsParameters,
      // 	sctpParameters,
      // 	iceServers,
      // 	iceTransportPolicy,
      // 	additionalSettings,
      // 	proprietaryConstraints,
      // 	appData = {}
      // }: TransportOptions
      ) //: Transport
  {
    debugger(when: false, message: 'createSendTransport()');

    var interOptions = InternalTransportOptions(
        options.id,
        options.iceParameters,
        options.iceCandidates,
        options.dtlsParameters,
        'send',
        null,
        null,
        null);
    interOptions.dtlsParameters = options.dtlsParameters;
    interOptions.sctpParameters = options.sctpParameters;
    interOptions.iceServers = options.iceServers;
    interOptions.iceTransportPolicy = options.iceTransportPolicy;
    interOptions.additionalSettings = options.additionalSettings;
    interOptions.proprietaryConstraints = options.proprietaryConstraints;
    interOptions.appData = options.appData;
    return _createTransport(interOptions);
    // {
    // 	direction              : 'send',
    // 	id                     : id,
    // 	iceParameters          : iceParameters,
    // 	iceCandidates          : iceCandidates,
    // 	dtlsParameters         : dtlsParameters,
    // 	sctpParameters         : sctpParameters,
    // 	iceServers             : iceServers,
    // 	iceTransportPolicy     : iceTransportPolicy,
    // 	additionalSettings     : additionalSettings,
    // 	proprietaryConstraints : proprietaryConstraints,
    // 	appData                : appData
    // });
  }

  /**
	 * Creates a Transport for receiving media.
	 *
	 * @throws {InvalidStateError} if not loaded.
	 * @throws {TypeError} if wrong arguments.
	 */
  Transport createRecvTransport(TransportOptions options
      // {
      // 	id,
      // 	iceParameters,
      // 	iceCandidates,
      // 	dtlsParameters,
      // 	sctpParameters,
      // 	iceServers,
      // 	iceTransportPolicy,
      // 	additionalSettings,
      // 	proprietaryConstraints,
      // 	appData = {}
      // }: TransportOptions
      ) //: Transport
  {
    debugger(when: false, message: 'createRecvTransport()');

    var interOptions = InternalTransportOptions(
        options.id,
        options.iceParameters,
        options.iceCandidates,
        options.dtlsParameters,
        'recv',
        null,
        null,
        null);
    // interOptions.direction = 'recv';
    // interOptions.id = options.id;
    // interOptions.iceParameters = options.iceParameters;
    // interOptions.iceCandidates = options.iceCandidates;
    // interOptions.dtlsParameters = options.dtlsParameters;
    interOptions.sctpParameters = options.sctpParameters;
    interOptions.iceServers = options.iceServers;
    interOptions.iceTransportPolicy = options.iceTransportPolicy;
    interOptions.additionalSettings = options.additionalSettings;
    interOptions.proprietaryConstraints = options.proprietaryConstraints;
    interOptions.appData = options.appData;

    return _createTransport(interOptions);
    // {
    // 	direction              : 'recv',
    // 	id                     : id,
    // 	iceParameters          : iceParameters,
    // 	iceCandidates          : iceCandidates,
    // 	dtlsParameters         : dtlsParameters,
    // 	sctpParameters         : sctpParameters,
    // 	iceServers             : iceServers,
    // 	iceTransportPolicy     : iceTransportPolicy,
    // 	additionalSettings     : additionalSettings,
    // 	proprietaryConstraints : proprietaryConstraints,
    // 	appData                : appData
    // });
  }

  Transport _createTransport(InternalTransportOptions options
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
      // 	appData = {}
      // }: InternalTransportOptions
      ) //: Transport
  {
    if (!_loaded) throw Exception('not loaded');
    // else if (typeof id !== 'string')
    // 	throw new TypeError('missing id');
    // else if (typeof iceParameters !== 'object')
    // 	throw new TypeError('missing iceParameters');
    // else if (!Array.isArray(iceCandidates))
    // 	throw new TypeError('missing iceCandidates');
    // else if (typeof dtlsParameters !== 'object')
    // 	throw new TypeError('missing dtlsParameters');
    // else if (sctpParameters && typeof sctpParameters !== 'object')
    // 	throw new TypeError('wrong sctpParameters');
    // else if (appData && typeof appData !== 'object')
    // 	throw new TypeError('if given, appData must be an object');

    var interOptions = InternalTransportOptions(
        options.id,
        options.iceParameters,
        options.iceCandidates,
        options.dtlsParameters,
        options.direction,
        null,
        null,
        null);
    // interOptions.direction = options.direction;
    // interOptions.id = options.id;
    // interOptions.iceParameters = options.iceParameters;
    // interOptions.iceCandidates = options.iceCandidates;
    // interOptions.dtlsParameters = options.dtlsParameters;
    interOptions.sctpParameters = options.sctpParameters;
    interOptions.iceServers = options.iceServers;
    interOptions.iceTransportPolicy = options.iceTransportPolicy;
    interOptions.additionalSettings = options.additionalSettings;
    interOptions.proprietaryConstraints = options.proprietaryConstraints;
    interOptions.appData = options.appData;
    interOptions.handlerFactory = _handlerFactory;
    interOptions.extendedRtpCapabilities = _extendedRtpCapabilities;
    interOptions.canProduceByKind = _canProduceByKind;
    // Create a new Transport.
    var transport = Transport(interOptions);
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
    // 	handlerFactory          : this._handlerFactory,
    // 	extendedRtpCapabilities : this._extendedRtpCapabilities,
    // 	canProduceByKind        : this._canProduceByKind
    // });

    // Emit observer event.
    _observer.safeEmit('newtransport', [transport]);

    return transport;
  }
}
