import 'dart:convert';

enum TaskStatus {
  processing,
  completed,
  canceled,
  error;

  String toJson() => name;
  factory TaskStatus.fromJson(String json) => values.byName(json);
}

class OutputInfo {
  OutputInfo({
    required this.taskStatus,
    required this.outputPath,
    required this.log,
  });

  TaskStatus taskStatus;
  String outputPath;
  String log;

  factory OutputInfo.fromJson(String str) {
    Map<String, dynamic> json = jsonDecode(str);
    return OutputInfo(
      taskStatus: TaskStatus.fromJson(json['taskStatus']),
      outputPath: json['outputPath'],
      log: json['info'],
    );
  }

  String toJson() {
    return jsonEncode(
      <String, dynamic>{
        'taskStatus': taskStatus.toJson(),
        'outputPath': outputPath,
        'info': log,
      },
    );
  }

  OutputInfo copyWith({
    TaskStatus? taskStatus,
    String? outputPath,
    String? log,
  }) {
    return OutputInfo(
      taskStatus: taskStatus ?? this.taskStatus,
      outputPath: outputPath ?? this.outputPath,
      log: log ?? this.log,
    );
  }
}

class OutputBasic {
  OutputBasic({
    required this.title,
    required this.path,
    required this.profile,
    required this.info,
    required this.dateTime,
    required this.duration,
  });

  final String title;
  final String path;
  final String profile;
  final OutputInfo info;
  final DateTime dateTime;
  final Duration duration;

  factory OutputBasic.fromJson(String str) {
    Map<String, dynamic> json = jsonDecode(str);
    return OutputBasic(
      title: json['title'],
      path: json['path'],
      profile: json['profile'] as String,
      info: OutputInfo.fromJson(json['info']),
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int),
      duration: Duration(seconds: json['duration']),
    );
  }

  String toJson() {
    return jsonEncode(
      <String, dynamic>{
        'title': title,
        'path': path,
        'profile': profile,
        'info': info.toJson(),
        'dateTime': dateTime.millisecondsSinceEpoch,
        'duration': duration.inSeconds,
      },
    );
  }
}
