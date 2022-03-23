// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdpobject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdpObject _$SdpObjectFromJson(Map<String, dynamic> json) => SdpObject(
      version: json['version'] as int,
      origin: Origin.fromJson(json['origin'] as Map<String, dynamic>),
      name: json['name'] as String,
      invalid: (json['invalid'] as List<dynamic>?)
              ?.map((e) => Invalid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      description: json['description'] as String?,
      timing: json['timing'] == null
          ? null
          : Timing.fromJson(json['timing'] as Map<String, dynamic>),
      connection: json['connection'] == null
          ? null
          : Connection.fromJson(json['connection'] as Map<String, dynamic>),
      iceUfrag: json['iceUfrag'] as String?,
      icePwd: json['icePwd'] as String?,
      fingerprint: json['fingerprint'] == null
          ? null
          : Fingerprint.fromJson(json['fingerprint'] as Map<String, dynamic>),
      media: (json['media'] as List<dynamic>?)
              ?.map((e) => MediaObject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      msidSemantic: json['msidSemantic'] == null
          ? null
          : MsidSemantic.fromJson(json['msidSemantic'] as Map<String, dynamic>),
      icelite: json['icelite'] as String?,
    );

Map<String, dynamic> _$SdpObjectToJson(SdpObject instance) => <String, dynamic>{
      'version': instance.version,
      'origin': instance.origin.toJson(),
      'name': instance.name,
      'invalid': instance.invalid.map((e) => e.toJson()).toList(),
      'description': instance.description,
      'timing': instance.timing?.toJson(),
      'connection': instance.connection?.toJson(),
      'iceUfrag': instance.iceUfrag,
      'icePwd': instance.icePwd,
      'fingerprint': instance.fingerprint?.toJson(),
      'media': instance.media.map((e) => e.toJson()).toList(),
      'groups': instance.groups.map((e) => e.toJson()).toList(),
      'msidSemantic': instance.msidSemantic?.toJson(),
      'icelite': instance.icelite,
    };

Origin _$OriginFromJson(Map<String, dynamic> json) => Origin(
      username: json['username'] as String,
      sessionId: json['sessionId'] as int,
      sessionVersion: json['sessionVersion'] as int? ?? 0,
      netType: json['netType'] as String,
      ipVer: json['ipVer'] as int,
      address: json['address'] as String,
    );

Map<String, dynamic> _$OriginToJson(Origin instance) => <String, dynamic>{
      'username': instance.username,
      'sessionId': instance.sessionId,
      'sessionVersion': instance.sessionVersion,
      'netType': instance.netType,
      'ipVer': instance.ipVer,
      'address': instance.address,
    };

Invalid _$InvalidFromJson(Map<String, dynamic> json) => Invalid(
      value: json['value'] as String,
    );

Map<String, dynamic> _$InvalidToJson(Invalid instance) => <String, dynamic>{
      'value': instance.value,
    };

Timing _$TimingFromJson(Map<String, dynamic> json) => Timing(
      start: json['start'] as int,
      stop: json['stop'] as int,
    );

Map<String, dynamic> _$TimingToJson(Timing instance) => <String, dynamic>{
      'start': instance.start,
      'stop': instance.stop,
    };

Connection _$ConnectionFromJson(Map<String, dynamic> json) => Connection(
      version: json['version'] as int,
      ip: json['ip'] as String,
    );

Map<String, dynamic> _$ConnectionToJson(Connection instance) =>
    <String, dynamic>{
      'version': instance.version,
      'ip': instance.ip,
    };

Fingerprint _$FingerprintFromJson(Map<String, dynamic> json) => Fingerprint(
      type: json['type'] as String,
      hash: json['hash'] as String,
    );

Map<String, dynamic> _$FingerprintToJson(Fingerprint instance) =>
    <String, dynamic>{
      'type': instance.type,
      'hash': instance.hash,
    };

MediaObject _$MediaObjectFromJson(Map<String, dynamic> json) => MediaObject(
      candidates: (json['candidates'] as List<dynamic>?)
              ?.map((e) => IceCandidate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      iceUfrag: json['iceUfrag'] as String?,
      icePwd: json['icePwd'] as String?,
      endOfCandidates: json['endOfCandidates'] as String?,
      iceOptions: json['iceOptions'] as String?,
      setup: json['setup'] as String?,
      mid: json['mid'] as int?,
      port: json['port'] as int?,
      direction:
          $enumDecodeNullable(_$RtpHeaderDirectionEnumMap, json['direction']),
      rtp: (json['rtp'] as List<dynamic>?)
              ?.map((e) => Rtp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fmtp: (json['fmtp'] as List<dynamic>?)
              ?.map((e) => Fmtp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      type: json['type'] as String?,
      protocol: json['protocol'] as String?,
      payloads: json['payloads'] as String?,
      connection: json['connection'] == null
          ? null
          : Connection.fromJson(json['connection'] as Map<String, dynamic>),
      rtcp: json['rtcp'] == null
          ? null
          : Rtcp.fromJson(json['rtcp'] as Map<String, dynamic>),
      ext: (json['ext'] as List<dynamic>?)
              ?.map((e) => Ext.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      msid: json['msid'] as String?,
      rtcpMux: json['rtcpMux'] as String?,
      rtcpFb: (json['rtcpFb'] as List<dynamic>?)
              ?.map((e) => RtcpFb.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      ssrcs: (json['ssrcs'] as List<dynamic>?)
              ?.map((e) => Ssrc.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      extmapAllowMixed: json['extmapAllowMixed'] as bool? ?? false,
      rids: (json['rids'] as List<dynamic>?)
              ?.map((e) => Rid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      simulcast: json['simulcast'] == null
          ? null
          : Simulcast.fromJson(json['simulcast'] as Map<String, dynamic>),
      simulcast_03: json['simulcast_03'] == null
          ? null
          : Simulcast03.fromJson(json['simulcast_03'] as Map<String, dynamic>),
      ssrcGroups: (json['ssrcGroups'] as List<dynamic>?)
              ?.map((e) => SsrcGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rtcpRsize: json['rtcpRsize'] as String?,
      sctpPort: json['sctpPort'] as int?,
      maxMessageSize: json['maxMessageSize'] as int?,
      sctpmap: json['sctpmap'] == null
          ? null
          : Sctpmap.fromJson(json['sctpmap'] as Map<String, dynamic>),
      xGoogleFlag: json['xGoogleFlag'] as String?,
      fingerprint: json['fingerprint'] == null
          ? null
          : Fingerprint.fromJson(json['fingerprint'] as Map<String, dynamic>),
      rtcpFbTrrInt: (json['rtcpFbTrrInt'] as List<dynamic>?)
              ?.map((e) => RtcpFbTrrInt.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      invalid: (json['invalid'] as List<dynamic>?)
              ?.map((e) => Invalid.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      ptime: json['ptime'] as int?,
      maxptime: json['maxptime'] as int?,
      label: json['label'] as int?,
      bandwidth: (json['bandwidth'] as List<dynamic>?)
              ?.map((e) => Bandwidth.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      framerate: json['framerate'] as String?,
      bundleOnly: json['bundleOnly'] as String?,
      imageattrs: (json['imageattrs'] as List<dynamic>?)
              ?.map((e) => Imageattrs.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sourceFilter: json['sourceFilter'] == null
          ? null
          : SourceFilter.fromJson(json['sourceFilter'] as Map<String, dynamic>),
      description: json['description'] as String?,
    )..crypto = (json['crypto'] as List<dynamic>?)
        ?.map((e) => Crypto.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$MediaObjectToJson(MediaObject instance) =>
    <String, dynamic>{
      'candidates': instance.candidates?.map((e) => e.toJson()).toList(),
      'iceUfrag': instance.iceUfrag,
      'icePwd': instance.icePwd,
      'endOfCandidates': instance.endOfCandidates,
      'iceOptions': instance.iceOptions,
      'setup': instance.setup,
      'mid': instance.mid,
      'port': instance.port,
      'direction': _$RtpHeaderDirectionEnumMap[instance.direction],
      'rtp': instance.rtp?.map((e) => e.toJson()).toList(),
      'fmtp': instance.fmtp?.map((e) => e.toJson()).toList(),
      'type': instance.type,
      'protocol': instance.protocol,
      'payloads': instance.payloads,
      'connection': instance.connection?.toJson(),
      'rtcp': instance.rtcp?.toJson(),
      'ext': instance.ext?.map((e) => e.toJson()).toList(),
      'msid': instance.msid,
      'rtcpMux': instance.rtcpMux,
      'rtcpFb': instance.rtcpFb?.map((e) => e.toJson()).toList(),
      'ssrcs': instance.ssrcs?.map((e) => e.toJson()).toList(),
      'ssrcGroups': instance.ssrcGroups?.map((e) => e.toJson()).toList(),
      'simulcast': instance.simulcast?.toJson(),
      'simulcast_03': instance.simulcast_03?.toJson(),
      'rids': instance.rids?.map((e) => e.toJson()).toList(),
      'extmapAllowMixed': instance.extmapAllowMixed,
      'rtcpRsize': instance.rtcpRsize,
      'sctpPort': instance.sctpPort,
      'maxMessageSize': instance.maxMessageSize,
      'sctpmap': instance.sctpmap?.toJson(),
      'xGoogleFlag': instance.xGoogleFlag,
      'fingerprint': instance.fingerprint?.toJson(),
      'rtcpFbTrrInt': instance.rtcpFbTrrInt?.map((e) => e.toJson()).toList(),
      'crypto': instance.crypto?.map((e) => e.toJson()).toList(),
      'invalid': instance.invalid?.map((e) => e.toJson()).toList(),
      'ptime': instance.ptime,
      'maxptime': instance.maxptime,
      'label': instance.label,
      'bandwidth': instance.bandwidth?.map((e) => e.toJson()).toList(),
      'framerate': instance.framerate,
      'bundleOnly': instance.bundleOnly,
      'imageattrs': instance.imageattrs?.map((e) => e.toJson()).toList(),
      'sourceFilter': instance.sourceFilter?.toJson(),
      'description': instance.description,
    };

const _$RtpHeaderDirectionEnumMap = {
  RtpHeaderDirection.sendrecv: 'sendrecv',
  RtpHeaderDirection.sendonly: 'sendonly',
  RtpHeaderDirection.recvonly: 'recvonly',
  RtpHeaderDirection.inactive: 'inactive',
};

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      type: json['type'] as String,
      mids: json['mids'] as String,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'type': instance.type,
      'mids': instance.mids,
    };

MsidSemantic _$MsidSemanticFromJson(Map<String, dynamic> json) => MsidSemantic(
      semantic: json['semantic'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$MsidSemanticToJson(MsidSemantic instance) =>
    <String, dynamic>{
      'semantic': instance.semantic,
      'token': instance.token,
    };

Rtp _$RtpFromJson(Map<String, dynamic> json) => Rtp(
      payload: json['payload'] as int,
      codec: json['codec'] as String,
      rate: json['rate'] as int,
      encoding: json['encoding'] as int?,
    );

Map<String, dynamic> _$RtpToJson(Rtp instance) => <String, dynamic>{
      'payload': instance.payload,
      'codec': instance.codec,
      'rate': instance.rate,
      'encoding': instance.encoding,
    };

Fmtp _$FmtpFromJson(Map<String, dynamic> json) => Fmtp(
      payload: json['payload'] as int,
      config: json['config'] as String,
    );

Map<String, dynamic> _$FmtpToJson(Fmtp instance) => <String, dynamic>{
      'payload': instance.payload,
      'config': instance.config,
    };

Rtcp _$RtcpFromJson(Map<String, dynamic> json) => Rtcp(
      port: json['port'] as int,
      netType: json['netType'] as String,
      address: json['address'] as String,
      ipVer: json['ipVer'] as int,
    );

Map<String, dynamic> _$RtcpToJson(Rtcp instance) => <String, dynamic>{
      'port': instance.port,
      'netType': instance.netType,
      'ipVer': instance.ipVer,
      'address': instance.address,
    };

Ext _$ExtFromJson(Map<String, dynamic> json) => Ext(
      value: json['value'] as int?,
      direction: json['direction'] as String?,
      uri: json['uri'] as String?,
      config: json['config'] as String?,
      encryptUri: json['encryptUri'] as String?,
    );

Map<String, dynamic> _$ExtToJson(Ext instance) => <String, dynamic>{
      'value': instance.value,
      'direction': instance.direction,
      'uri': instance.uri,
      'config': instance.config,
      'encryptUri': instance.encryptUri,
    };

RtcpFb _$RtcpFbFromJson(Map<String, dynamic> json) => RtcpFb(
      payload: json['payload'] as int,
      type: json['type'] as String,
      subtype: json['subtype'] as String? ?? '',
    );

Map<String, dynamic> _$RtcpFbToJson(RtcpFb instance) => <String, dynamic>{
      'payload': instance.payload,
      'type': instance.type,
      'subtype': instance.subtype,
    };

Ssrc _$SsrcFromJson(Map<String, dynamic> json) => Ssrc(
      id: json['id'] as int?,
      attribute: json['attribute'] as String?,
      value: json['value'] as String,
    );

Map<String, dynamic> _$SsrcToJson(Ssrc instance) => <String, dynamic>{
      'id': instance.id,
      'attribute': instance.attribute,
      'value': instance.value,
    };

SsrcGroup _$SsrcGroupFromJson(Map<String, dynamic> json) => SsrcGroup(
      semantics: json['semantics'] as String,
      ssrcs: json['ssrcs'] as String,
    );

Map<String, dynamic> _$SsrcGroupToJson(SsrcGroup instance) => <String, dynamic>{
      'semantics': instance.semantics,
      'ssrcs': instance.ssrcs,
    };

Sctpmap _$SctpmapFromJson(Map<String, dynamic> json) => Sctpmap(
      app: json['app'] as String,
      sctpmanNumber: json['sctpmanNumber'] as int,
      maxMessageSize: json['maxMessageSize'] as int,
    );

Map<String, dynamic> _$SctpmapToJson(Sctpmap instance) => <String, dynamic>{
      'app': instance.app,
      'sctpmanNumber': instance.sctpmanNumber,
      'maxMessageSize': instance.maxMessageSize,
    };

Rid _$RidFromJson(Map<String, dynamic> json) => Rid(
      id: json['id'] as int,
      direction: json['direction'] as String,
      params: json['params'] as String?,
    );

Map<String, dynamic> _$RidToJson(Rid instance) => <String, dynamic>{
      'id': instance.id,
      'direction': instance.direction,
      'params': instance.params,
    };

Simulcast _$SimulcastFromJson(Map<String, dynamic> json) => Simulcast(
      dir1: json['dir1'] as String?,
      list1: json['list1'] as String?,
      dir2: json['dir2'] as String?,
      list2: json['list2'] as String?,
    );

Map<String, dynamic> _$SimulcastToJson(Simulcast instance) => <String, dynamic>{
      'dir1': instance.dir1,
      'list1': instance.list1,
      'dir2': instance.dir2,
      'list2': instance.list2,
    };

Simulcast03 _$Simulcast03FromJson(Map<String, dynamic> json) => Simulcast03(
      value: json['value'] as String,
    );

Map<String, dynamic> _$Simulcast03ToJson(Simulcast03 instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

RtcpFbTrrInt _$RtcpFbTrrIntFromJson(Map<String, dynamic> json) => RtcpFbTrrInt(
      payload: json['payload'] as int,
      value: json['value'] as int,
    );

Map<String, dynamic> _$RtcpFbTrrIntToJson(RtcpFbTrrInt instance) =>
    <String, dynamic>{
      'payload': instance.payload,
      'value': instance.value,
    };

Crypto _$CryptoFromJson(Map<String, dynamic> json) => Crypto(
      id: json['id'] as int,
      suite: json['suite'] as String,
      config: json['config'] as String,
      sessionConfig: json['sessionConfig'],
    );

Map<String, dynamic> _$CryptoToJson(Crypto instance) => <String, dynamic>{
      'id': instance.id,
      'suite': instance.suite,
      'config': instance.config,
      'sessionConfig': instance.sessionConfig,
    };

Bandwidth _$BandwidthFromJson(Map<String, dynamic> json) => Bandwidth(
      type: json['type'] as String,
      limit: json['limit'] as int,
    );

Map<String, dynamic> _$BandwidthToJson(Bandwidth instance) => <String, dynamic>{
      'type': instance.type,
      'limit': instance.limit,
    };

Imageattrs _$ImageattrsFromJson(Map<String, dynamic> json) => Imageattrs(
      pt: json['pt'] as int,
      dir1: json['dir1'] as String,
      attrs1: json['attrs1'] as String,
      dir2: json['dir2'] as String,
      attrs2: json['attrs2'] as String,
    );

Map<String, dynamic> _$ImageattrsToJson(Imageattrs instance) =>
    <String, dynamic>{
      'pt': instance.pt,
      'dir1': instance.dir1,
      'attrs1': instance.attrs1,
      'dir2': instance.dir2,
      'attrs2': instance.attrs2,
    };

SourceFilter _$SourceFilterFromJson(Map<String, dynamic> json) => SourceFilter(
      filterMode: json['filterMode'] as String,
      netType: json['netType'] as String,
      addressTypes: json['addressTypes'] as String,
      destAddress: json['destAddress'] as String,
      srcList: json['srcList'] as String,
    );

Map<String, dynamic> _$SourceFilterToJson(SourceFilter instance) =>
    <String, dynamic>{
      'filterMode': instance.filterMode,
      'netType': instance.netType,
      'addressTypes': instance.addressTypes,
      'destAddress': instance.destAddress,
      'srcList': instance.srcList,
    };
