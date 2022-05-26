import 'package:json_annotation/json_annotation.dart';

import '../../rtpparameters.dart';
import '../../transport.dart';

part 'sdpobject.g.dart';

/// sdp 字符串识别对象
@JsonSerializable(explicitToJson: true)
class SdpObject {
  final int version;
  final Origin origin;
  final String name;
  final List<Invalid> invalid;
  final String? description;
  final Timing? timing;
  final Connection? connection;
  final String? iceUfrag;
  final String? icePwd;
  Fingerprint? fingerprint;
  final List<MediaObject> media;
  List<Group> groups;
  MsidSemantic? msidSemantic;
  String? icelite;

  SdpObject({
    required this.version,
    required this.origin,
    required this.name,
    this.invalid = const [],
    this.description,
    this.timing,
    this.connection,
    this.iceUfrag,
    this.icePwd,
    this.fingerprint,
    this.media = const [],
    this.groups = const [],
    this.msidSemantic,
    this.icelite,
  });

  factory SdpObject.fromJson(Map<String, dynamic> json) =>
      _$SdpObjectFromJson(json);

  Map<String, dynamic> toJson() => _$SdpObjectToJson(this);
}

@JsonSerializable()
class Origin {
  final String username;
  final int sessionId;
  int sessionVersion;
  final String netType;
  int ipVer;
  String address;

  Origin({
    required this.username,
    required this.sessionId,
    this.sessionVersion = 0,
    required this.netType,
    required this.ipVer,
    required this.address,
  });

  factory Origin.fromJson(Map<String, dynamic> json) => _$OriginFromJson(json);

  Map<String, dynamic> toJson() => _$OriginToJson(this);
}

@JsonSerializable()
class Invalid {
  final String value;

  Invalid({
    required this.value,
  });

  factory Invalid.fromJson(Map<String, dynamic> json) =>
      _$InvalidFromJson(json);

  Map<String, dynamic> toJson() => _$InvalidToJson(this);
}

@JsonSerializable()
class Timing {
  final int start;
  final int stop;

  Timing({
    required this.start,
    required this.stop,
  });

  factory Timing.fromJson(Map<String, dynamic> json) => _$TimingFromJson(json);

  Map<String, dynamic> toJson() => _$TimingToJson(this);
}

@JsonSerializable()
class Connection {
  final int version;
  final String ip;

  Connection({
    required this.version,
    required this.ip,
  });

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionToJson(this);
}

@JsonSerializable()
class Fingerprint {
  final String type;
  final String hash;

  Fingerprint({
    required this.type,
    required this.hash,
  });

  factory Fingerprint.fromJson(Map<String, dynamic> json) =>
      _$FingerprintFromJson(json);

  Map<String, dynamic> toJson() => _$FingerprintToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MediaObject {
  List<IceCandidate>? candidates;
  String? iceUfrag;
  String? icePwd;
  String? endOfCandidates;
  String? iceOptions;

  /// Always 'actpass'.
  String? setup;
  int? mid;
  int? port;
  RtpHeaderDirection? direction;
  List<Rtp>? rtp;
  List<Fmtp>? fmtp;
  String? type;
  String? protocol;
  String? payloads;
  Connection? connection;
  Rtcp? rtcp;
  List<Ext>? ext;
  String? msid;
  String? rtcpMux;
  List<RtcpFb>? rtcpFb;
  List<Ssrc>? ssrcs;
  List<SsrcGroup>? ssrcGroups;
  Simulcast? simulcast;
  Simulcast03? simulcast_03;
  List<Rid>? rids;
  bool? extmapAllowMixed;
  String? rtcpRsize;
  int? sctpPort;
  int? maxMessageSize;
  Sctpmap? sctpmap;
  String? xGoogleFlag;
  Fingerprint? fingerprint;
  List<RtcpFbTrrInt>? rtcpFbTrrInt;
  List<Crypto>? crypto;
  List<Invalid>? invalid;
  int? ptime;
  int? maxptime;
  int? label;
  List<Bandwidth>? bandwidth;
  String? framerate;
  String? bundleOnly;
  List<Imageattrs>? imageattrs;
  SourceFilter? sourceFilter;
  String? description;

  MediaObject({
    this.candidates = const [],
    this.iceUfrag,
    this.icePwd,
    this.endOfCandidates,
    this.iceOptions,
    this.setup,
    this.mid,
    this.port,
    this.direction,
    this.rtp = const [],
    this.fmtp = const [],
    this.type,
    this.protocol,
    this.payloads,
    this.connection,
    this.rtcp,
    this.ext = const [],
    this.msid,
    this.rtcpMux,
    this.rtcpFb = const [],
    this.ssrcs = const [],
    this.extmapAllowMixed = false,
    this.rids = const [],
    this.simulcast,
    this.simulcast_03,
    this.ssrcGroups = const [],
    this.rtcpRsize,
    this.sctpPort,
    this.maxMessageSize,
    this.sctpmap,
    this.xGoogleFlag,
    this.fingerprint,
    this.rtcpFbTrrInt = const [],
    this.invalid = const [],
    this.ptime,
    this.maxptime,
    this.label,
    this.bandwidth = const [],
    this.framerate,
    this.bundleOnly,
    this.imageattrs = const [],
    this.sourceFilter,
    this.description,
  });

  factory MediaObject.fromJson(Map<String, dynamic> json) =>
      _$MediaObjectFromJson(json);

  Map<String, dynamic> toJson() => _$MediaObjectToJson(this);
}

@JsonSerializable()
class Group {
  final String type;
  String mids;

  Group({
    required this.type,
    required this.mids,
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class MsidSemantic {
  final String semantic;
  final String token;

  MsidSemantic({
    required this.semantic,
    required this.token,
  });

  factory MsidSemantic.fromJson(Map<String, dynamic> json) =>
      _$MsidSemanticFromJson(json);

  Map<String, dynamic> toJson() => _$MsidSemanticToJson(this);
}

@JsonSerializable()
class Rtp {
  final int payload;
  final String codec;
  final int rate;
  int? encoding;

  Rtp({
    required this.payload,
    required this.codec,
    required this.rate,
    this.encoding,
  });

  factory Rtp.fromJson(Map<String, dynamic> json) => _$RtpFromJson(json);

  Map<String, dynamic> toJson() => _$RtpToJson(this);
}

@JsonSerializable()
class Fmtp {
  final int payload;
  String config;

  Fmtp({
    required this.payload,
    required this.config,
  });

  factory Fmtp.fromJson(Map<String, dynamic> json) => _$FmtpFromJson(json);

  Map<String, dynamic> toJson() => _$FmtpToJson(this);
}

@JsonSerializable()
class Rtcp {
  final int port;
  final String netType;
  final int ipVer;
  final String address;

  Rtcp({
    required this.port,
    required this.netType,
    required this.address,
    required this.ipVer,
  });

  factory Rtcp.fromJson(Map<String, dynamic> json) => _$RtcpFromJson(json);

  Map<String, dynamic> toJson() => _$RtcpToJson(this);
}

@JsonSerializable()
class Ext {
  final int? value;
  final String? direction;
  final String? uri;
  final String? config;
  final String? encryptUri;

  Ext({
    this.value,
    this.direction,
    this.uri,
    this.config,
    this.encryptUri,
  });

  factory Ext.fromJson(Map<String, dynamic> json) => _$ExtFromJson(json);

  Map<String, dynamic> toJson() => _$ExtToJson(this);
}

@JsonSerializable()
class RtcpFb {
  final int payload;
  final String type;
  final String subtype;

  RtcpFb({
    required this.payload,
    required this.type,
    this.subtype = '',
  });

  factory RtcpFb.fromJson(Map<String, dynamic> json) => _$RtcpFbFromJson(json);

  Map<String, dynamic> toJson() => _$RtcpFbToJson(this);
}

@JsonSerializable()
class Ssrc {
  final int? id;
  final String? attribute;
  final String value;

  Ssrc({
    this.id,
    this.attribute,
    required this.value,
  });

  factory Ssrc.fromJson(Map<String, dynamic> json) => _$SsrcFromJson(json);

  Map<String, dynamic> toJson() => _$SsrcToJson(this);
}

@JsonSerializable()
class SsrcGroup {
  final String semantics;
  final String ssrcs;

  SsrcGroup({
    required this.semantics,
    required this.ssrcs,
  });

  factory SsrcGroup.fromJson(Map<String, dynamic> json) =>
      _$SsrcGroupFromJson(json);

  Map<String, dynamic> toJson() => _$SsrcGroupToJson(this);
}

@JsonSerializable()
class Sctpmap {
  final String app;
  final int sctpmapNumber;
  final int maxMessageSize;

  Sctpmap({
    required this.app,
    required this.sctpmapNumber,
    required this.maxMessageSize,
  });

  factory Sctpmap.fromJson(Map<String, dynamic> json) =>
      _$SctpmapFromJson(json);

  Map<String, dynamic> toJson() => _$SctpmapToJson(this);
}

@JsonSerializable()
class Rid {
  final int id;
  final String direction;
  final String? params;

  Rid({
    required this.id,
    required this.direction,
    this.params,
  });

  factory Rid.fromJson(Map<String, dynamic> json) => _$RidFromJson(json);

  Map<String, dynamic> toJson() => _$RidToJson(this);
}

@JsonSerializable()
class Simulcast {
  final String? dir1;
  final String? list1;
  final String? dir2;
  final String? list2;

  Simulcast({
    this.dir1,
    this.list1,
    this.dir2,
    this.list2,
  });

  factory Simulcast.fromJson(Map<String, dynamic> json) =>
      _$SimulcastFromJson(json);

  Map<String, dynamic> toJson() => _$SimulcastToJson(this);
}

@JsonSerializable()
class Simulcast03 {
  final String value;

  Simulcast03({required this.value});

  factory Simulcast03.fromJson(Map<String, dynamic> json) =>
      _$Simulcast03FromJson(json);

  Map<String, dynamic> toJson() => _$Simulcast03ToJson(this);
}

@JsonSerializable()
class RtcpFbTrrInt {
  final int payload;
  final int value;

  RtcpFbTrrInt({
    required this.payload,
    required this.value,
  });

  factory RtcpFbTrrInt.fromJson(Map<String, dynamic> json) =>
      _$RtcpFbTrrIntFromJson(json);

  Map<String, dynamic> toJson() => _$RtcpFbTrrIntToJson(this);
}

@JsonSerializable()
class Crypto {
  final int id;
  final String suite;
  final String config;
  dynamic sessionConfig;

  Crypto({
    required this.id,
    required this.suite,
    required this.config,
    this.sessionConfig,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) => _$CryptoFromJson(json);

  Map<String, dynamic> toJson() => _$CryptoToJson(this);
}

@JsonSerializable()
class Bandwidth {
  final String type;
  final int limit;

  Bandwidth({
    required this.type,
    required this.limit,
  });

  factory Bandwidth.fromJson(Map<String, dynamic> json) =>
      _$BandwidthFromJson(json);

  Map<String, dynamic> toJson() => _$BandwidthToJson(this);
}

@JsonSerializable()
class Imageattrs {
  final int pt;
  final String dir1;
  final String attrs1;
  final String dir2;
  final String attrs2;

  Imageattrs({
    required this.pt,
    required this.dir1,
    required this.attrs1,
    required this.dir2,
    required this.attrs2,
  });

  factory Imageattrs.fromJson(Map<String, dynamic> json) =>
      _$ImageattrsFromJson(json);

  Map<String, dynamic> toJson() => _$ImageattrsToJson(this);
}

@JsonSerializable()
class SourceFilter {
  final String filterMode;
  final String netType;
  final String addressTypes;
  final String destAddress;
  final String srcList;

  SourceFilter({
    required this.filterMode,
    required this.netType,
    required this.addressTypes,
    required this.destAddress,
    required this.srcList,
  });

  factory SourceFilter.fromJson(Map<String, dynamic> json) =>
      _$SourceFilterFromJson(json);

  Map<String, dynamic> toJson() => _$SourceFilterToJson(this);
}
