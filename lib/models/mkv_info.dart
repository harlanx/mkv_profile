import 'dart:convert';

class MkvInfo {
  MkvInfo({
    required this.fileName,
    required this.videoInfo,
    required this.audioInfo,
    required this.textInfo,
  });

  final String fileName;
  final List<MkvExtraInfo> videoInfo;
  final List<MkvExtraInfo> audioInfo;
  final List<MkvExtraInfo> textInfo;

  factory MkvInfo.fromJson(String str) {
    final cleanSource = preprocessJsonString(str, 16);
    final Map<String, dynamic> json = jsonDecode(cleanSource);
    final List tracks = json['tracks'];
    return MkvInfo(
      fileName: json['file_name'],
      videoInfo: List<MkvExtraInfo>.from(tracks
          .where((item) => item['type'] == 'video')
          .map((e) => MkvExtraInfo.fromJson(e))),
      audioInfo: List<MkvExtraInfo>.from(tracks
          .where((item) => item['type'] == 'audio')
          .map((e) => MkvExtraInfo.fromJson(e))),
      textInfo: List<MkvExtraInfo>.from(tracks
          .where((item) => item['type'] == 'subtitles')
          .map((e) => MkvExtraInfo.fromJson(e))),
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

class MkvExtraInfo {
  MkvExtraInfo({
    required this.id,
    required this.uid,
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
  final bool defaultFlag;
  final bool originalFlag;
  final bool forcedFlag;
  final bool commentaryFlag;
  final bool hearingImpairedFlag;
  final bool visualImpairedFlag;
  final bool textDescriptionFlag;

  factory MkvExtraInfo.fromJson(Map<String, dynamic> json) {
    final props = json['properties'];
    String? uid = props['uid'];
    uid ??= json.hashCode.toString();
    return MkvExtraInfo(
      id: json['id'],
      uid: uid,
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
