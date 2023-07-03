enum TaskStatus {
  processing,
  completed,
  canceled,
  error;
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

  factory OutputInfo.fromJson(Map<String, dynamic> json) {
    return OutputInfo(
      taskStatus: TaskStatus.values.byName(json['taskStatus']),
      outputPath: json['outputPath'],
      log: json['info'],
    );
  }

  Map<String, dynamic> toJson() => {
        'taskStatus': taskStatus.name,
        'outputPath': outputPath,
        'info': log,
      };

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

  factory OutputBasic.fromJson(Map<String, dynamic> json) {
    return OutputBasic(
      title: json['title'],
      path: json['path'],
      profile: json['profile'] as String,
      info: OutputInfo.fromJson(json['info']),
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int),
      duration: Duration(seconds: json['duration']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'path': path,
        'profile': profile,
        'info': info,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'duration': duration.inSeconds,
      };
}
