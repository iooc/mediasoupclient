// const logger = new Logger('Chrome74');

import 'dart:developer';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../rtpparameters.dart';
import '../sctpparameters.dart';
import '../transport.dart';
import 'handlerinterface.dart';
import 'sdp/RemoteSdp.dart';
import '../utils.dart' as utils;
import '../ortc.dart' as ortc;
import 'package:sdp_transform/sdp_transform.dart' as sdpTransform;
import 'sdp/commonutils.dart' as sdpCommonUtils;
import 'sdp/sdpobject.dart';
import 'sdp/unifiedplanutils.dart' as sdpUnifiedPlanUtils;
import '../scalabilitymodes.dart' as scalabilityMode;

var SCTP_NUM_STREAMS = NumSctpStreams(1024, 1024);

class Chrome74 extends HandlerInterface {
  // Handler direction.
  String? _direction; //?: 'send' | 'recv';
  // Remote SDP handler.
  RemoteSdp? _remoteSdp; //?: RemoteSdp;
  // Generic sending RTP parameters for audio and video.
  Map<String, RtpParameters>?
      _sendingRtpParametersByKind; //?: { [key: string]: RtpParameters };
  // Generic sending RTP parameters for audio and video suitable for the SDP
  // remote answer.
  Map<String, RtpParameters>?
      _sendingRemoteRtpParametersByKind; //?: { [key: string]: RtpParameters };
  // RTCPeerConnection instance.
  RTCPeerConnection? _pc; //: any;
  // Map of RTCTransceivers indexed by MID.
  final Map<String, RTCRtpTransceiver>
      _mapMidTransceiver = //: Map<string, RTCRtpTransceiver> =
      {};
  // Local stream for sending.
  // late MediaStream _sendStream; // = MediaStream();
  // Whether a DataChannel m=application section has been created.
  bool _hasDataChannelMediaSection = false;
  // Sending DataChannel id value counter. Incremented for each new DataChannel.
  int _nextSendSctpStreamId = 0;
  // Got transport local and remote parameters.
  bool _transportReady = false;

  /**
	 * Creates a factory function.
	 */
  static Function createFactory() //: HandlerFactory
  {
    return () => Chrome74();
  }

  Chrome74() : super() {
    // super();
    // createLocalMediaStream('local9087').then((value) {
    //   _sendStream = value;
    // });
  }

  @override
  String get name //(): string
  {
    return 'Chrome74';
  }

  @override
  void close() //: void
  {
    debugger(when: false, message: 'close()');

    // Close RTCPeerConnection.
    if (_pc != null) {
      try {
        _pc!.close();
      } catch (error) {}
    }
  }

  @override
  Future<RtpCapabilities>
      getNativeRtpCapabilities() async //: Promise<RtpCapabilities>
  {
    debugger(when: false, message: 'getNativeRtpCapabilities()');

    var pc = await createPeerConnection({
      'iceServers': [],
      'iceTransportPolicy': 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'unified-plan'
    });

    // try {
    // pc.addTransceiver('audio');
    // pc.addTransceiver('video');
    pc.addTransceiver(kind: RTCRtpMediaType.RTCRtpMediaTypeAudio);
    pc.addTransceiver(kind: RTCRtpMediaType.RTCRtpMediaTypeVideo);

    var offer = await pc.createOffer();

    try {
      pc.close();
    } catch (error) {}

    var sdpObject = sdpTransform.parse(offer.sdp!);
    var nativeRtpCapabilities =
        sdpCommonUtils.extractRtpCapabilities(SdpObject.fromJson(sdpObject));

    return nativeRtpCapabilities;
    // } catch (error) {
    //   try {
    //     pc.close();
    //   } catch (error2) {}

    //   throw error;
    // }
  }

  @override
  Future<SctpCapabilities>
      getNativeSctpCapabilities() async //: Promise<SctpCapabilities>
  {
    debugger(when: false, message: 'getNativeSctpCapabilities()');

    // return {
    // 	numStreams : SCTP_NUM_STREAMS
    // };
    return SctpCapabilities(SCTP_NUM_STREAMS);
  }

  @override
  Future<void> run(HandlerRunOptions options
      // {
      // 	direction,
      // 	iceParameters,
      // 	iceCandidates,
      // 	dtlsParameters,
      // 	sctpParameters,
      // 	iceServers,
      // 	iceTransportPolicy,
      // 	additionalSettings,
      // 	proprietaryConstraints,
      // 	extendedRtpCapabilities
      // }: HandlerRunOptions
      ) async //: void
  {
    debugger(when: false, message: 'run()');

    _direction = options.direction;

    _remoteSdp = RemoteSdp(
        // {
        iceParameters: options.iceParameters,
        iceCandidates: options.iceCandidates,
        dtlsParameters: options.dtlsParameters,
        sctpParameters: options.sctpParameters!
        // }
        );

    _sendingRtpParametersByKind = {
      'audio': ortc.getSendingRtpParameters(
          'audio', options.extendedRtpCapabilities!),
      'video': ortc.getSendingRtpParameters(
          'video', options.extendedRtpCapabilities!)
    };

    _sendingRemoteRtpParametersByKind = {
      'audio': ortc.getSendingRemoteRtpParameters(
          'audio', options.extendedRtpCapabilities!),
      'video': ortc.getSendingRemoteRtpParameters(
          'video', options.extendedRtpCapabilities!)
    };

    _pc = await createPeerConnection({
      'iceServers': options.iceServers, // || [],
      'iceTransportPolicy': options.iceTransportPolicy ?? 'all',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'sdpSemantics': 'unified-plan',
      ...?options.additionalSettings
    }, options.proprietaryConstraints);

    // Handle RTCPeerConnection connection status.
    // this._pc.addEventListener('iceconnectionstatechange', () {
    //   switch (this._pc.iceConnectionState) {
    //     case RTCIceConnectionState.RTCIceConnectionStateChecking: //'checking':
    //       this.emit('@connectionstatechange', ['connecting']);
    //       break;
    //     case RTCIceConnectionState
    //         .RTCIceConnectionStateConnected: //'connected':
    //     case RTCIceConnectionState
    //         .RTCIceConnectionStateCompleted: //'completed':
    //       this.emit('@connectionstatechange', ['connected']);
    //       break;
    //     case RTCIceConnectionState.RTCIceConnectionStateFailed: //'failed':
    //       this.emit('@connectionstatechange', ['failed']);
    //       break;
    //     case RTCIceConnectionState
    //         .RTCIceConnectionStateDisconnected: //'disconnected':
    //       this.emit('@connectionstatechange', ['disconnected']);
    //       break;
    //     case RTCIceConnectionState.RTCIceConnectionStateClosed: //'closed':
    //       this.emit('@connectionstatechange', ['closed']);
    //       break;
    //   }
    // });
    _pc!.onIceConnectionState = (state) {
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateChecking: //'checking':
          emit('@connectionstatechange', ['connecting']);
          break;
        case RTCIceConnectionState
            .RTCIceConnectionStateConnected: //'connected':
        case RTCIceConnectionState
            .RTCIceConnectionStateCompleted: //'completed':
          emit('@connectionstatechange', ['connected']);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed: //'failed':
          emit('@connectionstatechange', ['failed']);
          break;
        case RTCIceConnectionState
            .RTCIceConnectionStateDisconnected: //'disconnected':
          emit('@connectionstatechange', ['disconnected']);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed: //'closed':
          emit('@connectionstatechange', ['closed']);
          break;
      }
    };
  }

  @override
  Future<void> updateIceServers(
      List<dynamic /*RTCIceServer*/ > iceServers) async //: Promise<void>
  {
    debugger(when: false, message: 'updateIceServers()');

    var configuration = _pc!.getConfiguration;

    configuration['iceServers'] = iceServers;

    _pc!.setConfiguration(configuration);
  }

  @override
  Future<void> restartIce(IceParameters iceParameters) async //: Promise<void>
  {
    debugger(when: false, message: 'restartIce()');

    // Provide the remote SDP handler with new remote ICE parameters.
    _remoteSdp!.updateIceParameters(iceParameters);

    if (!_transportReady) return;

    if (_direction == 'send') {
      var offer = await _pc!.createOffer({'iceRestart': true});

      debugger(
          when: false,
          message:
              'restartIce() | calling pc.setLocalDescription() [offer:$offer]');

      await _pc!.setLocalDescription(offer);

      var answer = RTCSessionDescription(_remoteSdp!.getSdp(), 'answer');

      debugger(
          when: false,
          message:
              'restartIce() | calling pc.setRemoteDescription() [answer:$answer]');

      await _pc!.setRemoteDescription(answer);
    } else {
      var offer = RTCSessionDescription(_remoteSdp!.getSdp(), 'offer');

      debugger(
          when: false,
          message:
              'restartIce() | calling pc.setRemoteDescription() [offer:$offer]');

      await _pc!.setRemoteDescription(offer);

      var answer = await _pc!.createAnswer();

      debugger(
          when: false,
          message:
              'restartIce() | calling pc.setLocalDescription() [answer:$answer]');

      await _pc!.setLocalDescription(answer);
    }
  }

  @override
  Future<List<StatsReport>>
      getTransportStats() async //: Promise<RTCStatsReport>
  {
    return _pc!.getStats();
  }

  @override
  Future<HandlerSendResult> send(HandlerSendOptions options
      // { track, encodings, codecOptions, codec }: HandlerSendOptions
      ) async //: Promise<HandlerSendResult>
  {
    _assertSendDirection();

    debugger(
        when: false,
        message:
            'send() [kind:${options.track.kind}, track.id:${options.track.id}]');

    if (options.encodings != null && options.encodings!.length > 1) {
      // encodings.forEach((encoding: RtpEncodingParameters, idx: number) =>
      // {
      // 	encoding.rid = `r${idx}`;
      // });
      for (var i = 0; i < options.encodings!.length; i++) {
        var encoding = options.encodings![i];
        encoding.rid = 'r$i';
      }
    }

    // RtpParameters sendingRtpParameters =
    //     utils.clone(_sendingRtpParametersByKind![options.track.kind], {});
    RtpParameters sendingRtpParameters = RtpParameters.fromJson(
        _sendingRtpParametersByKind![options.track.kind]!.toJson());

    // This may throw.
    sendingRtpParameters.codecs =
        ortc.reduceCodecs(sendingRtpParameters.codecs, options.codec!);

    // RtpParameters sendingRemoteRtpParameters =
    //     utils.clone(_sendingRemoteRtpParametersByKind![options.track.kind], {});
    RtpParameters sendingRemoteRtpParameters = RtpParameters.fromJson(
        _sendingRemoteRtpParametersByKind![options.track.kind]!.toJson());

    // This may throw.
    sendingRemoteRtpParameters.codecs =
        ortc.reduceCodecs(sendingRemoteRtpParameters.codecs, options.codec!);

    var mediaSectionIdx = _remoteSdp!.getNextMediaSectionIdx();

    List<RTCRtpEncoding> codes = [];
    for (var element in options.encodings!) {
      var code = RTCRtpEncoding(
        rid: element.rid,
        maxBitrate: element.maxBitrate,
        maxFramerate: element.maxFramerate,
        minBitrate: element.maxBitrate,
        scaleResolutionDownBy: element.scaleResolutionDownBy,
        ssrc: element.ssrc,
      );
      codes.add(code);
    }
    var transceiver = await _pc!.addTransceiver(
        track: options.track,
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly, //'sendonly',
            streams: [options.stream!],
            sendEncodings: codes));
    var offer = await _pc!.createOffer();
    var localSdpObject = SdpObject.fromJson(sdpTransform.parse(offer.sdp!));
    MediaObject offerMediaObject;

    if (!_transportReady) {
      await _setupTransport(
          localDtlsRole: 'server', localSdpObject: localSdpObject);
    }

    // Special case for VP9 with SVC.
    var hackVp9Svc = false;

    var layers = scalabilityMode.parse(
        scalabilityMode: options.encodings![0].scalabilityMode!);

    if (options.encodings != null &&
        options.encodings!.length == 1 &&
        layers.spatialLayers > 1 &&
        sendingRtpParameters.codecs[0].mimeType.toLowerCase() == 'video/vp9') {
      debugger(
          when: false,
          message: 'send() | enabling legacy simulcast for VP9 SVC');

      hackVp9Svc = true;
      localSdpObject = SdpObject.fromJson(sdpTransform.parse(offer.sdp!));
      offerMediaObject = localSdpObject.media[mediaSectionIdx['idx']];

      sdpUnifiedPlanUtils.addLegacySimulcast(
          // {
          offerMediaObject: offerMediaObject,
          numStreams: layers.spatialLayers
          // }
          );

      offer = RTCSessionDescription(
          sdpTransform.write(localSdpObject.toJson(), null), 'offer');
    }

    debugger(
        when: false,
        message: 'send() | calling pc.setLocalDescription() [offer:$offer]');

    await _pc!.setLocalDescription(offer);

    // We can now get the transceiver.mid.
    var localId = transceiver.mid;

    // Set MID.
    sendingRtpParameters.mid = localId;

    var localDescription = await _pc!.getLocalDescription();
    localSdpObject =
        SdpObject.fromJson(sdpTransform.parse(localDescription!.sdp!));
    offerMediaObject = localSdpObject.media[mediaSectionIdx['idx']];

    // Set RTCP CNAME.
    sendingRtpParameters.rtcp!.cname =
        sdpCommonUtils.getCname(offerMediaObject: offerMediaObject);

    // Set RTP encodings by parsing the SDP offer if no encodings are given.
    if (options.encodings == null) {
      sendingRtpParameters.encodings = sdpUnifiedPlanUtils.getRtpEncodings(
          offerMediaObject: offerMediaObject);
    }
    // Set RTP encodings by parsing the SDP offer and complete them with given
    // one if just a single encoding has been given.
    else if (options.encodings!.length == 1) {
      var newEncodings = sdpUnifiedPlanUtils.getRtpEncodings(
          offerMediaObject: offerMediaObject);

      // Object.assign(newEncodings[0], encodings[0]);
      newEncodings[0] = options.encodings![0];

      // Hack for VP9 SVC.
      if (hackVp9Svc) newEncodings = [newEncodings[0]];

      sendingRtpParameters.encodings = newEncodings;
    }
    // Otherwise if more than 1 encoding are given use them verbatim.
    else {
      sendingRtpParameters.encodings = options.encodings;
    }

    // If VP8 or H264 and there is effective simulcast, add scalabilityMode to
    // each encoding.
    if (sendingRtpParameters.encodings!.length > 1 &&
        (sendingRtpParameters.codecs[0].mimeType.toLowerCase() == 'video/vp8' ||
            sendingRtpParameters.codecs[0].mimeType.toLowerCase() ==
                'video/h264')) {
      for (var encoding in sendingRtpParameters.encodings!) {
        encoding.scalabilityMode = 'S1T3';
      }
    }

    _remoteSdp!.send(
        // {
        offerMediaObject: offerMediaObject,
        reuseMid: mediaSectionIdx['reuseMid'],
        offerRtpParameters: sendingRtpParameters,
        answerRtpParameters: sendingRemoteRtpParameters,
        codecOptions: options.codecOptions!,
        extmapAllowMixed: true
        // }
        );

    var answer = RTCSessionDescription(_remoteSdp!.getSdp(), 'answer');

    debugger(
        when: false,
        message: 'send() | calling pc.setRemoteDescription() [answer:$answer]');

    await _pc!.setRemoteDescription(answer);

    // Store in the map.
    _mapMidTransceiver[localId] = transceiver;

    return HandlerSendResult(
      localId,
      sendingRtpParameters,
      rtpSender: transceiver.sender,
    );
  }

  @override
  Future<void> stopSending(String localId) async //: Promise<void>
  {
    _assertSendDirection();

    debugger(when: false, message: 'stopSending() [localId:$localId]');

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    // transceiver.sender.replaceTrack(null);
    _pc!.removeTrack(transceiver.sender);
    _remoteSdp!.closeMediaSection(transceiver.mid);

    var offer = await _pc!.createOffer();

    debugger(
        when: false,
        message:
            'stopSending() | calling pc.setLocalDescription() [offer:$offer]');

    await _pc!.setLocalDescription(offer);

    var answer = RTCSessionDescription(_remoteSdp!.getSdp(), 'answer');

    debugger(
        when: false,
        message:
            'stopSending() | calling pc.setRemoteDescription() [answer:$answer]');

    await _pc!.setRemoteDescription(answer);
  }

  @override
  Future<void> replaceTrack(String localId,
      {MediaStreamTrack? track} //: MediaStreamTrack | null
      ) async //: Promise<void>
  {
    _assertSendDirection();

    if (track != null) {
      debugger(
          when: false,
          message: 'replaceTrack() [localId:$localId, track.id:${track.id}]');
    } else {
      debugger(
          when: false, message: 'replaceTrack() [localId:$localId, no track]');
    }

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    await transceiver.sender.replaceTrack(track!);
  }

  @override
  Future<void> setMaxSpatialLayer(
      String localId, int spatialLayer) async //: Promise<void>
  {
    _assertSendDirection();

    debugger(
        when: false,
        message:
            'setMaxSpatialLayer() [localId:$localId, spatialLayer:$spatialLayer]');

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    var parameters = transceiver.sender.parameters;

    // parameters.encodings.forEach((encoding: RTCRtpEncodingParameters, idx: number) =>
    // {
    // 	if (idx <= spatialLayer)
    // 		encoding.active = true;
    // 	else
    // 		encoding.active = false;
    // });
    for (var i = 0; i < parameters.encodings!.length; i++) {
      var encoding = parameters.encodings![i];
      if (i <= spatialLayer) {
        encoding.active = true;
      } else {
        encoding.active = false;
      }
    }

    await transceiver.sender.setParameters(parameters);
  }

  @override
  Future<void> setRtpEncodingParameters(
      String localId, params) async //: Promise<void>
  {
    _assertSendDirection();

    debugger(
        when: false,
        message:
            'setRtpEncodingParameters() [localId:$localId, params:$params]');

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    var parameters = transceiver.sender.parameters;

    // parameters.encodings.forEach((encoding: RTCRtpEncodingParameters, idx: number) =>
    // {
    // 	parameters.encodings[idx] = { ...encoding, ...params };
    // });
    for (var i = 0; i < parameters.encodings!.length; i++) {
      var encoding = parameters.encodings![i];
      // dynamic code = utils.clone(encoding, {});
      var code = RTCRtpEncoding.fromMap(encoding.toMap());
      code.ssrc = params;
      parameters.encodings![i] = code;
    }

    await transceiver.sender.setParameters(parameters);
  }

  @override
  Future<List<StatsReport>> getSenderStats(
      String localId) async //: Promise<RTCStatsReport>
  {
    _assertSendDirection();

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    return transceiver.sender.getStats();
  }

  @override
  Future<HandlerSendDataChannelResult> sendDataChannel(
      HandlerSendDataChannelOptions options
      // {
      // 	ordered,
      // 	maxPacketLifeTime,
      // 	maxRetransmits,
      // 	label,
      // 	protocol,
      // 	priority
      // }: HandlerSendDataChannelOptions
      ) async //: Promise<HandlerSendDataChannelResult>
  {
    _assertSendDirection();

    dynamic option = RTCDataChannelInit();
    option.negotiated = true;
    option.id = _nextSendSctpStreamId;
    option.ordered = options.ordered;
    option.maxPacketLifeTime = options.maxPacketLifeTime;
    option.maxRetransmits = options.maxRetransmits;
    option.protocol = options.protocol;
    option.priority = options.priority;

    debugger(when: false, message: 'sendDataChannel() [options:$option]');

    var dataChannel = await _pc!.createDataChannel(options.label!, option);

    // Increase next id.
    _nextSendSctpStreamId = ++_nextSendSctpStreamId % SCTP_NUM_STREAMS.MIS;

    // If this is the first DataChannel we need to create the SDP answer with
    // m=application section.
    if (!_hasDataChannelMediaSection) {
      var offer = await _pc!.createOffer();
      var localSdpObject = SdpObject.fromJson(sdpTransform.parse(offer.sdp!));
      var offerMediaObject =
          localSdpObject.media.firstWhere((m) => m.type == 'application');

      if (!_transportReady) {
        await _setupTransport(
            localDtlsRole: 'server', localSdpObject: localSdpObject);
      }

      debugger(
          when: false,
          message:
              'sendDataChannel() | calling pc.setLocalDescription() [offer:$offer]');

      await _pc!.setLocalDescription(offer);

      _remoteSdp!.sendSctpAssociation(offerMediaObject);

      var answer = RTCSessionDescription(_remoteSdp!.getSdp(), 'answer');

      debugger(
          when: false,
          message:
              'sendDataChannel() | calling pc.setRemoteDescription() [answer:$answer]');

      await _pc!.setRemoteDescription(answer);

      _hasDataChannelMediaSection = true;
    }

    var sctpStreamParameters = SctpStreamParameters(
        streamId: option.id,
        ordered: option.ordered,
        maxPacketLifeTime: option.maxPacketLifeTime,
        maxRetransmits: option.maxRetransmits);

    return HandlerSendDataChannelResult(dataChannel, sctpStreamParameters);
  }

  @override
  Future<HandlerReceiveResult> receive(HandlerReceiveOptions options
      // { String trackId, String kind, RtpParameters rtpParameters }//: HandlerReceiveOptions
      ) async //: Promise<HandlerReceiveResult>
  {
    _assertRecvDirection();

    debugger(
        when: false,
        message:
            'receive() [trackId:${options.trackId}, kind:${options.kind}]');

    var localId =
        options.rtpParameters.mid; // || String(this._mapMidTransceiver.size);
    if (localId!.isEmpty) localId = _mapMidTransceiver.length.toString();

    _remoteSdp!.receive(
        mid: localId,
        kind: options.kind,
        offerRtpParameters: options.rtpParameters,
        streamId: options.rtpParameters.rtcp!.cname!,
        trackId: options.trackId);

    var offer = RTCSessionDescription(_remoteSdp!.getSdp(), 'offer');

    debugger(
        when: false,
        message:
            'receive() | calling pc.setRemoteDescription() [offer:$offer]');

    await _pc!.setRemoteDescription(offer);

    var answer = await _pc!.createAnswer();
    var localSdpObject = SdpObject.fromJson(sdpTransform.parse(answer.sdp!));
    var answerMediaObject =
        localSdpObject.media.firstWhere((m) => m.mid == localId);

    // May need to modify codec parameters in the answer based on codec
    // parameters in the offer.
    sdpCommonUtils.applyCodecParameters(
        offerRtpParameters: options.rtpParameters,
        answerMediaObject: answerMediaObject);

    answer = RTCSessionDescription(
        sdpTransform.write(localSdpObject.toJson(), null), 'answer');

    if (!_transportReady) {
      await _setupTransport(
          localDtlsRole: 'client', localSdpObject: localSdpObject);
    }

    debugger(
        when: false,
        message:
            'receive() | calling pc.setLocalDescription() [answer:$answer]');

    await _pc!.setLocalDescription(answer);

    var transceiver = (await _pc!.getTransceivers())
        .firstWhereOrNull((t) => t.mid == localId);

    if (transceiver == null) throw Exception('new RTCRtpTransceiver not found');

    // Store in the map.
    _mapMidTransceiver[localId] = transceiver;

    final MediaStream? stream = _pc!
        .getRemoteStreams()
        .firstWhereOrNull((e) => e?.id == options.rtpParameters.rtcp!.cname);

    if (stream == null) throw ('Stream not found');

    return HandlerReceiveResult(localId, transceiver.receiver.track!, stream,
        rtpReceiver: transceiver.receiver);
  }

  @override
  Future<void> stopReceiving(String localId) async //: Promise<void>
  {
    _assertRecvDirection();

    debugger(when: false, message: 'stopReceiving() [localId:$localId]');

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    _remoteSdp!.closeMediaSection(transceiver.mid);

    var offer = RTCSessionDescription(_remoteSdp!.getSdp(), 'offer');

    debugger(
        when: false,
        message:
            'stopReceiving() | calling pc.setRemoteDescription() [offer:$offer]');

    await _pc!.setRemoteDescription(offer);

    var answer = await _pc!.createAnswer();

    debugger(
        when: false,
        message:
            'stopReceiving() | calling pc.setLocalDescription() [answer:$answer]');

    await _pc!.setLocalDescription(answer);
  }

  @override
  Future<List<StatsReport>> getReceiverStats(
      String localId) async //: Promise<RTCStatsReport>
  {
    _assertRecvDirection();

    var transceiver = _mapMidTransceiver[localId];

    if (transceiver == null) {
      throw Exception('associated RTCRtpTransceiver not found');
    }

    return transceiver.receiver.getStats();
  }

  @override
  Future<HandlerReceiveDataChannelResult> receiveDataChannel(
      HandlerReceiveDataChannelOptions options
      // { sctpStreamParameters, label, protocol }: HandlerReceiveDataChannelOptions
      ) async //: Promise<HandlerReceiveDataChannelResult>
  {
    _assertRecvDirection();

    var sctpStreamParameters = options.sctpStreamParameters;
    var streamId = sctpStreamParameters.streamId;
    var ordered = sctpStreamParameters.ordered;
    var maxPacketLifeTime = sctpStreamParameters.maxPacketLifeTime;
    var maxRetransmits = sctpStreamParameters.maxRetransmits;

    var option = RTCDataChannelInit();

    option.negotiated = true;
    option.id = streamId!;
    option.ordered = ordered ?? option.ordered;
    // option.maxPacketLifeTime = maxPacketLifeTime;
    option.maxRetransmitTime = maxPacketLifeTime ?? option.maxRetransmitTime;
    option.maxRetransmits = maxRetransmits ?? option.maxRetransmits;
    option.protocol = options.protocol!;

    debugger(when: false, message: 'receiveDataChannel() [options:$option]');

    var dataChannel = await _pc!.createDataChannel(options.label!, option);

    // If this is the first DataChannel we need to create the SDP offer with
    // m=application section.
    if (!_hasDataChannelMediaSection) {
      _remoteSdp!.receiveSctpAssociation();

      var offer = RTCSessionDescription(_remoteSdp!.getSdp(), 'offer');

      debugger(
          when: false,
          message:
              'receiveDataChannel() | calling pc.setRemoteDescription() [offer:$offer]');

      await _pc!.setRemoteDescription(offer);

      var answer = await _pc!.createAnswer();

      if (!_transportReady) {
        var localSdpObject =
            SdpObject.fromJson(sdpTransform.parse(answer.sdp!));

        await _setupTransport(
            localDtlsRole: 'client', localSdpObject: localSdpObject);
      }

      debugger(
          when: false,
          message:
              'receiveDataChannel() | calling pc.setRemoteDescription() [answer:$answer]');

      await _pc!.setLocalDescription(answer);

      _hasDataChannelMediaSection = true;
    }

    return HandlerReceiveDataChannelResult(dataChannel);
  }

  Future<void> _setupTransport(
      {String? localDtlsRole, SdpObject? localSdpObject} //:
      // {
      // 	localDtlsRole: DtlsRole;
      // 	localSdpObject?: any;
      // }
      ) async //: Promise<void>
  {
    localSdpObject ??= SdpObject.fromJson(
        sdpTransform.parse((await _pc!.getLocalDescription())!.sdp!));

    // Get our local DTLS parameters.
    var dtlsParameters =
        sdpCommonUtils.extractDtlsParameters(sdpObject: localSdpObject);

    // Set our DTLS role.
    dtlsParameters.role = localDtlsRole!;

    // Update the remote DTLS role in the SDP.
    _remoteSdp!.updateDtlsRole(localDtlsRole == 'client' ? 'server' : 'client');

    // Need to tell the remote transport about our parameters.
    await safeEmitAsPromise('@connect', [
      {dtlsParameters}
    ]);

    _transportReady = true;
  }

  void _assertSendDirection() //: void
  {
    if (_direction != 'send') {
      throw Exception(
          'method can just be called for handlers with "send" direction');
    }
  }

  void _assertRecvDirection() //: void
  {
    if (_direction != 'recv') {
      throw Exception(
          'method can just be called for handlers with "recv" direction');
    }
  }
}
