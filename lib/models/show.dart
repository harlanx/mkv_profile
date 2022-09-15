// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/services/app_services.dart';
import 'package:merge2mkv/utilities/utilities.dart';

abstract class Show {
  late final String title;
  final Directory directory;

  Show({
    required this.directory,
  }) : title = directory.name;
}

class Video extends Equatable {
  final File mainFile;
  final List<Subtitle> subtitles;
  late final MediaInfo info;

  Video({
    required this.mainFile,
    required this.subtitles,
  }) {
    // You can't hot restart DLL so use CLI version when debugging.
    // TODO: Change method to DLL in Production.
    MetadataScanner.scanViaCLI(mainFile).then((value) => info = value);
    //MetadataScanner.scanViaDLL(mainFile).then((value) => info = value);
  }

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
  final File file;
  late LanguageCode language;
  late bool isSDH;

  Subtitle(this.file) {
    language = AppData.languageCodes.identifyTitle(file.title);
    isSDH = _isSDH;
  }

  bool get _isSDH {
    LineSplitter ls = const LineSplitter();
    var content = ls.convert(file.readAsStringSync());
    var result = content.take(500).where(
        (element) => RegExp(r'\-\[(.*?)\]|\-\((.*?)\)').hasMatch(element));
    return result.length > 2;
  }

  void update({
    LanguageCode? language,
    bool? isSDH,
  }) {
    this.language = language ?? this.language;
    this.isSDH = isSDH ?? this.isSDH;
  }
}
