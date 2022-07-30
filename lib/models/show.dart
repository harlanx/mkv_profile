import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/services/app_services.dart';
import 'package:merge2mkv/utilities/utilities.dart';

abstract class Show extends Equatable {
  late final String title;
  final Directory directory;

  Show({
    required this.directory,
  }) : title = directory.name;

  @override
  List<Object> get props => [title, directory];
}

class Video extends Equatable {
  final File mainFile;
  final List<Subtitle> subtitles;

  const Video({
    required this.mainFile,
    required this.subtitles,
  });

  Future<MediaInfo> get info async => (await MetadataScanner.scan(mainFile));

  @override
  List<Object> get props => [mainFile, subtitles];
}

class Movie extends Show {
  final Video video;

  Movie({
    required Directory directory,
    required this.video,
  }) : super(directory: directory);

  Movie copyWith({
    String? title,
    Directory? directory,
    Video? video,
  }) =>
      Movie(
        directory: directory ?? this.directory,
        video: video ?? this.video,
      );

  @override
  List<Object> get props => [...super.props, video];
}

class Series extends Show {
  final List<Seasons> seasons;

  Series({
    required Directory directory,
    required this.seasons,
  }) : super(directory: directory);

  Series copyWith({
    String? title,
    Directory? directory,
    List<Seasons>? seasons,
  }) =>
      Series(
        directory: directory ?? this.directory,
        seasons: seasons ?? this.seasons,
      );

  @override
  List<Object> get props => [...super.props, seasons];
}

class Seasons {
  final int season;
  final List<Video> videos;

  Seasons({
    required this.season,
    required this.videos,
  });
}

class Subtitle {
  final File sub;
  late final String language;
  late final bool isSDH;

  Subtitle(this.sub) {
    language = _language;
    isSDH = _isSDH;
  }

  bool get _isSDH {
    LineSplitter ls = const LineSplitter();
    var content = ls.convert(sub.readAsStringSync());
    var result = content.take(500).where(
        (element) => RegExp(r'\-\[(.*?)\]|\-\((.*?)\)').hasMatch(element));
    return result.length > 2;
  }

  String get _language =>
      AppData.languageCodes
          .items.firstWhereOrNull((element) => element.englishSplit.any(
              (language) =>
                  sub.title.toLowerCase().contains(language.toLowerCase())))
          ?.alpha2 ??
      'und';
}
