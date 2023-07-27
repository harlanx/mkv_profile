import 'dart:convert';

class MkvInfo {
  MkvInfo({
    required this.fileName,
    required this.videoInfo,
    required this.audioInfo,
    required this.textInfo,
    required this.attachmentInfo,
  });

  final String fileName;
  final List<MkvTrackInfo> videoInfo;
  final List<MkvTrackInfo> audioInfo;
  final List<MkvTrackInfo> textInfo;
  final List<MkvAttachmentInfo> attachmentInfo;

  factory MkvInfo.fromJson(String str) {
    final cleanSource = preprocessJsonString(str, 16);
    final Map<String, dynamic> json = jsonDecode(cleanSource);
    final List tracks = json['tracks'];
    final List attachments = json['attachments'];
    return MkvInfo(
      fileName: json['file_name'],
      videoInfo: List.from(tracks
          .where((item) => item['type'] == 'video')
          .map((e) => MkvTrackInfo.fromJson(e))),
      audioInfo: List.from(tracks
          .where((item) => item['type'] == 'audio')
          .map((e) => MkvTrackInfo.fromJson(e))),
      textInfo: List.from(tracks
          .where((item) => item['type'] == 'subtitles')
          .map((e) => MkvTrackInfo.fromJson(e))),
      attachmentInfo:
          List.from(attachments.map((e) => MkvAttachmentInfo.fromJson(e))),
    );
  }

  /// Converts the LongInt/BigInt in the json into string so that it won't lose the precision on decode
  static String preprocessJsonString(String jsonString, int maxLength) {
    final numberRegex = RegExp(
        r'(?<![\d."])[+-]?\b\d{' + maxLength.toString() + r',}\b(?![\d."])');
    return jsonString.replaceAllMapped(numberRegex, (match) {
      final numericValue = match.group(0)!; // Assert non-nullability with '!'
      if (!numericValue.startsWith('"') && !numericValue.endsWith('"')) {
        return '"$numericValue"';
      } else {
        return numericValue;
      }
    });
  }
}

class MkvTrackInfo {
  MkvTrackInfo({
    required this.id,
    required this.uid,
    required this.enabledFlag,
    required this.defaultFlag,
    required this.originalFlag,
    required this.forcedFlag,
    required this.commentaryFlag,
    required this.hearingImpairedFlag,
    required this.visualImpairedFlag,
    required this.textDescriptionFlag,
  });

  final int id;
  final String uid;
  final bool enabledFlag;
  final bool defaultFlag;
  final bool originalFlag;
  final bool forcedFlag;
  final bool commentaryFlag;
  final bool hearingImpairedFlag;
  final bool visualImpairedFlag;
  final bool textDescriptionFlag;

  factory MkvTrackInfo.fromJson(Map<String, dynamic> json) {
    final props = json['properties'];
    final uid = props['uid']?.toString() ?? json.hashCode.toString();

    return MkvTrackInfo(
      id: json['id'],
      uid: uid,
      // Value for enabled flag is true by default (even if not specified in metadta)
      enabledFlag: props['enabled_track'] ?? true,
      defaultFlag: props['default_track'] ?? false,
      originalFlag: props['flag_original'] ?? false,
      forcedFlag: props['forced_track'] ?? false,
      commentaryFlag: props['flag_commentary'] ?? false,
      hearingImpairedFlag: props['flag_hearing_impaired'] ?? false,
      visualImpairedFlag: props['flag_visual_impaired'] ?? false,
      textDescriptionFlag: props['flag_text_descriptions'] ?? false,
    );
  }
}

class MkvAttachmentInfo {
  MkvAttachmentInfo({
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

  factory MkvAttachmentInfo.fromJson(Map<String, dynamic> json) {
    final props = json['properties'];
    return MkvAttachmentInfo(
      id: json['id'],
      uid: props['uid'].toString(),
      name: json['file_name'],
      type: json['content_type'],
      size: json['size'],
    );
  }
}
