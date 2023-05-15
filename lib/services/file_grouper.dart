import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class FileGrouper {
  static Future<GroupingResult> group(PathData pathData) async {
    if (pathData.videos.length == 1) {
      var videoFile = pathData.videos.first;
      return GroupingResult(
        Movie(
          directory: pathData.mainDir,
          video: Video(
            mainFile: videoFile,
          )
            ..addedSubtitles.addAll(await _fetchSubtitles(pathData.otherFiles))
            ..addedAudios.addAll(await _fetchAudios(pathData.otherFiles))
            ..chapterFiles.addAll(await _fetchChapters(pathData.otherFiles))
            ..fontFiles.addAll(await _fetchFonts(pathData.otherFiles))
            ..imageFiles.addAll(await _fetchImages(pathData.otherFiles)),
        ),
      );
    }

    Set<String> successGroup = {};
    Set<String> failGroup = {};
    Set<String> seasonsStr = {};
    // Get available seasons through directory names;
    for (var dir in pathData.directories) {
      var season = await _fetchSeason(dir.name);
      if (season != null) {
        seasonsStr.add(season);
      }
    }
    // Get available seasons through video file names;
    for (var vid in pathData.videos) {
      var season = await _fetchSeason(vid.title);
      if (season != null) {
        seasonsStr.add(season);
      }
    }

    List<Season> seasons = [];
    for (var s in seasonsStr) {
      int seasonInt = int.parse(s.replaceAll(RegExp(r'[^0-9]'), ''));
      List<Video> videos = [];
      for (var v in pathData.videos) {
        if (v.title.contains(s)) {
          Set<File> relatedFiles = {};
          // Get files with same name as the video
          relatedFiles.addAll(pathData.otherFiles
              .where((element) => element.title == v.title)
              .toSet());
          // Get files with the same folder name as the video
          relatedFiles.addAll(pathData.otherFiles
              .where((element) => element.parent.name == v.title)
              .toSet());

          videos.add(
            Video(
              mainFile: v,
              season: seasonInt,
              episode: await _fetchEpisode(v.title),
            )
              ..addedSubtitles
                  .addAll(await _fetchSubtitles(relatedFiles.toList()))
              ..addedAudios.addAll(await _fetchAudios(relatedFiles.toList()))
              ..chapterFiles.addAll(await _fetchChapters(relatedFiles.toList()))
              ..fontFiles.addAll(await _fetchFonts(relatedFiles.toList()))
              ..imageFiles.addAll(await _fetchImages(relatedFiles.toList())),
          );
        }
      }
      // If no subtitle file found for the video, remove it from the list
      // Remove this line if planning on managing mkv files.
      //videos.removeWhere((element) => element.addedSubtitles.isEmpty);

      if (videos.isNotEmpty) {
        // Sort by file name
        videos.sort((a, b) => compareNatural(a.mainFile.name, b.mainFile.name));
        seasons.add(Season(number: seasonInt, videos: videos));
        successGroup.add('Season $seasonInt');
      } else {
        failGroup.add('Season $seasonInt');
      }
    }

    if (seasons.isEmpty) {
      throw 'No correlation between files has been found.';
    }

    return GroupingResult(
      Series(
        directory: pathData.mainDir,
        seasons: seasons,
      ),
      failedGroups: Set.from(failGroup.difference(successGroup)),
    );
  }

  static Future<String?> _fetchSeason(String fileName) async {
    RegExp extractSeason = RegExp(r'Season.\d+|S.\d+', caseSensitive: false);
    if (extractSeason.hasMatch(fileName)) {
      var result = extractSeason.firstMatch(fileName)![0].toString();
      return result;
    } else {
      return null;
    }
  }

  static Future<int?> _fetchEpisode(String fileName) async {
    int? result;
    // Extract the episode string
    var episodeFullStr = RegExp(
      r'Episode.\d+|E.\d+|Episode \d+|E \d+',
      caseSensitive: false,
    ).stringMatch(fileName);
    if (episodeFullStr != null) {
      // Extract the episode number
      var episodeNumStr = RegExp(
        r'\d+',
        caseSensitive: false,
      ).stringMatch(episodeFullStr);
      if (episodeNumStr != null) {
        result = int.parse(episodeNumStr);
      }
    }

    return result;
  }

  static Future<List<AddedTrack>> _fetchAudios(List<File> relatedFiles) async {
    return relatedFiles
        .where((element) => AppData.audioFormats.contains(element.extension))
        .map((e) => AddedTrack(file: e))
        .toList();
  }

  static Future<List<AddedTrack>> _fetchSubtitles(
      List<File> relatedFiles) async {
    return relatedFiles
        .where((element) => AppData.subtitleFormats.contains(element.extension))
        .map((e) => AddedTrack(file: e))
        .toList();
  }

  static Future<List<File>> _fetchChapters(List<File> relatedFiles) async {
    return relatedFiles
        .where((element) => AppData.chapterFormats.contains(element.extension))
        .map((e) => e)
        .toList();
  }

  static Future<List<File>> _fetchFonts(List<File> relatedFiles) async {
    return relatedFiles
        .where((element) => AppData.fontFormats.contains(element.extension))
        .map((e) => e)
        .toList();
  }

  static Future<List<File>> _fetchImages(List<File> relatedFiles) async {
    return relatedFiles
        .where((element) => AppData.imageFormats.contains(element.extension))
        .map((e) => e)
        .toList();
  }
}

class GroupingResult {
  Show show;
  Set<String> failedGroups;
  GroupingResult(this.show, {this.failedGroups = const {}});
}
