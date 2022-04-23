// const logger = new Logger('RemoteSdp');

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:sdp_transform/sdp_transform.dart' as sdpTransform;

import '../../producer.dart';
import '../../rtpparameters.dart';
import '../../sctpparameters.dart';
import '../../transport.dart';
import 'mediasection.dart';
import '../../utils.dart';

class RemoteSdp {
  // Remote ICE parameters.
  IceParameters? _iceParameters; //?: IceParameters;
  // Remote ICE candidates.
  List<IceCandidate>? _iceCandidates; //?: IceCandidate[];
  // Remote DTLS parameters.
  DtlsParameters? _dtlsParameters; //?: DtlsParameters;
  // Remote SCTP parameters.
  SctpParameters? _sctpParameters; //?: SctpParameters;
  // Parameters for plain RTP (no SRTP nor DTLS no BUNDLE).
  PlainRtpParameters? _plainRtpParameters; //?: PlainRtpParameters;
  // Whether this is Plan-B SDP.
  late bool _planB; //: boolean;
  // MediaSection instances with same order as in the SDP.
  final List<MediaSection> _mediaSections = [];
  // MediaSection indices indexed by MID.
  final Map<String, int> _midToIndex = {};
  // First MID.
  String? _firstMid; //?: string;
  // SDP object.
  late Map<String, dynamic> _sdpObject; //: any;

  RemoteSdp(
      {IceParameters? iceParameters,
      List<IceCandidate>? iceCandidates,
      DtlsParameters? dtlsParameters,
      SctpParameters? sctpParameters,
      PlainRtpParameters? plainRtpParameters,
      planB = false} //:
      // {
      // 	iceParameters?: IceParameters;
      // 	iceCandidates?: IceCandidate[];
      // 	dtlsParameters?: DtlsParameters;
      // 	sctpParameters?: SctpParameters;
      // 	plainRtpParameters?: PlainRtpParameters;
      // 	planB?: boolean;
      // }
      ) {
    _iceParameters = iceParameters;
    _iceCandidates = iceCandidates;
    _dtlsParameters = dtlsParameters;
    _sctpParameters = sctpParameters;
    _plainRtpParameters = plainRtpParameters;
    _planB = planB;
    _sdpObject = {
      'version': 0,
      'origin': {
        'address': '0.0.0.0',
        'ipVer': 4,
        'netType': 'IN',
        'sessionId': 10000,
        'sessionVersion': 0,
        'username': 'mediasoup-client'
      },
      'name': '-',
      'timing': {'start': 0, 'stop': 0},
      'media': []
    };

    // If ICE parameters are given, add ICE-Lite indicator.
    if (iceParameters != null && iceParameters.iceLite!) {
      _sdpObject['icelite'] = 'ice-lite';
    }

    // If DTLS parameters are given, assume WebRTC and BUNDLE.
    if (dtlsParameters != null) {
      _sdpObject['msidSemantic'] = {'semantic': 'WMS', 'token': '*'};

      // NOTE: We take the latest fingerprint.
      var numFingerprints = _dtlsParameters!.fingerprints.length;

      _sdpObject['fingerprint'] = {
        'type': dtlsParameters.fingerprints[numFingerprints - 1].algorithm,
        'hash': dtlsParameters.fingerprints[numFingerprints - 1].value
      };

      _sdpObject['groups'] = [
        {'type': 'BUNDLE', 'mids': ''}
      ];
    }

    // If there are plain RPT parameters, override SDP origin.
    if (plainRtpParameters != null) {
      _sdpObject['origin']['address'] = plainRtpParameters.ip;
      _sdpObject['origin']['ipVer'] = plainRtpParameters.ipVersion;
    }
  }

  void updateIceParameters(IceParameters iceParameters) //: void
  {
    debugger(
        when: false,
        message: 'updateIceParameters() [iceParameters:$iceParameters]');

    _iceParameters = iceParameters;
    _sdpObject['icelite'] = iceParameters.iceLite! ? 'ice-lite' : null;

    for (var mediaSection in _mediaSections) {
      mediaSection.setIceParameters(iceParameters);
    }
  }

  void updateDtlsRole(String role /*: DtlsRole*/) //: void
  {
    debugger(when: false, message: 'updateDtlsRole() [role:$role]');

    _dtlsParameters!.role = role;

    for (var mediaSection in _mediaSections) {
      mediaSection.setDtlsRole(role);
    }
  }

  Map<String, dynamic>
      getNextMediaSectionIdx() //: { idx: number; reuseMid?: string }
  {
    // If a closed media section is found, return its index.
    for (var idx = 0; idx < _mediaSections.length; ++idx) {
      var mediaSection = _mediaSections[idx];

      if (mediaSection.closed) {
        return {'idx': idx, 'reuseMid': mediaSection.mid};
      }
    }

    // If no closed media section is found, return next one.
    return {'idx': _mediaSections.length};
  }

  void send(
      {offerMediaObject,
      String? reuseMid,
      RtpParameters? offerRtpParameters,
      RtpParameters? answerRtpParameters,
      ProducerCodecOptions? codecOptions,
      extmapAllowMixed = false} //:
      // {
      // 	offerMediaObject: any;
      // 	reuseMid?: string;
      // 	offerRtpParameters: RtpParameters;
      // 	answerRtpParameters: RtpParameters;
      // 	codecOptions?: ProducerCodecOptions;
      // 	extmapAllowMixed? : boolean;
      // }
      ) //: void
  {
    var mediaSection = AnswerMediaSection(
        iceParameters: _iceParameters,
        iceCandidates: _iceCandidates,
        dtlsParameters: _dtlsParameters,
        plainRtpParameters: _plainRtpParameters,
        planB: _planB,
        offerMediaObject: offerMediaObject,
        offerRtpParameters: offerRtpParameters,
        answerRtpParameters: answerRtpParameters,
        codecOptions: codecOptions,
        extmapAllowMixed: extmapAllowMixed);

    // Unified-Plan with closed media section replacement.
    if (reuseMid != null && reuseMid.isNotEmpty) {
      _replaceMediaSection(mediaSection, reuseMid: reuseMid);
    }
    // Unified-Plan or Plan-B with different media kind.
    else if (!_midToIndex.containsKey(mediaSection.mid)) {
      _addMediaSection(mediaSection);
    }
    // Plan-B with same media kind.
    else {
      _replaceMediaSection(mediaSection);
    }
  }

  void receive(
      {String? mid,
      String? kind,
      RtpParameters? offerRtpParameters,
      String? streamId,
      String? trackId} //:
      // {
      // 	mid: string;
      // 	kind: MediaKind;
      // 	offerRtpParameters: RtpParameters;
      // 	streamId: string;
      // 	trackId: string;
      // }
      ) //: void
  {
    var idx = _midToIndex[mid];
    OfferMediaSection? mediaSection; //: OfferMediaSection | undefined;

    if (idx != 0) mediaSection = _mediaSections[idx!] as OfferMediaSection;

    // Unified-Plan or different media kind.
    if (mediaSection == null) {
      mediaSection = OfferMediaSection(
          iceParameters: _iceParameters,
          iceCandidates: _iceCandidates,
          dtlsParameters: _dtlsParameters,
          plainRtpParameters: _plainRtpParameters,
          planB: _planB,
          mid: mid,
          kind: kind,
          offerRtpParameters: offerRtpParameters,
          streamId: streamId,
          trackId: trackId);

      // Let's try to recycle a closed media section (if any).
      // NOTE: Yes, we can recycle a closed m=audio section with a new m=video.
      var oldMediaSection = _mediaSections.firstWhereOrNull((m) => (m.closed));

      if (oldMediaSection != null) {
        _replaceMediaSection(mediaSection, reuseMid: oldMediaSection.mid);
      } else {
        _addMediaSection(mediaSection);
      }
    }
    // Plan-B.
    else {
      mediaSection.planBReceive(offerRtpParameters!, streamId!, trackId!);

      _replaceMediaSection(mediaSection);
    }
  }

  void disableMediaSection(String mid) //: void
  {
    var idx = _midToIndex[mid];

    if (idx == null) {
      throw Exception('no media section found with mid $mid');
    }

    var mediaSection = _mediaSections[idx];

    mediaSection.disable();
  }

  void closeMediaSection(String mid) //: void
  {
    var idx = _midToIndex[mid];

    if (idx == null) {
      throw Exception('no media section found with mid $mid');
    }

    var mediaSection = _mediaSections[idx];

    // NOTE: Closing the first m section is a pain since it invalidates the
    // bundled transport, so let's avoid it.
    if (mid == _firstMid) {
      debugger(
          when: false,
          message:
              'closeMediaSection() | cannot close first media section, disabling it instead [mid:$mid]');

      disableMediaSection(mid);

      return;
    }

    mediaSection.close();

    // Regenerate BUNDLE mids.
    _regenerateBundleMids();
  }

  void planBStopReceiving({
    @required String? mid,
    @required RtpParameters? offerRtpParameters,
  } //:
      // {
      // 	mid: string;
      // 	offerRtpParameters: RtpParameters;
      // }
      ) //: void
  {
    var idx = _midToIndex[mid];

    if (idx == null) {
      throw Exception('no media section found with mid $mid');
    }

    var mediaSection = _mediaSections[idx] as OfferMediaSection;

    mediaSection.planBStopReceiving(offerRtpParameters!);
    _replaceMediaSection(mediaSection);
  }

  void sendSctpAssociation(
      offerMediaObject /*: { offerMediaObject: any }*/) //: void
  {
    var mediaSection = AnswerMediaSection(
        iceParameters: _iceParameters,
        iceCandidates: _iceCandidates,
        dtlsParameters: _dtlsParameters,
        sctpParameters: _sctpParameters,
        plainRtpParameters: _plainRtpParameters,
        offerMediaObject: offerMediaObject);

    _addMediaSection(mediaSection);
  }

  void receiveSctpAssociation({oldDataChannelSpec = false} //:
      // { oldDataChannelSpec?: boolean } = {}
      ) //: void
  {
    var mediaSection = OfferMediaSection(
        iceParameters: _iceParameters,
        iceCandidates: _iceCandidates,
        dtlsParameters: _dtlsParameters,
        sctpParameters: _sctpParameters,
        plainRtpParameters: _plainRtpParameters,
        mid: 'datachannel',
        kind: 'application',
        oldDataChannelSpec: oldDataChannelSpec);

    _addMediaSection(mediaSection);
  }

  String getSdp() //: string
  {
    // Increase SDP version.
    _sdpObject['origin']['sessionVersion']++;

    return sdpTransform.write(_sdpObject, null);
  }

  void _addMediaSection(MediaSection newMediaSection) //: void
  {
    if (_firstMid!.isEmpty) _firstMid = newMediaSection.mid;

    // Add to the vector.
    _mediaSections.add(newMediaSection);

    // Add to the map.
    _midToIndex[newMediaSection.mid] = _mediaSections.length - 1;

    // Add to the SDP object.
    _sdpObject['media'].addAll(newMediaSection.getObject());

    // Regenerate BUNDLE mids.
    _regenerateBundleMids();
  }

  void _replaceMediaSection(MediaSection newMediaSection,
      {String? reuseMid}) //: void
  {
    // Store it in the map.
    if (reuseMid is String) {
      var idx = _midToIndex[reuseMid];

      if (idx == null) {
        throw Exception('no media section found for reuseMid $reuseMid');
      }

      var oldMediaSection = _mediaSections[idx];

      // Replace the index in the vector with the new media section.
      _mediaSections[idx] = newMediaSection;

      // Update the map.
      _midToIndex.remove(oldMediaSection.mid);
      _midToIndex[newMediaSection.mid] = idx;

      // Update the SDP object.
      _sdpObject['media'][idx] = newMediaSection.getObject();

      // Regenerate BUNDLE mids.
      _regenerateBundleMids();
    } else {
      var idx = _midToIndex[newMediaSection.mid];

      if (idx == null) {
        throw Exception(
            'no media section found with mid ${newMediaSection.mid}');
      }

      // Replace the index in the vector with the new media section.
      _mediaSections[idx] = newMediaSection;

      // Update the SDP object.
      _sdpObject['media'][idx] = newMediaSection.getObject();
    }
  }

  void _regenerateBundleMids() //: void
  {
    if (_dtlsParameters == null) return;

    _sdpObject['groups'][0].mids = _mediaSections
        .where((MediaSection mediaSection) => !mediaSection.closed)
        .map((MediaSection mediaSection) => mediaSection.mid)
        .join(' ');
  }
}
