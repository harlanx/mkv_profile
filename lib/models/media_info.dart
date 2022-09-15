import 'dart:convert';

class MediaInfo {
  final Media media;

  MediaInfo({
    required this.media,
  });

  factory MediaInfo.fromRawJson(String str) =>
      MediaInfo.fromJson(json.decode(str));

  factory MediaInfo.fromJson(Map<String, dynamic> json) => MediaInfo(
        media: Media.fromMap(json["media"]),
      );
}

class Media {
  final String ref;
  final GeneralInfo generalInfo;
  final VideoInfo videoInfo;
  final List<AudioInfo> audioInfo;
  final List<TextInfo> textInfo;

  Media({
    required this.ref,
    required this.generalInfo,
    required this.videoInfo,
    required this.audioInfo,
    required this.textInfo,
  });

  factory Media.fromRawJson(String str) => Media.fromMap(json.decode(str));

  factory Media.fromMap(Map<String, dynamic> json) => Media(
        ref: json["@ref"],
        generalInfo: GeneralInfo.fromMap(
            json["track"].singleWhere((item) => item["@type"] == "General")),
        videoInfo: VideoInfo.fromMap(
            json["track"].singleWhere((item) => item["@type"] == "Video")),
        audioInfo: List<AudioInfo>.from(json["track"]
            .where((item) => item["@type"] == "Audio")
            .map((x) => AudioInfo.fromMap(x))),
        textInfo: List<TextInfo>.from(json["track"]
            .where((item) => item["@type"] == "Text")
            .map((x) => TextInfo.fromMap(x))),
      );
}

class GeneralInfo {
  final String title;

  final String fileExtension;
  final String format;
  final int fileSize;

  GeneralInfo({
    required this.title,
    required this.fileExtension,
    required this.format,
    required this.fileSize,
  });

  factory GeneralInfo.fromMap(Map<String, dynamic> json) => GeneralInfo(
        title: json["Title"],
        fileExtension: json["FileExtension"],
        format: json["Format"],
        fileSize: int.parse(json["FileSize"]),
      );
}

class VideoInfo {
  final int id;
  final String format;
  final double duration;
  final int width;
  final int height;
  final double frameRate;
  final int streamSize;
  final String encoding;
  final String? title;
  final String? language;
  final String? defaultFlag;
  final String? forcedFlag;

  VideoInfo({
    required this.id,
    required this.format,
    required this.duration,
    required this.width,
    required this.height,
    required this.frameRate,
    required this.streamSize,
    required this.encoding,
    this.title,
    this.language,
    this.defaultFlag,
    this.forcedFlag,
  });

  factory VideoInfo.fromMap(Map<String, dynamic> json) => VideoInfo(
        id: int.parse(json["StreamOrder"]),
        format: json["Format"],
        duration: double.parse(json["Duration"]),
        width: int.parse(json["Width"]),
        height: int.parse(json["Height"]),
        frameRate: double.parse(json["FrameRate"]),
        streamSize: int.parse(json["StreamSize"]),
        encoding: json["Encoded_Library_Name"],
        title: json["Title"],
        language: json["Language"],
        defaultFlag: json["Default"],
        forcedFlag: json["Forced"],
      );
}

class AudioInfo {
  final int id;
  final String format;
  final double duration;
  final int bitRate;
  final int channels;
  final int samplingRate;
  final int streamSize;
  final String? title;
  final String? language;
  final String? defaultFlag;
  final String? forcedFlag;

  AudioInfo({
    required this.id,
    required this.format,
    required this.duration,
    required this.bitRate,
    required this.channels,
    required this.samplingRate,
    required this.streamSize,
    this.title,
    this.language,
    this.defaultFlag,
    this.forcedFlag,
  });

  factory AudioInfo.fromMap(Map<String, dynamic> json) => AudioInfo(
        id: int.parse(json["StreamOrder"]),
        format: json["Format"],
        duration: double.parse(json["Duration"]),
        bitRate: int.parse(json["BitRate"]),
        channels: int.parse(json["Channels"]),
        samplingRate: int.parse(json["SamplingRate"]),
        streamSize: int.parse(json["StreamSize"]),
        title: json["Title"],
        language: json["Language"],
        defaultFlag: json["Default"],
        forcedFlag: json["Forced"],
      );
}

class TextInfo {
  final int id;
  final int count;
  final String format;
  final double duration;
  final int streamSize;
  final String? title;
  final String? language;
  final String? defaultFlag;
  final String? forcedFlag;

  TextInfo({
    required this.id,
    required this.count,
    required this.format,
    required this.duration,
    required this.streamSize,
    this.title,
    this.language,
    this.defaultFlag,
    this.forcedFlag,
  });

  factory TextInfo.fromMap(Map<String, dynamic> json) => TextInfo(
        id: int.parse(json["StreamOrder"]),
        count: int.parse(json["Count"]),
        format: json["Format"],
        duration: double.parse(json["Duration"]),
        streamSize: int.parse(json["StreamSize"]),
        title: json["Title"],
        language: json["Language"],
        defaultFlag: json["Default"],
        forcedFlag: json["Forced"],
      );
}
