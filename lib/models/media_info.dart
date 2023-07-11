import 'dart:convert';

import '../data/app_data.dart';
import '../models/models.dart';

class MediaInfo {
  MediaInfo({
    required this.ref,
    required this.generalInfo,
    required this.videoInfo,
    required this.audioInfo,
    required this.textInfo,
    required this.menuInfo,
    required this.attachmentInfo,
  });

  final String ref;
  final GeneralInfo generalInfo;
  final List<VideoInfo> videoInfo;
  final List<AudioInfo> audioInfo;
  final List<TextInfo> textInfo;
  final List<MenuInfo> menuInfo;
  final List<AttachmentInfo> attachmentInfo;

  factory MediaInfo.fromJson(String str, MkvInfo? mkvInfo) {
    final Map<String, dynamic> json = jsonDecode(str)['media'];
    return MediaInfo(
      ref: json['@ref'],
      generalInfo: GeneralInfo.fromJson(
          json['track'].singleWhere((item) => item['@type'] == 'General')),
      videoInfo: List<VideoInfo>.from(json['track']
          .where((item) => item['@type'] == 'Video')
          .map((e) => VideoInfo.fromJson(e, mkvInfo))),
      audioInfo: List<AudioInfo>.from(json['track']
          .where((item) => item['@type'] == 'Audio')
          .map((e) => AudioInfo.fromJson(e, mkvInfo))),
      textInfo: List<TextInfo>.from(json['track']
          .where((item) => item['@type'] == 'Text')
          .map((e) => TextInfo.fromJson(e, mkvInfo))),
      menuInfo: List<MenuInfo>.from(json['track']
          .where((item) => item['@type'] == 'Menu')
          .map((e) => MenuInfo.fromJson(e))),
      attachmentInfo: mkvInfo != null
          ? List<AttachmentInfo>.from(
              mkvInfo.attachmentInfo.map((e) => AttachmentInfo.fromMkvInfo(e)))
          : [],
    );
  }
}

class GeneralInfo {
  GeneralInfo({
    this.title,
    required this.fileExtension,
    required this.format,
    required this.fileSize,
  });

  final String? title;
  final String fileExtension;
  final String format;
  final int fileSize;

  factory GeneralInfo.fromJson(Map<String, dynamic> json) {
    return GeneralInfo(
      title: json['Title'],
      fileExtension: json['FileExtension'],
      format: json['Format'],
      fileSize: int.parse(json['FileSize']),
    );
  }
}

class VideoInfo extends TrackProperties {
  VideoInfo({
    required this.id,
    this.uid,
    required this.format,
    required this.duration,
    required this.width,
    required this.height,
    required this.frameRate,
    required this.streamSize,
    required this.encoding,
    String? title,
    bool include = true,
  }) : super(title: title, include: include);

  final int id;
  String? uid;
  final String format;
  final double duration;
  final int width;
  final int height;
  final double frameRate;
  final int streamSize;
  final String encoding;

  factory VideoInfo.fromJson(Map<String, dynamic> json, MkvInfo? mkvInfo) {
    final mkvVideoInfo = mkvInfo?.videoInfo
        .singleWhere((video) => video.id == int.parse(json['StreamOrder']));
    return VideoInfo(
      id: int.parse(json['StreamOrder']),
      uid: mkvVideoInfo?.uid,
      format: json['Format'],
      duration: double.parse(json['Duration']),
      width: int.parse(json['Width']),
      height: int.parse(json['Height']),
      frameRate: double.parse(json['FrameRate']),
      streamSize: int.parse(json['StreamSize']),
      encoding: json['Encoded_Library_Name'] ?? json['Format_Commercial'],
      title: json['Title'],
    )
      ..language = AppData.languageCodes
          .identifyByCode(json['Language_String3'], json['Language'])
      ..update(
        isDefault: mkvVideoInfo?.defaultFlag ?? false,
        isOriginal: mkvVideoInfo?.originalFlag ?? false,
        isForced: mkvVideoInfo?.forcedFlag ?? false,
        isCommentary: mkvVideoInfo?.commentaryFlag ?? false,
        isHearingImpaired: mkvVideoInfo?.hearingImpairedFlag ?? false,
        isVisualImpaired: mkvVideoInfo?.visualImpairedFlag ?? false,
        isTextDescription: mkvVideoInfo?.textDescriptionFlag ?? false,
      );
  }
}

class AudioInfo extends TrackProperties {
  AudioInfo({
    required this.id,
    this.uid,
    required this.format,
    required this.duration,
    required this.bitRate,
    required this.channels,
    required this.samplingRate,
    String? title,
    bool include = true,
  }) : super(title: title, include: include);

  final int id;
  String? uid;
  final String format;
  final double duration;
  final int bitRate;
  final int channels;
  final int samplingRate;

  factory AudioInfo.fromJson(Map<String, dynamic> json, MkvInfo? mkvInfo) {
    final mkvAudioInfo = mkvInfo?.audioInfo.singleWhere((audio) =>
        audio.id == int.parse(json['StreamOrder'] ?? json['StreamKindID']));

    return AudioInfo(
      id: int.parse(json['StreamOrder'] ?? json['StreamKindID']),
      uid: mkvAudioInfo?.uid,
      format: json['Format'],
      duration: double.parse(json['Duration']),
      bitRate: int.parse(json['BitRate']),
      channels: int.parse(json['Channels']),
      samplingRate: int.parse(json['SamplingRate']),
      title: json['Title'],
    )
      ..language = AppData.languageCodes
          .identifyByCode(json['Language_String3'], json['Language'])
      ..update(
        isDefault: mkvAudioInfo?.defaultFlag ?? false,
        isOriginal: mkvAudioInfo?.originalFlag ?? false,
        isForced: mkvAudioInfo?.forcedFlag ?? false,
        isCommentary: mkvAudioInfo?.commentaryFlag ?? false,
        isHearingImpaired: mkvAudioInfo?.hearingImpairedFlag ?? false,
        isVisualImpaired: mkvAudioInfo?.visualImpairedFlag ?? false,
        isTextDescription: mkvAudioInfo?.textDescriptionFlag ?? false,
      );
  }
}

class TextInfo extends TrackProperties {
  TextInfo({
    required this.id,
    this.uid,
    required this.format,
    String? title,
    bool include = true,
  }) : super(title: title, include: include);

  final int id;
  String? uid;
  final String format;

  factory TextInfo.fromJson(Map<String, dynamic> json, MkvInfo? mkvInfo) {
    final mkvTextInfo = mkvInfo?.textInfo.singleWhere((text) =>
        text.id == int.parse(json['StreamOrder'] ?? json['StreamKindID']));
    return TextInfo(
      id: int.parse(json['StreamOrder'] ?? json['StreamKindID']),
      uid: mkvTextInfo?.uid,
      format: json['Format'],
      title: json['Title'],
    )
      ..language = AppData.languageCodes
          .identifyByCode(json['Language_String3'], json['Language'])
      ..update(
        isDefault: mkvTextInfo?.defaultFlag ?? false,
        isOriginal: mkvTextInfo?.originalFlag ?? false,
        isForced: mkvTextInfo?.forcedFlag ?? false,
        isCommentary: mkvTextInfo?.commentaryFlag ?? false,
        isHearingImpaired: mkvTextInfo?.hearingImpairedFlag ?? false,
        isVisualImpaired: mkvTextInfo?.visualImpairedFlag ?? false,
        isTextDescription: mkvTextInfo?.textDescriptionFlag ?? false,
      );
  }
}

class MenuInfo {
  MenuInfo({
    required this.id,
    required this.uid,
    required this.count,
    required this.chapters,
  });

  final int id;
  final String uid;
  final int count;
  List<ChapterInfo> chapters;

  factory MenuInfo.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawChapters = json['extra'];
    // Remove non chapter entries
    rawChapters.removeWhere(
        (key, value) => !RegExp(r'_\d{2}_\d{2}_\d{2}_\d{3}').hasMatch(key));
    return MenuInfo(
      id: int.parse(json['StreamOrder'] ?? json['StreamKindID']),
      uid: json.hashCode.toString(),
      count: int.parse(json['Count']),
      chapters: List<ChapterInfo>.from(
          rawChapters.entries.map((e) => ChapterInfo.fromJson(e))),
    );
  }
}

class ChapterInfo {
  ChapterInfo({
    required this.title,
    required this.startsStamp,
  });

  final String title;
  final Duration startsStamp;

  factory ChapterInfo.fromJson(MapEntry<String, dynamic> jsonEntry) {
    return ChapterInfo(
      title: jsonEntry.value,
      startsStamp: _parseDurationString(jsonEntry.key),
    );
  }

  // static String _parseStringTitle(String inputString) {
  //   final firstColonIndex = inputString.indexOf(':');
  //   return inputString.substring(firstColonIndex + 1);
  // }

  static Duration _parseDurationString(String inputString) {
    final durations = inputString.substring(1).split('_');

    return Duration(
      hours: int.parse(durations[0]),
      minutes: int.parse(durations[1]),
      seconds: int.parse(durations[2]),
      milliseconds: int.parse(durations[3]),
    );
  }
}

class AttachmentInfo {
  AttachmentInfo({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.size,
  });

  final int id;
  final String uid;
  final String name;
  final String type;
  final int size;

  factory AttachmentInfo.fromMkvInfo(MkvAttachmentInfo attachmentInfo) {
    return AttachmentInfo(
      id: attachmentInfo.id,
      uid: attachmentInfo.uid,
      name: attachmentInfo.name,
      type: attachmentInfo.type,
      size: attachmentInfo.size,
    );
  }
}
