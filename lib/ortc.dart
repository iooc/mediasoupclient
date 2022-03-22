// import * as h264 from 'h264-profile-level-id';

import 'rtpparameters.dart';
import 'sctpparameters.dart';

import 'utils.dart' as utils;
import 'h264.dart' as h264;

const RTP_PROBATOR_MID = 'probator';
const RTP_PROBATOR_SSRC = 1234;
const RTP_PROBATOR_CODEC_PAYLOAD_TYPE = 127;

/**
 * Validates RtpCapabilities. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpCapabilities(RtpCapabilities caps) //: void
{
  // if (typeof caps !== 'object')
  // 	throw new TypeError('caps is not an object');

  // codecs is optional. If unset, fill with an empty array.
  // if (caps.codecs && !Array.isArray(caps.codecs))
  // 	throw new TypeError('caps.codecs is not an array');
  // else
  caps.codecs ??= [];

  for (var codec in caps.codecs!) {
    validateRtpCodecCapability(codec);
  }

  // headerExtensions is optional. If unset, fill with an empty array.
  // if (caps.headerExtensions && !Array.isArray(caps.headerExtensions))
  // 	throw new TypeError('caps.headerExtensions is not an array');
  // else
  caps.headerExtensions ??= [];

  for (var ext in caps.headerExtensions!) {
    validateRtpHeaderExtension(ext);
  }
}

/**
 * Validates RtpCodecCapability. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpCodecCapability(RtpCodecCapability codec) //: void
{
  var MimeTypeRegex = RegExp('^(audio|video)/(.+)' /*, 'i'*/);

  // if (typeof codec !== 'object')
  // 	throw new TypeError('codec is not an object');

  // mimeType is mandatory.
  // if (!codec.mimeType || typeof codec.mimeType !== 'string')
  // 	throw new TypeError('missing codec.mimeType');

  var mimeTypeMatch = MimeTypeRegex.allMatches(codec.mimeType).toList();

  // if (mimeTypeMatch==null)
  // 	throw new Exception('invalid codec.mimeType');

  // Just override kind with media component of mimeType.
  codec.kind = mimeTypeMatch[0].group(1)!.toLowerCase(); // as MediaKind;

  // preferredPayloadType is optional.
  // if (codec.preferredPayloadType && typeof codec.preferredPayloadType !== 'number')
  // 	throw new TypeError('invalid codec.preferredPayloadType');

  // clockRate is mandatory.
  // if (typeof codec.clockRate !== 'number')
  // 	throw new TypeError('missing codec.clockRate');

  // channels is optional. If unset, set it to 1 (just if audio).
  if (codec.kind == 'audio') {
    // if (typeof codec.channels !== 'number')
    // codec.channels = 1;
  } else {
    // delete codec.channels;
    codec.channels = null;
  }

  // parameters is optional. If unset, set it to an empty object.
  codec.parameters ??= {};

  var codeKeys = codec.parameters!.keys.toList();
  codeKeys.sort();
  for (var key in codeKeys /*Object.keys(codec.parameters)*/) {
    var value = codec.parameters![key];

    if (value == null) {
      codec.parameters![key] = '';
      value = '';
    }

    // if (typeof value !== 'string' && typeof value !== 'number')
    // {
    // 	throw new TypeError(
    // 		`invalid codec parameter [key:${key}s, value:${value}]`);
    // }

    // Specific parameters validation.
    if (key == 'apt') {
      // if (value is num)
      // 	throw new TypeError('invalid codec apt parameter');
    }
  }

  // rtcpFeedback is optional. If unset, set it to an empty array.
  codec.rtcpFeedback ??= [];

  for (var fb in codec.rtcpFeedback!) {
    validateRtcpFeedback(fb);
  }
}

/**
 * Validates RtcpFeedback. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtcpFeedback(RtcpFeedback fb) //: void
{
  // if (typeof fb !== 'object')
  // 	throw new TypeError('fb is not an object');

  // type is mandatory.
  // if (fb.type==null /*|| typeof fb.type !== 'string'*/)
  // 	throw new Exception('missing fb.type');

  // parameter is optional. If unset set it to an empty string.
  fb.parameter ??= '';
}

/**
 * Validates RtpHeaderExtension. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpHeaderExtension(RtpHeaderExtension ext) //: void
{
  // if (typeof ext !== 'object')
  // 	throw new TypeError('ext is not an object');

  // kind is optional. If unset set it to an empty string.
  ext.kind ??= '';

  if (ext.kind != '' && ext.kind != 'audio' && ext.kind != 'video') {
    throw Exception('invalid ext.kind');
  }

  // uri is mandatory.
  // if (ext.uri==null/* || typeof ext.uri !== 'string'*/)
  // 	throw new Exception('missing ext.uri');

  // preferredId is mandatory.
  // if (typeof ext.preferredId !== 'number')
  // 	throw new TypeError('missing ext.preferredId');

  // preferredEncrypt is optional. If unset set it to false.
  // if (ext.preferredEncrypt|=null && typeof ext.preferredEncrypt !== 'boolean')
  // 	throw new TypeError('invalid ext.preferredEncrypt');
  // else
  // if (!ext.preferredEncrypt!)
  // 	ext.preferredEncrypt = false;

  // direction is optional. If unset set it to sendrecv.
  // if (ext.direction && typeof ext.direction !== 'string')
  // 	throw new TypeError('invalid ext.direction');
  // else
  ext.direction ??= 'sendrecv';
}

/**
 * Validates RtpParameters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpParameters(RtpParameters params) //: void
{
  // if (typeof params !== 'object')
  // 	throw new TypeError('params is not an object');

  // mid is optional.
  // if (params.mid && typeof params.mid !== 'string')
  // 	throw new TypeError('params.mid is not a string');

  // codecs is mandatory.
  // if (!Array.isArray(params.codecs))
  // 	throw new TypeError('missing params.codecs');

  for (var codec in params.codecs) {
    validateRtpCodecParameters(codec);
  }

  // headerExtensions is optional. If unset, fill with an empty array.
  // if (params.headerExtensions && !Array.isArray(params.headerExtensions))
  // 	throw new TypeError('params.headerExtensions is not an array');
  // else
  params.headerExtensions ??= [];

  for (var ext in params.headerExtensions!) {
    validateRtpHeaderExtensionParameters(ext);
  }

  // encodings is optional. If unset, fill with an empty array.
  // if (params.encodings && !Array.isArray(params.encodings))
  // 	throw new TypeError('params.encodings is not an array');
  // else
  params.encodings ??= [];

  for (var encoding in params.encodings!) {
    validateRtpEncodingParameters(encoding);
  }

  // rtcp is optional. If unset, fill with an empty object.
  // if (params.rtcp && typeof params.rtcp !== 'object')
  // 	throw new TypeError('params.rtcp is not an object');
  // else
  params.rtcp ??= RtcpParameters();

  validateRtcpParameters(params.rtcp!);
}

/**
 * Validates RtpCodecParameters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpCodecParameters(RtpCodecParameters codec) //: void
{
  var mimeTypeRegex = RegExp('^(audio|video)/(.+)' /*, 'i'*/);

  // if (typeof codec !== 'object')
  // 	throw new TypeError('codec is not an object');

  // mimeType is mandatory.
  // if (codec.mimeType==null /*|| typeof codec.mimeType !== 'string'*/)
  // 	throw new Exception('missing codec.mimeType');

  var mimeTypeMatch = mimeTypeRegex.allMatches(codec.mimeType).toList();

  // if (mimeTypeMatch==null)
  // 	throw new Exception('invalid codec.mimeType');

  // payloadType is mandatory.
  // if (typeof codec.payloadType !== 'number')
  // 	throw new TypeError('missing codec.payloadType');

  // clockRate is mandatory.
  // if (typeof codec.clockRate !== 'number')
  // 	throw new TypeError('missing codec.clockRate');

  var kind = mimeTypeMatch[1].group(0)!.toLowerCase(); // as MediaKind;

  // channels is optional. If unset, set it to 1 (just if audio).
  if (kind == 'audio') {
    // if (typeof codec.channels !== 'number')
    // 	codec.channels = 1;
  } else {
    // delete codec.channels;
    codec.channels = null;
  }

  // parameters is optional. If unset, set it to an empty object.
  codec.parameters ??= {};
  var codekeys = codec.parameters!.keys.toList();
  codekeys.sort();
  for (var key in codekeys /*Object.keys(codec.parameters)*/) {
    var value = codec.parameters![key];

    if (value == null) {
      codec.parameters![key] = '';
      value = '';
    }

    // if (typeof value !== 'string' && typeof value !== 'number')
    // {
    // 	throw new TypeError(
    // 		`invalid codec parameter [key:${key}s, value:${value}]`);
    // }

    // Specific parameters validation.
    if (key == 'apt') {
      // if (typeof value !== 'number')
      // 	throw new TypeError('invalid codec apt parameter');
    }
  }

  // rtcpFeedback is optional. If unset, set it to an empty array.
  codec.rtcpFeedback ??= [];

  for (var fb in codec.rtcpFeedback!) {
    validateRtcpFeedback(fb);
  }
}

/**
 * Validates RtpHeaderExtensionParameteters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpHeaderExtensionParameters(
    RtpHeaderExtensionParameters ext) //: void
{
  // if (typeof ext !== 'object')
  // 	throw new TypeError('ext is not an object');

  // uri is mandatory.
  // if (ext.uri==null/* || typeof ext.uri !== 'string'*/)
  // 	throw new TypeError('missing ext.uri');

  // id is mandatory.
  // if (typeof ext.id !== 'number')
  // 	throw new TypeError('missing ext.id');

  // encrypt is optional. If unset set it to false.
  // if (ext.encrypt && typeof ext.encrypt !== 'boolean')
  // 	throw new TypeError('invalid ext.encrypt');
  // else
  ext.encrypt ??= false;

  // parameters is optional. If unset, set it to an empty object.
  ext.parameters ??= {};

  var extKeys = ext.parameters!.keys.toList();
  extKeys.sort();
  for (var key in extKeys /*Object.keys(ext.parameters)*/) {
    var value = ext.parameters![key];

    if (value == null) {
      ext.parameters![key] = '';
      value = '';
    }

    // if (typeof value !== 'string' && typeof value !== 'number')
    // 	throw new TypeError('invalid header extension parameter');
  }
}

/**
 * Validates RtpEncodingParameters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtpEncodingParameters(RtpEncodingParameters encoding) //: void
{
  // if (typeof encoding !== 'object')
  // 	throw new TypeError('encoding is not an object');

  // ssrc is optional.
  // if (encoding.ssrc && typeof encoding.ssrc !== 'number')
  // 	throw new TypeError('invalid encoding.ssrc');

  // rid is optional.
  // if (encoding.rid && typeof encoding.rid !== 'string')
  // 	throw new TypeError('invalid encoding.rid');

  // rtx is optional.
  // if (encoding.rtx && typeof encoding.rtx !== 'object')
  // {
  // 	throw new TypeError('invalid encoding.rtx');
  // }
  // else
  //  if (encoding.rtx!=null)
  // {
  // 	// RTX ssrc is mandatory if rtx is present.
  // 	if (typeof encoding.rtx.ssrc !== 'number')
  // 		throw new TypeError('missing encoding.rtx.ssrc');
  // }

  // dtx is optional. If unset set it to false.
  encoding.dtx ??= false;

  // scalabilityMode is optional.
  // if (encoding.scalabilityMode && typeof encoding.scalabilityMode !== 'string')
  // 	throw new TypeError('invalid encoding.scalabilityMode');
}

/**
 * Validates RtcpParameters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateRtcpParameters(RtcpParameters rtcp) //: void
{
  // if (typeof rtcp !== 'object')
  // 	throw new TypeError('rtcp is not an object');

  // cname is optional.
  // if (rtcp.cname && typeof rtcp.cname !== 'string')
  // 	throw new TypeError('invalid rtcp.cname');

  // reducedSize is optional. If unset set it to true.
  if (rtcp.reducedSize == null &&
      !rtcp.reducedSize! /*|| typeof rtcp.reducedSize !== 'boolean'*/) {
    rtcp.reducedSize = true;
  }
}

/**
 * Validates SctpCapabilities. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateSctpCapabilities(SctpCapabilities caps) //: void
{
  // if (typeof caps !== 'object')
  // 	throw new TypeError('caps is not an object');

  // numStreams is mandatory.
  if (caps.numStreams == null /* || typeof caps.numStreams !== 'object'*/) {
    throw Exception('missing caps.numStreams');
  }

  validateNumSctpStreams(caps.numStreams!);
}

/**
 * Validates NumSctpStreams. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateNumSctpStreams(NumSctpStreams numStreams) //: void
{
  // if (typeof numStreams !== 'object')
  // 	throw new TypeError('numStreams is not an object');

  // OS is mandatory.
  // if (typeof numStreams.OS !== 'number')
  // 	throw new TypeError('missing numStreams.OS');

  // MIS is mandatory.
  // if (typeof numStreams.MIS !== 'number')
  // 	throw new TypeError('missing numStreams.MIS');
}

/**
 * Validates SctpParameters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateSctpParameters(SctpParameters params) //: void
{
  // if (typeof params !== 'object')
  // 	throw new TypeError('params is not an object');

  // // port is mandatory.
  // if (typeof params.port !== 'number')
  // 	throw new TypeError('missing params.port');

  // // OS is mandatory.
  // if (typeof params.OS !== 'number')
  // 	throw new TypeError('missing params.OS');

  // // MIS is mandatory.
  // if (typeof params.MIS !== 'number')
  // 	throw new TypeError('missing params.MIS');

  // // maxMessageSize is mandatory.
  // if (typeof params.maxMessageSize !== 'number')
  // 	throw new TypeError('missing params.maxMessageSize');
}

/**
 * Validates SctpStreamParameters. It may modify given data by adding missing
 * fields with default values.
 * It throws if invalid.
 */
void validateSctpStreamParameters(SctpStreamParameters params) //: void
{
  // if (typeof params !== 'object')
  // 	throw new TypeError('params is not an object');

  // // streamId is mandatory.
  // if (typeof params.streamId !== 'number')
  // 	throw new TypeError('missing params.streamId');

  // ordered is optional.
  var orderedGiven = false;

  // if (typeof params.ordered === 'boolean')
  if (params.ordered == null && !params.ordered!) {
    orderedGiven = true;
  } else {
    params.ordered = true;
  }

  // maxPacketLifeTime is optional.
  // if (params.maxPacketLifeTime && typeof params.maxPacketLifeTime !== 'number')
  // 	throw new TypeError('invalid params.maxPacketLifeTime');

  // maxRetransmits is optional.
  // if (params.maxRetransmits && typeof params.maxRetransmits !== 'number')
  // 	throw new TypeError('invalid params.maxRetransmits');

  if (params.maxPacketLifeTime != 0 && params.maxRetransmits != 0) {
    throw Exception('cannot provide both maxPacketLifeTime and maxRetransmits');
  }

  if (orderedGiven &&
      params.ordered! &&
      (params.maxPacketLifeTime != 0 || params.maxRetransmits != 0)) {
    throw Exception(
        'cannot be ordered with maxPacketLifeTime or maxRetransmits');
  } else if (!orderedGiven &&
      (params.maxPacketLifeTime != 0 || params.maxRetransmits != 0)) {
    params.ordered = false;
  }

  // priority is optional.
  // if (params.priority && typeof params.priority !== 'string')
  // 	throw new TypeError('invalid params.priority');

  // // label is optional.
  // if (params.label && typeof params.label !== 'string')
  // 	throw new TypeError('invalid params.label');

  // // protocol is optional.
  // if (params.protocol && typeof params.protocol !== 'string')
  // 	throw new TypeError('invalid params.protocol');
}

/**
 * Generate extended RTP capabilities for sending and receiving.
 */
dynamic getExtendedRtpCapabilities(
    RtpCapabilities localCaps, RtpCapabilities remoteCaps) //: any
{
  var extendedRtpCapabilities =
      RtpCapabilities(codecs: [], headerExtensions: []);

  // Match media codecs and keep the order preferred by remoteCaps.
  for (var remoteCodec in remoteCaps.codecs! /*|| []*/) {
    if (isRtxCodec(remoteCodec)) continue;

    var matchingLocalCodec = (localCaps.codecs /*|| []*/)!
        .firstWhere((RtpCodecCapability localCodec) => (matchCodecs(
              localCodec,
              remoteCodec,
              strict: true,
              modify: true,
            )));

    if (matchingLocalCodec == null) continue;

    dynamic extendedCodec = RtpCodecCapability(matchingLocalCodec.kind,
        matchingLocalCodec.mimeType, matchingLocalCodec.clockRate,
        channels: matchingLocalCodec.channels,
        // localPayloadType     : matchingLocalCodec.preferredPayloadType,
        // localRtxPayloadType  : undefined,
        // remotePayloadType    : remoteCodec.preferredPayloadType,
        // remoteRtxPayloadType : undefined,
        // localParameters      : matchingLocalCodec.parameters,
        // remoteParameters     : remoteCodec.parameters,
        rtcpFeedback: reduceRtcpFeedback(matchingLocalCodec, remoteCodec));
    extendedCodec.localPayloadType = matchingLocalCodec.preferredPayloadType;
    extendedCodec.remotePayloadType = remoteCodec.preferredPayloadType;
    extendedCodec.localParameters = matchingLocalCodec.parameters;
    extendedCodec.remoteParameters = remoteCodec.parameters;

    extendedRtpCapabilities.codecs!.add(extendedCodec);
  }

  // Match RTX codecs.
  for (dynamic extendedCodec in extendedRtpCapabilities.codecs!) {
    var matchingLocalRtxCodec = localCaps.codecs!.firstWhere(
        (RtpCodecCapability localCodec) => (isRtxCodec(localCodec) &&
            localCodec.parameters!['apt'] == extendedCodec.localPayloadType));

    var matchingRemoteRtxCodec = remoteCaps.codecs!.firstWhere(
        (RtpCodecCapability remoteCodec) => (isRtxCodec(remoteCodec) &&
            remoteCodec.parameters!['apt'] == extendedCodec.remotePayloadType));

    if (matchingLocalRtxCodec != null && matchingRemoteRtxCodec != null) {
      extendedCodec.localRtxPayloadType =
          matchingLocalRtxCodec.preferredPayloadType;
      extendedCodec.remoteRtxPayloadType =
          matchingRemoteRtxCodec.preferredPayloadType;
    }
  }

  // Match header extensions.
  for (var remoteExt in remoteCaps.headerExtensions!) {
    var matchingLocalExt = localCaps.headerExtensions!.firstWhere(
        (RtpHeaderExtension localExt) =>
            (matchHeaderExtensions(localExt, remoteExt)));

    if (matchingLocalExt == null) continue;

    dynamic extendedExt = Object();
    extendedExt.kind = remoteExt.kind;
    extendedExt.uri = remoteExt.uri;
    extendedExt.sendId = matchingLocalExt.preferredId;
    extendedExt.recvId = remoteExt.preferredId;
    extendedExt.encrypt = matchingLocalExt.preferredEncrypt;
    extendedExt.direction = 'sendrecv';
    // {
    // 	kind      : remoteExt.kind,
    // 	uri       : remoteExt.uri,
    // 	sendId    : matchingLocalExt.preferredId,
    // 	recvId    : remoteExt.preferredId,
    // 	encrypt   : matchingLocalExt.preferredEncrypt,
    // 	direction : 'sendrecv'
    // };

    switch (remoteExt.direction) {
      case 'sendrecv':
        extendedExt.direction = 'sendrecv';
        break;
      case 'recvonly':
        extendedExt.direction = 'sendonly';
        break;
      case 'sendonly':
        extendedExt.direction = 'recvonly';
        break;
      case 'inactive':
        extendedExt.direction = 'inactive';
        break;
    }

    extendedRtpCapabilities.headerExtensions!.add(extendedExt);
  }

  return extendedRtpCapabilities;
}

/**
 * Generate RTP capabilities for receiving media based on the given extended
 * RTP capabilities.
 */
RtpCapabilities getRecvRtpCapabilities(
    extendedRtpCapabilities) //: RtpCapabilities
{
  var rtpCapabilities = RtpCapabilities(codecs: [], headerExtensions: []);

  for (var extendedCodec in extendedRtpCapabilities.codecs) {
    var codec = RtpCodecCapability(
        extendedCodec.kind, extendedCodec.mimeType, extendedCodec.clockRate,
        preferredPayloadType: extendedCodec.remotePayloadType,
        channels: extendedCodec.channels,
        parameters: extendedCodec.localParameters,
        rtcpFeedback: extendedCodec.rtcpFeedback);
    rtpCapabilities.codecs!.add(codec);

    // Add RTX codec.
    if (extendedCodec.remoteRtxPayloadType == null) continue;

    var rtxCodec = RtpCodecCapability(extendedCodec.kind,
        '${extendedCodec.kind}/rtx', extendedCodec.clockRate,
        preferredPayloadType: extendedCodec.remoteRtxPayloadType,
        parameters: {'apt': extendedCodec.remotePayloadType},
        rtcpFeedback: []);

    rtpCapabilities.codecs!.add(rtxCodec);

    // TODO: In the future, we need to add FEC, CN, etc, codecs.
  }

  for (var extendedExtension in extendedRtpCapabilities.headerExtensions) {
    // Ignore RTP extensions not valid for receiving.
    if (extendedExtension.direction != 'sendrecv' &&
        extendedExtension.direction != 'recvonly') {
      continue;
    }

    var ext = RtpHeaderExtension(
        extendedExtension.uri, extendedExtension.recvId,
        kind: extendedExtension.kind,
        preferredEncrypt: extendedExtension.encrypt,
        direction: extendedExtension.direction);

    rtpCapabilities.headerExtensions!.add(ext);
  }

  return rtpCapabilities;
}

/**
 * Generate RTP parameters of the given kind for sending media.
 * NOTE: mid, encodings and rtcp fields are left empty.
 */
RtpParameters getSendingRtpParameters(
    String kind, extendedRtpCapabilities) //: RtpParameters
{
  var rtpParameters = RtpParameters(
    [],
    mid: null,
    headerExtensions: [],
    encodings: [],
    rtcp: RtcpParameters(),
  );
  // (
  // 	mid              : undefined,
  // 	codecs           : [],
  // 	headerExtensions : [],
  // 	encodings        : [],
  // 	rtcp             : {}
  // );

  for (var extendedCodec in extendedRtpCapabilities.codecs) {
    if (extendedCodec.kind != kind) continue;

    var codec = RtpCodecParameters(extendedCodec.mimeType,
        extendedCodec.localPayloadType, extendedCodec.clockRate,
        channels: extendedCodec.channels,
        parameters: extendedCodec.localParameters,
        rtcpFeedback: extendedCodec.rtcpFeedback);

    rtpParameters.codecs.add(codec);

    // Add RTX codec.
    if (extendedCodec.localRtxPayloadType) {
      var rtxCodec = RtpCodecParameters('${extendedCodec.kind}/rtx',
          extendedCodec.localRtxPayloadType, extendedCodec.clockRate,
          parameters: {'apt': extendedCodec.localPayloadType},
          rtcpFeedback: []);

      rtpParameters.codecs.add(rtxCodec);
    }
  }

  for (var extendedExtension in extendedRtpCapabilities.headerExtensions) {
    // Ignore RTP extensions of a different kind and those not valid for sending.
    if ((extendedExtension.kind && extendedExtension.kind != kind) ||
        (extendedExtension.direction != 'sendrecv' &&
            extendedExtension.direction != 'sendonly')) {
      continue;
    }

    var ext = RtpHeaderExtensionParameters(
      extendedExtension.uri,
      extendedExtension.sendId,
      encrypt: extendedExtension.encrypt,
      parameters: {},
    );
    // (
    // 	uri        : extendedExtension.uri,
    // 	id         : extendedExtension.sendId,
    // 	encrypt    : extendedExtension.encrypt,
    // 	parameters : {}
    // );

    rtpParameters.headerExtensions!.add(ext);
  }

  return rtpParameters;
}

/**
 * Generate RTP parameters of the given kind suitable for the remote SDP answer.
 */
RtpParameters getSendingRemoteRtpParameters(
    String kind, //: MediaKind,
    extendedRtpCapabilities //: any
    ) //: RtpParameters
{
  var rtpParameters = RtpParameters(
    [],
    mid: null,
    headerExtensions: [],
    encodings: [],
    rtcp: RtcpParameters(),
  );

  // (
  // 	mid              : undefined,
  // 	codecs           : [],
  // 	headerExtensions : [],
  // 	encodings        : [],
  // 	rtcp             : {}
  // );

  for (var extendedCodec in extendedRtpCapabilities.codecs) {
    if (extendedCodec.kind != kind) continue;

    var codec = RtpCodecParameters(extendedCodec.mimeType,
        extendedCodec.localPayloadType, extendedCodec.clockRate,
        channels: extendedCodec.channels,
        parameters: extendedCodec.remoteParameters,
        rtcpFeedback: extendedCodec.rtcpFeedback);

    rtpParameters.codecs.add(codec);

    // Add RTX codec.
    if (extendedCodec.localRtxPayloadType) {
      var rtxCodec = RtpCodecParameters(
        '${extendedCodec.kind}/rtx',
        extendedCodec.localRtxPayloadType,
        extendedCodec.clockRate,
        parameters: {'apt': extendedCodec.localPayloadType},
        rtcpFeedback: [],
      );
      // (
      // 	mimeType    : '${extendedCodec.kind}/rtx',
      // 	payloadType : extendedCodec.localRtxPayloadType,
      // 	clockRate   : extendedCodec.clockRate,
      // 	parameters  :
      // 	{
      // 		apt : extendedCodec.localPayloadType
      // 	},
      // 	rtcpFeedback : []
      // );

      rtpParameters.codecs.add(rtxCodec);
    }
  }

  for (var extendedExtension in extendedRtpCapabilities.headerExtensions) {
    // Ignore RTP extensions of a different kind and those not valid for sending.
    if ((extendedExtension.kind && extendedExtension.kind != kind) ||
        (extendedExtension.direction != 'sendrecv' &&
            extendedExtension.direction != 'sendonly')) {
      continue;
    }

    var ext = RtpHeaderExtensionParameters(
        extendedExtension.uri, extendedExtension.sendId,
        encrypt: extendedExtension.encrypt, parameters: {});

    rtpParameters.headerExtensions!.add(ext);
  }

  // Reduce codecs' RTCP feedback. Use Transport-CC if available, REMB otherwise.
  if (rtpParameters.headerExtensions!.any((ext) => (ext.uri ==
      'http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01'))) {
    for (var codec in rtpParameters.codecs) {
      codec.rtcpFeedback = (codec.rtcpFeedback /*|| []*/)!
          .where((RtcpFeedback fb) => fb.type != 'goog-remb')
          .toList();
    }
  } else if (rtpParameters.headerExtensions!.any((ext) => (ext.uri ==
      'http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time'))) {
    for (var codec in rtpParameters.codecs) {
      codec.rtcpFeedback = (codec.rtcpFeedback /*|| []*/)!
          .where((fb) => fb.type != 'transport-cc')
          .toList();
    }
  } else {
    for (var codec in rtpParameters.codecs) {
      codec.rtcpFeedback = (codec.rtcpFeedback /*|| []*/)!
          .where((RtcpFeedback fb) =>
              (fb.type != 'transport-cc' && fb.type != 'goog-remb'))
          .toList();
    }
  }

  return rtpParameters;
}

/**
 * Reduce given codecs by returning an array of codecs "compatible" with the
 * given capability codec. If no capability codec is given, take the first
 * one(s).
 *
 * Given codecs must be generated by ortc.getSendingRtpParameters() or
 * ortc.getSendingRemoteRtpParameters().
 *
 * The returned array of codecs also include a RTX codec if available.
 */
List<RtpCodecParameters> reduceCodecs(
    List<RtpCodecParameters> codecs, //: RtpCodecParameters[],
    RtpCodecCapability capCodec //?: RtpCodecCapability
    ) //: RtpCodecParameters[]
{
  List<RtpCodecParameters> filteredCodecs = [];

  // If no capability codec is given, take the first one (and RTX).
  if (capCodec == null) {
    filteredCodecs.add(codecs[0]);

    if (isRtxCodec(codecs[1] as RtpCodecCapability)) {
      filteredCodecs.add(codecs[1]);
    }
  }
  // Otherwise look for a compatible set of codecs.
  else {
    for (var idx = 0; idx < codecs.length; ++idx) {
      if (matchCodecs(codecs[idx], capCodec)) {
        filteredCodecs.add(codecs[idx]);

        if (isRtxCodec(codecs[idx + 1] as RtpCodecCapability)) {
          filteredCodecs.add(codecs[idx + 1]);
        }

        break;
      }
    }

    if (filteredCodecs.length == 0) {
      throw Exception('no matching codec found');
    }
  }

  return filteredCodecs;
}

/**
 * Create RTP parameters for a Consumer for the RTP probator.
 */
RtpParameters generateProbatorRtpParameters(
    RtpParameters videoRtpParameters //: RtpParameters
    ) //: RtpParameters
{
  // Clone given reference video RTP parameters.
  // videoRtpParameters = utils.clone(videoRtpParameters, {}) as RtpParameters;
  videoRtpParameters = RtpParameters.fromJson(videoRtpParameters.toJson());

  // This may throw.
  validateRtpParameters(videoRtpParameters);

  var rtpParameters = RtpParameters(
    [],
    mid: RTP_PROBATOR_MID,
    headerExtensions: [],
    encodings: [RtpEncodingParameters(ssrc: RTP_PROBATOR_SSRC)],
    rtcp: RtcpParameters(cname: 'probator'),
  );

  rtpParameters.codecs.add(videoRtpParameters.codecs[0]);
  rtpParameters.codecs[0].payloadType = RTP_PROBATOR_CODEC_PAYLOAD_TYPE;
  rtpParameters.headerExtensions = videoRtpParameters.headerExtensions;

  return rtpParameters;
}

/**
 * Whether media can be sent based on the given RTP capabilities.
 */
bool canSend(String kind, extendedRtpCapabilities) //: boolean
{
  return extendedRtpCapabilities.codecs.some((codec) => codec.kind == kind);
}

/**
 * Whether the given RTP parameters can be received with the given RTP
 * capabilities.
 */
bool canReceive(
    RtpParameters rtpParameters, //: RtpParameters,
    extendedRtpCapabilities //: any
    ) //: boolean
{
  // This may throw.
  validateRtpParameters(rtpParameters);

  if (rtpParameters.codecs.length == 0) return false;

  var firstMediaCodec = rtpParameters.codecs[0];

  return (extendedRtpCapabilities.codecs as List)
      .any((codec) => codec.remotePayloadType == firstMediaCodec.payloadType);
}

bool isRtxCodec(
    RtpCodecCapability
        codec /*?: RtpCodecCapability | RtpCodecParameters*/) //: boolean
{
  if (codec == null) return false;

  return RegExp(r'.+\/rtx$').hasMatch(codec.mimeType);

  ///.+\/rtx$/i.test(codec.mimeType);
}

bool matchCodecs(
    aCodec, //: RtpCodecCapability | RtpCodecParameters,
    bCodec, //: RtpCodecCapability | RtpCodecParameters,
    {strict = false,
    modify = false} //= {}
    ) //: boolean
{
  var aMimeType = aCodec.mimeType.toLowerCase();
  var bMimeType = bCodec.mimeType.toLowerCase();

  if (aMimeType != bMimeType) return false;

  if (aCodec.clockRate != bCodec.clockRate) return false;

  if (aCodec.channels != bCodec.channels) return false;

  // Per codec special checks.
  switch (aMimeType) {
    case 'video/h264':
      {
        var aPacketizationMode =
            aCodec.parameters['packetization-mode']; // || 0;
        var bPacketizationMode =
            bCodec.parameters['packetization-mode']; // || 0;
        aPacketizationMode = aPacketizationMode ?? 0;
        bPacketizationMode = bPacketizationMode ?? 0;

        if (aPacketizationMode != bPacketizationMode) return false;

        // If strict matching check profile-level-id.
        if (strict) {
          if (!h264.isSameProfile(aCodec.parameters, bCodec.parameters)) {
            return false;
          }

          var selectedProfileLevelId;

          try {
            selectedProfileLevelId = h264.generateProfileLevelIdForAnswer(
                aCodec.parameters, bCodec.parameters);
          } catch (error) {
            return false;
          }

          if (modify) {
            if (selectedProfileLevelId) {
              aCodec.parameters['profile-level-id'] = selectedProfileLevelId;
              bCodec.parameters['profile-level-id'] = selectedProfileLevelId;
            } else {
              // delete aCodec.parameters['profile-level-id'];
              // delete bCodec.parameters['profile-level-id'];
              aCodec.parameters['profile-level-id'] = null;
              bCodec.parameters['profile-level-id'] = null;
            }
          }
        }

        break;
      }

    case 'video/vp9':
      {
        // If strict matching check profile-id.
        if (strict) {
          var aProfileId = aCodec.parameters['profile-id']; // || 0;
          var bProfileId = bCodec.parameters['profile-id']; // || 0;
          aProfileId = aProfileId ?? 0;
          bProfileId = bProfileId ?? 0;

          if (aProfileId != bProfileId) return false;
        }

        break;
      }
  }

  return true;
}

bool matchHeaderExtensions(
    RtpHeaderExtension aExt, RtpHeaderExtension bExt) //: boolean
{
  if (aExt.kind != null && bExt.kind != null && aExt.kind != bExt.kind) {
    return false;
  }

  if (aExt.uri != bExt.uri) return false;

  return true;
}

List<RtcpFeedback> reduceRtcpFeedback(
  codecA, //: RtpCodecCapability | RtpCodecParameters,
  codecB, //: RtpCodecCapability | RtpCodecParameters
) //: RtcpFeedback[]
{
  List<RtcpFeedback> reducedRtcpFeedback = [];

  for (var aFb in codecA.rtcpFeedback /*|| []*/) {
    var matchingBFb = (codecB.rtcpFeedback /*|| []*/).firstWhere(
        (RtcpFeedback bFb) => (bFb.type == aFb.type &&
            (bFb.parameter == aFb.parameter ||
                (bFb.parameter == null && aFb.parameter == null))));

    if (matchingBFb) reducedRtcpFeedback.add(matchingBFb);
  }

  return reducedRtcpFeedback;
}
