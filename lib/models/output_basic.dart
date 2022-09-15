// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum TaskStatus {
  processing,
  completed,
  canceled,
  error;

  String toJson() => name;
  static TaskStatus fromJson(String json) => values.byName(json);
}

class OutputInfo {
  TaskStatus taskStatus;
  String log;

  OutputInfo({
    required this.taskStatus,
    required this.log,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskStatus': taskStatus.toJson(),
      'info': log,
    };
  }

  factory OutputInfo.fromMap(Map<String, dynamic> json) {
    return OutputInfo(
      taskStatus: TaskStatus.fromJson(json['taskStatus']),
      log: json['info'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OutputInfo.fromJson(String source) =>
      OutputInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  OutputInfo copyWith({
    TaskStatus? taskStatus,
    String? log,
  }) {
    return OutputInfo(
      taskStatus: taskStatus ?? this.taskStatus,
      log: log ?? this.log,
    );
  }
}

class OutputBasic {
  final String title;
  final String path;
  final String profile;
  final OutputInfo info;
  final DateTime dateTime;

  OutputBasic({
    required this.title,
    required this.path,
    required this.profile,
    required this.info,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'path': path,
      'profile': profile,
      'info': info.toJson(),
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory OutputBasic.fromMap(Map<String, dynamic> json) {
    return OutputBasic(
      title: json['title'],
      path: json['path'],
      profile: json['profile'] as String,
      info: OutputInfo.fromJson(json['info']),
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory OutputBasic.fromJson(String source) =>
      OutputBasic.fromMap(json.decode(source) as Map<String, dynamic>);
}
