import 'dart:convert';

class MediaInfo {
  final Media media;

  MediaInfo({
    required this.media,
  });

  factory MediaInfo.fromRawJson(String str) => MediaInfo.fromJson(json.decode(str));

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
        generalInfo: GeneralInfo.fromMap(json["track"].singleWhere((item) => item["@type"] == "General")),
        videoInfo: VideoInfo.fromMap(json["track"].singleWhere((item) => item["@type"] == "Video")),
        audioInfo: List<AudioInfo>.from(json["track"].where((item) => item["@type"] == "Audio").map((x) => AudioInfo.fromMap(x))),
        textInfo: List<TextInfo>.from(json["track"].where((item) => item["@type"] == "Text").map((x) => TextInfo.fromMap(x))),
      );
}

class GeneralInfo {
  final String fileName;
  final String fileExtension;
  final String format;
  final String fileSizeString;
  final String title;
  final String movie;

  GeneralInfo({
    required this.fileName,
    required this.fileExtension,
    required this.format,
    required this.fileSizeString,
    required this.title,
    required this.movie,
  });

  factory GeneralInfo.fromMap(Map<String, dynamic> json) => GeneralInfo(
        fileName: json["FileName"],
        fileExtension: json["FileExtension"],
        format: json["Format"],
        fileSizeString: json["FileSize_String"],
        title: json["Title"] ?? "",
        movie: json["Movie"] ?? "",
      );
}

class VideoInfo {
  final String format;
  final String durationString;
  final int width;
  final int height;
  final double frameRate;
  final String streamSizeString;
  final String title;
  final String language;
  final String languageString;
  final String languageString3;
  final String defaultTrack;
  final String defaultString;

  VideoInfo({
    required this.format,
    required this.durationString,
    required this.width,
    required this.height,
    required this.frameRate,
    required this.streamSizeString,
    required this.title,
    required this.language,
    required this.languageString,
    required this.languageString3,
    required this.defaultTrack,
    required this.defaultString,
  });

  factory VideoInfo.fromMap(Map<String, dynamic> json) => VideoInfo(
        format: json["Format"],
        durationString: json["Duration_String"],
        width: int.parse(json["Width"]),
        height: int.parse(json["Height"]),
        frameRate: double.parse(json["FrameRate"]),
        streamSizeString: json["StreamSize_String"],
        title: json["Title"] ?? "",
        language: json["Language"] ?? "",
        languageString: json["Language_String"] ?? "",
        languageString3: json["Language_String3"] ?? "",
        defaultTrack: json["Default"] ?? "",
        defaultString: json["Default_String"] ?? "",
      );
}

class AudioInfo {
  final String format;
  final String durationString;
  final String bitRateString;
  final String channels;
  final String streamSizeString;
  final String title;
  final String language;
  final String languageString;
  final String languageString3;
  final String defaultTrack;
  final String defaultString;

  AudioInfo({
    required this.format,
    required this.durationString,
    required this.bitRateString,
    required this.channels,
    required this.streamSizeString,
    required this.title,
    required this.language,
    required this.languageString,
    required this.languageString3,
    required this.defaultTrack,
    required this.defaultString,
  });

  factory AudioInfo.fromMap(Map<String, dynamic> json) => AudioInfo(
        format: json["Format"],
        durationString: json["Duration_String"],
        bitRateString: json["BitRate_String"],
        channels: json["Channels"],
        streamSizeString: json["StreamSize_String"],
        title: json["Title"] ?? "",
        language: json["Language"] ?? "",
        languageString: json["Language_String"] ?? "",
        languageString3: json["Language_String3"] ?? "",
        defaultTrack: json["Default"] ?? "",
        defaultString: json["Default_String"] ?? "",
      );
}

class TextInfo {
  final String format;
  final String durationString;
  final double frameRate;
  final int elementCount;
  final String streamSizeString;
  final String title;
  final String language;
  final String languageString;
  final String languageString3;
  final String defaultTrack;
  final String defaultString;

  TextInfo({
    required this.format,
    required this.durationString,
    required this.frameRate,
    required this.elementCount,
    required this.streamSizeString,
    required this.title,
    required this.language,
    required this.languageString,
    required this.languageString3,
    required this.defaultTrack,
    required this.defaultString,
  });

  factory TextInfo.fromMap(Map<String, dynamic> json) => TextInfo(
        format: json["Format"],
        durationString: json["Duration_String"],
        frameRate: json["FrameRate"],
        elementCount: json["ElementCount"],
        streamSizeString: json["StreamSize_String"],
        title: json["Title"] ?? "",
        language: json["Language"] ?? "",
        languageString: json["Language_String"] ?? "",
        languageString3: json["Language_String3"] ?? "",
        defaultTrack: json["Default"] ?? "",
        defaultString: json["Default_String"] ?? "",
      );
}
