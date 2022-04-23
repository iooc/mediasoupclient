import '../../producer.dart';
import '../../rtpparameters.dart';
import '../../sctpparameters.dart';
import '../../transport.dart';
import '../../utils.dart' as utils;
import 'sdpobject.dart';

abstract class MediaSection {
  // SDP media object.
  late MediaObject _mediaObject; //: any;
  // Whether this is Plan-B SDP.
  late bool _planB; //: boolean;

  MediaSection(
      {IceParameters? iceParameters,
      List<IceCandidate>? iceCandidates,
      DtlsParameters? dtlsParameters,
      bool planB = false} //:
      // {
      // 	iceParameters?: IceParameters;
      // 	iceCandidates?: IceCandidate[];
      // 	dtlsParameters?: DtlsParameters;
      // 	planB: boolean;
      // }
      ) {
    _mediaObject = MediaObject();
    _planB = planB;

    if (iceParameters != null) {
      setIceParameters(iceParameters);
    }

    if (iceCandidates != null) {
      _mediaObject.candidates = [];

      for (var candidate in iceCandidates) {
        var candidateObject = IceCandidate.fromJson(candidate.toJson());

        // mediasoup does mandates rtcp-mux so candidates component is always
        // RTP (1).
        // candidateObject.component = 1;
        // candidateObject.foundation = candidate.foundation;
        // candidateObject.ip = candidate.ip;
        // candidateObject.port = candidate.port;
        // candidateObject.priority = candidate.priority;
        // candidateObject.transport = candidate.protocol;
        // candidateObject.type = candidate.type;
        if (candidate.tcpType != null && candidate.tcpType!.isNotEmpty) {
          candidateObject.tcpType = candidate.tcpType;
        }

        _mediaObject.candidates!.add(candidateObject);
      }

      _mediaObject.endOfCandidates = 'end-of-candidates';
      _mediaObject.iceOptions = 'renomination';
    }

    if (dtlsParameters != null) {
      setDtlsRole(dtlsParameters.role!);
    }
  }

  void setDtlsRole(String role); //(DtlsRole role);//: void;

  String get mid //(): string
  {
    return _mediaObject.mid.toString();
  }

  bool get closed //(): boolean
  {
    return _mediaObject.port == 0;
  }

  MediaObject getObject() //: object
  {
    return _mediaObject;
  }

  void setIceParameters(IceParameters iceParameters) //: void
  {
    _mediaObject.iceUfrag = iceParameters.usernameFragment;
    _mediaObject.icePwd = iceParameters.password;
  }

  void disable() //: void
  {
    _mediaObject.direction = RtpHeaderDirection.inactive; // 'inactive';
    _mediaObject.ext = null;
    _mediaObject.ssrcs = null;
    _mediaObject.ssrcGroups = null;
    _mediaObject.simulcast = null;
    _mediaObject.simulcast_03 = null;
    _mediaObject.rids = null;
    // delete this._mediaObject.ext;
    // delete this._mediaObject.ssrcs;
    // delete this._mediaObject.ssrcGroups;
    // delete this._mediaObject.simulcast;
    // delete this._mediaObject.simulcast_03;
    // delete this._mediaObject.rids;
  }

  void close() //: void
  {
    _mediaObject.direction = RtpHeaderDirection.inactive; // 'inactive';

    _mediaObject.port = 0;
    _mediaObject.ext = null;
    _mediaObject.ssrcs = null;
    _mediaObject.ssrcGroups = null;
    _mediaObject.simulcast = null;
    _mediaObject.simulcast_03 = null;
    _mediaObject.rids = null;
    _mediaObject.extmapAllowMixed = null;

    // delete this._mediaObject.ext;
    // delete this._mediaObject.ssrcs;
    // delete this._mediaObject.ssrcGroups;
    // delete this._mediaObject.simulcast;
    // delete this._mediaObject.simulcast_03;
    // delete this._mediaObject.rids;
    // delete this._mediaObject.extmapAllowMixed;
  }
}

class AnswerMediaSection extends MediaSection {
  AnswerMediaSection(
      {IceParameters? iceParameters,
      List<IceCandidate>? iceCandidates,
      DtlsParameters? dtlsParameters,
      SctpParameters? sctpParameters,
      PlainRtpParameters? plainRtpParameters,
      bool planB = false,
      MediaObject? offerMediaObject,
      RtpParameters? offerRtpParameters,
      RtpParameters? answerRtpParameters,
      ProducerCodecOptions? codecOptions,
      bool extmapAllowMixed = false} //:
      // {
      // 	iceParameters?: IceParameters;
      // 	iceCandidates?: IceCandidate[];
      // 	dtlsParameters?: DtlsParameters;
      // 	sctpParameters?: SctpParameters;
      // 	plainRtpParameters?: PlainRtpParameters;
      // 	planB?: boolean;
      // 	offerMediaObject: any;
      // 	offerRtpParameters?: RtpParameters;
      // 	answerRtpParameters?: RtpParameters;
      // 	codecOptions?: ProducerCodecOptions;
      // 	extmapAllowMixed?: boolean;
      // }
      )
      : super(
            iceParameters: iceParameters,
            iceCandidates: iceCandidates,
            dtlsParameters: dtlsParameters,
            planB: planB) {
    // super({ iceParameters, iceCandidates, dtlsParameters, planB });

    _mediaObject.mid = offerMediaObject?.mid;
    _mediaObject.type = offerMediaObject?.type;
    _mediaObject.protocol = offerMediaObject?.protocol;

    if (plainRtpParameters == null) {
      _mediaObject.connection = Connection(ip: '127.0.0.1', version: 4);
      _mediaObject.port = 7;
    } else {
      _mediaObject.connection = Connection(
          ip: plainRtpParameters.ip, version: plainRtpParameters.ipVersion);
      _mediaObject.port = plainRtpParameters.port;
    }

    switch (offerMediaObject?.type) {
      case 'audio':
      case 'video':
        {
          _mediaObject.direction = RtpHeaderDirection.recvonly; // 'recvonly';
          _mediaObject.rtp = [];
          _mediaObject.rtcpFb = [];
          _mediaObject.fmtp = [];

          for (var codec in answerRtpParameters!.codecs) {
            var rtp = Rtp(
                payload: codec.payloadType,
                codec: getCodecName(codec),
                rate: codec.clockRate);

            if (codec.channels! > 1) rtp.encoding = codec.channels!;

            _mediaObject.rtp!.add(rtp);

            Map<String, dynamic> codecParameters =
                utils.clone(codec.parameters, {});

            if (codecOptions != null) {
              // const {
              // 	opusStereo,
              // 	opusFec,
              // 	opusDtx,
              // 	opusMaxPlaybackRate,
              // 	opusMaxAverageBitrate,
              // 	opusPtime,
              // 	videoGoogleStartBitrate,
              // 	videoGoogleMaxBitrate,
              // 	videoGoogleMinBitrate
              // } = codecOptions;
              var opusStereo = codecOptions.opusStereo;
              var opusFec = codecOptions.opusFec;
              var opusDtx = codecOptions.opusDtx;
              var opusMaxPlaybackRate = codecOptions.opusMaxPlaybackRate;
              var opusMaxAverageBitrate = codecOptions.opusMaxAverageBitrate;
              var opusPtime = codecOptions.opusPtime;
              var videoGoogleStartBitrate =
                  codecOptions.videoGoogleStartBitrate;
              var videoGoogleMaxBitrate = codecOptions.videoGoogleMaxBitrate;
              var videoGoogleMinBitrate = codecOptions.videoGoogleMinBitrate;

              var offerCodec = offerRtpParameters!.codecs
                  .firstWhere((c) => (c.payloadType == codec.payloadType));

              switch (codec.mimeType.toLowerCase()) {
                case 'audio/opus':
                  {
                    if (opusStereo != null) {
                      offerCodec.parameters!['sprop-stereo'] =
                          opusStereo ? 1 : 0;
                      codecParameters['stereo'] = opusStereo ? 1 : 0;
                    }

                    if (opusFec != null) {
                      offerCodec.parameters!['useinbandfec'] = opusFec ? 1 : 0;
                      codecParameters['useinbandfec'] = opusFec ? 1 : 0;
                    }

                    if (opusDtx != null) {
                      offerCodec.parameters!['usedtx'] = opusDtx ? 1 : 0;
                      codecParameters['usedtx'] = opusDtx ? 1 : 0;
                    }

                    if (opusMaxPlaybackRate != null) {
                      codecParameters['maxplaybackrate'] = opusMaxPlaybackRate;
                    }

                    if (opusMaxAverageBitrate != null) {
                      codecParameters['maxaveragebitrate'] =
                          opusMaxAverageBitrate;
                    }

                    if (opusPtime != null) {
                      offerCodec.parameters!['ptime'] = opusPtime;
                      codecParameters['ptime'] = opusPtime;
                    }

                    break;
                  }

                case 'video/vp8':
                case 'video/vp9':
                case 'video/h264':
                case 'video/h265':
                  {
                    if (videoGoogleStartBitrate != null) {
                      codecParameters['x-google-start-bitrate'] =
                          videoGoogleStartBitrate;
                    }

                    if (videoGoogleMaxBitrate != null) {
                      codecParameters['x-google-max-bitrate'] =
                          videoGoogleMaxBitrate;
                    }

                    if (videoGoogleMinBitrate != null) {
                      codecParameters['x-google-min-bitrate'] =
                          videoGoogleMinBitrate;
                    }

                    break;
                  }
              }
            }

            var fmtp = Fmtp(payload: codec.payloadType, config: '');

            var sortCodec = codecParameters.keys.toList();
            sortCodec.sort();
            for (var key in sortCodec /*Object.keys(codecParameters)*/) {
              if (fmtp.config.isNotEmpty) {
                fmtp.config += ';';
              }

              fmtp.config += '$key=${codecParameters[key]}';
            }

            if (fmtp.config.isNotEmpty) _mediaObject.fmtp!.add(fmtp);

            for (var fb in codec.rtcpFeedback!) {
              _mediaObject.rtcpFb!.add(RtcpFb(
                  payload: codec.payloadType,
                  type: fb.type,
                  subtype: fb.parameter!));
            }
          }

          _mediaObject.payloads = answerRtpParameters.codecs
              .map((RtpCodecParameters codec) => codec.payloadType)
              .join(' ');

          _mediaObject.ext = [];

          for (var ext in answerRtpParameters.headerExtensions!) {
            // Don't add a header extension if not present in the offer.
            var found = (offerMediaObject!.ext /*|| []*/)!
                .any((localExt) => localExt.uri == ext.uri);

            if (!found) continue;

            _mediaObject.ext!.add(Ext(uri: ext.uri, value: ext.id));
          }

          // Allow both 1 byte and 2 bytes length header extensions.
          if (extmapAllowMixed &&
              offerMediaObject!
                  .extmapAllowMixed! /* == 'extmap-allow-mixed'*/) {
            _mediaObject.extmapAllowMixed = true; // 'extmap-allow-mixed';
          }

          // Simulcast.
          if (offerMediaObject!.simulcast != null) {
            _mediaObject.simulcast = Simulcast(
              dir1: 'recv',
              list1: offerMediaObject.simulcast!.list1,
            );

            _mediaObject.rids = [];

            for (var rid in offerMediaObject.rids! /*|| []*/) {
              if (rid.direction != 'send') continue;

              _mediaObject.rids!.add(Rid(id: rid.id, direction: 'recv'));
            }
          }
          // Simulcast (draft version 03).
          else if (offerMediaObject.simulcast_03 != null) {
            // eslint-disable-next-line camelcase
            _mediaObject.simulcast_03 = Simulcast03(
                value: offerMediaObject.simulcast_03!.value
                    .replaceAll('send', 'recv'));

            _mediaObject.rids = [];

            for (var rid in offerMediaObject.rids! /*|| []*/) {
              if (rid.direction != 'send') continue;

              _mediaObject.rids!.add(Rid(id: rid.id, direction: 'recv'));
            }
          }

          _mediaObject.rtcpMux = 'rtcp-mux';
          _mediaObject.rtcpRsize = 'rtcp-rsize';

          if (_planB && _mediaObject.type == 'video') {
            _mediaObject.xGoogleFlag = 'conference';
          }

          break;
        }

      case 'application':
        {
          // New spec.
          // if (typeof offerMediaObject.sctpPort === 'number')
          if (offerMediaObject!.sctpPort is int) {
            _mediaObject.payloads = 'webrtc-datachannel';
            _mediaObject.sctpPort = sctpParameters!.port;
            _mediaObject.maxMessageSize = sctpParameters.maxMessageSize;
          }
          // Old spec.
          else if (offerMediaObject.sctpmap != null) {
            _mediaObject.payloads = sctpParameters!.port.toString();
            _mediaObject.sctpmap = Sctpmap(
              app: 'webrtc-datachannel',
              sctpmapNumber: sctpParameters.port,
              maxMessageSize: sctpParameters.maxMessageSize,
            );
          }

          break;
        }
    }
  }

  void setDtlsRole(String role) //(role: DtlsRole): void
  {
    switch (role) {
      case 'client':
        _mediaObject.setup = 'active';
        break;
      case 'server':
        _mediaObject.setup = 'passive';
        break;
      case 'auto':
        _mediaObject.setup = 'actpass';
        break;
    }
  }
}

class OfferMediaSection extends MediaSection {
  OfferMediaSection(
      {IceParameters? iceParameters,
      List<IceCandidate>? iceCandidates,
      DtlsParameters? dtlsParameters,
      SctpParameters? sctpParameters,
      PlainRtpParameters? plainRtpParameters,
      bool planB = false,
      String? mid,
      String? kind,
      RtpParameters? offerRtpParameters,
      String? streamId,
      String? trackId,
      bool oldDataChannelSpec = false} //:
      // {
      // 	iceParameters?: IceParameters;
      // 	iceCandidates?: IceCandidate[];
      // 	dtlsParameters?: DtlsParameters;
      // 	sctpParameters?: SctpParameters;
      // 	plainRtpParameters?: PlainRtpParameters;
      // 	planB?: boolean;
      // 	mid: string;
      // 	kind: MediaKind | 'application';
      // 	offerRtpParameters?: RtpParameters;
      // 	streamId?: string;
      // 	trackId?: string;
      // 	oldDataChannelSpec?: boolean;
      // }
      )
      : super(
            iceParameters: iceParameters,
            iceCandidates: iceCandidates,
            dtlsParameters: dtlsParameters,
            planB: planB) {
    // super({ iceParameters, iceCandidates, dtlsParameters, planB });

    _mediaObject.mid = mid;
    _mediaObject.type = kind;

    if (plainRtpParameters == null) {
      _mediaObject.connection = Connection(ip: '127.0.0.1', version: 4);

      if (sctpParameters == null) {
        _mediaObject.protocol = 'UDP/TLS/RTP/SAVPF';
      } else {
        _mediaObject.protocol = 'UDP/DTLS/SCTP';
      }

      _mediaObject.port = 7;
    } else {
      _mediaObject.connection = Connection(
        ip: plainRtpParameters.ip,
        version: plainRtpParameters.ipVersion,
      );
      _mediaObject.protocol = 'RTP/AVP';
      _mediaObject.port = plainRtpParameters.port;
    }

    switch (kind) {
      case 'audio':
      case 'video':
        {
          _mediaObject.direction = RtpHeaderDirection.sendonly; //'sendonly';
          _mediaObject.rtp = [];
          _mediaObject.rtcpFb = [];
          _mediaObject.fmtp = [];

          if (!_planB) {
            _mediaObject.msid = '${streamId ?? '-'} $trackId';
          }

          for (var codec in offerRtpParameters!.codecs) {
            var rtp = Rtp(
                payload: codec.payloadType,
                codec: getCodecName(codec),
                rate: codec.clockRate);

            if (codec.channels! > 1) rtp.encoding = codec.channels!;

            _mediaObject.rtp!.add(rtp);

            var fmtp = Fmtp(payload: codec.payloadType, config: '');

            var codeKeys = codec.parameters!.keys.toList();
            codeKeys.sort();
            for (var key in codeKeys /*Object.keys(codec.parameters)*/) {
              if (fmtp.config.isNotEmpty) {
                fmtp.config += ';';
              }

              fmtp.config += '$key=${codec.parameters![key]}';
            }

            if (fmtp.config.isNotEmpty) _mediaObject.fmtp!.add(fmtp);

            for (var fb in codec.rtcpFeedback!) {
              _mediaObject.rtcpFb!.add(RtcpFb(
                payload: codec.payloadType,
                type: fb.type,
                subtype: fb.parameter!,
              ));
            }
          }

          _mediaObject.payloads = offerRtpParameters.codecs
              .map((codec) => codec.payloadType != 0)
              .join(' ');

          _mediaObject.ext = [];

          for (var ext in offerRtpParameters.headerExtensions!) {
            _mediaObject.ext!.add(Ext(uri: ext.uri, value: ext.id));
          }

          _mediaObject.rtcpMux = 'rtcp-mux';
          _mediaObject.rtcpRsize = 'rtcp-rsize';

          var encoding = offerRtpParameters.encodings![0];
          var ssrc = encoding.ssrc;
          var rtxSsrc = (encoding.rtx != null && encoding.rtx!['ssrc'] != null)
              ? encoding.rtx!['ssrc']
              : null;

          _mediaObject.ssrcs = [];
          _mediaObject.ssrcGroups = [];

          if (offerRtpParameters.rtcp!.cname != null &&
              offerRtpParameters.rtcp!.cname!.isNotEmpty) {
            _mediaObject.ssrcs!.add(Ssrc(
              id: ssrc,
              attribute: 'cname',
              value: offerRtpParameters.rtcp!.cname!,
            ));
          }

          if (_planB) {
            _mediaObject.ssrcs!.add(Ssrc(
              id: ssrc,
              attribute: 'msid',
              value: '${(streamId!.isNotEmpty ? streamId : '-')} $trackId',
            ));
          }

          if (rtxSsrc != null) {
            if (offerRtpParameters.rtcp!.cname != null &&
                offerRtpParameters.rtcp!.cname!.isNotEmpty) {
              _mediaObject.ssrcs!.add(Ssrc(
                id: rtxSsrc,
                attribute: 'cname',
                value: offerRtpParameters.rtcp!.cname!,
              ));
            }

            if (_planB) {
              _mediaObject.ssrcs!.add(Ssrc(
                id: rtxSsrc,
                attribute: 'msid',
                value: '${(streamId!.isNotEmpty ? streamId : '-')} $trackId',
              ));
            }

            // Associate original and retransmission SSRCs.
            _mediaObject.ssrcGroups!
                .add(SsrcGroup(semantics: 'FID', ssrcs: '$ssrc $rtxSsrc'));
          }

          break;
        }

      case 'application':
        {
          // New spec.
          if (!oldDataChannelSpec) {
            _mediaObject.payloads = 'webrtc-datachannel';
            _mediaObject.sctpPort = sctpParameters!.port;
            _mediaObject.maxMessageSize = sctpParameters.maxMessageSize;
          }
          // Old spec.
          else {
            _mediaObject.payloads = sctpParameters!.port.toString();
            _mediaObject.sctpmap = Sctpmap(
              app: 'webrtc-datachannel',
              sctpmapNumber: sctpParameters.port,
              maxMessageSize: sctpParameters.maxMessageSize,
            );
          }

          break;
        }
    }
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  @override
  void setDtlsRole(String role) //(role: DtlsRole): void
  {
    // Always 'actpass'.
    _mediaObject.setup = 'actpass';
  }

  void planBReceive(
      RtpParameters offerRtpParameters, String streamId, String trackId
      //:
      // {
      // 	offerRtpParameters: RtpParameters;
      // 	streamId: string;
      // 	trackId: string;
      // }
      ) //: void
  {
    var encoding = offerRtpParameters.encodings![0];
    var ssrc = encoding.ssrc;
    var rtxSsrc = (encoding.rtx != null && encoding.rtx!['ssrc'] != null)
        ? encoding.rtx!['ssrc']
        : null;

    if (offerRtpParameters.rtcp!.cname != null &&
        offerRtpParameters.rtcp!.cname!.isNotEmpty) {
      _mediaObject.ssrcs!.add(Ssrc(
          id: ssrc,
          attribute: 'cname',
          value: offerRtpParameters.rtcp!.cname!));
    }

    _mediaObject.ssrcs!.add(Ssrc(
      id: ssrc,
      attribute: 'msid',
      value: '${streamId.isNotEmpty ? streamId : '-'} $trackId',
    ));

    if (rtxSsrc != null) {
      if (offerRtpParameters.rtcp!.cname != null &&
          offerRtpParameters.rtcp!.cname!.isNotEmpty) {
        _mediaObject.ssrcs!.add(Ssrc(
          id: rtxSsrc,
          attribute: 'cname',
          value: offerRtpParameters.rtcp!.cname!,
        ));
      }

      _mediaObject.ssrcs!.add(Ssrc(
        id: rtxSsrc,
        attribute: 'msid',
        value: '${streamId.isNotEmpty ? streamId : '-'} $trackId',
      ));

      // Associate original and retransmission SSRCs.
      _mediaObject.ssrcGroups!
          .add(SsrcGroup(semantics: 'FID', ssrcs: '$ssrc $rtxSsrc'));
    }
  }

  void planBStopReceiving(
      RtpParameters offerRtpParameters //: { offerRtpParameters: RtpParameters }
      ) //: void
  {
    var encoding = offerRtpParameters.encodings![0];
    var ssrc = encoding.ssrc;
    var rtxSsrc = (encoding.rtx != null && encoding.rtx!['ssrc'] != null)
        ? encoding.rtx!['ssrc']
        : null;

    _mediaObject.ssrcs = _mediaObject.ssrcs!
        .where((s) => s.id != ssrc && s.id != rtxSsrc)
        .toList();

    if (rtxSsrc != null) {
      _mediaObject.ssrcGroups = _mediaObject.ssrcGroups!
          .where((group) => group.ssrcs != '$ssrc $rtxSsrc')
          .toList();
    }
  }
}

String getCodecName(RtpCodecParameters codec) //: string
{
  var mimeTypeRegex = RegExp('^(audio|video)/(.+)' /*, 'i'*/);
  var mimeTypeMatch = mimeTypeRegex.allMatches(codec.mimeType);

  if (mimeTypeMatch == null) throw Exception('invalid codec.mimeType');

  return mimeTypeMatch.toList()[2].group(0)!;
}
