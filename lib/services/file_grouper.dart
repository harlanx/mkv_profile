import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class FileGrouper {
  static Future<GroupingResult> group(PathData pathData) async {
    if (pathData.videos.length == 1) {
      final videoFile = pathData.videos.first;
      return GroupingResult(
        Movie(
            directory: pathData.mainDir,
            video: Video(
              mainFile: videoFile,
            )
              ..addedSubtitles
                  .addAll(await _fetchSubtitles(pathData.otherFiles))
              ..addedAudios.addAll(await _fetchAudios(pathData.otherFiles))
              ..addedChapters.addAll(await _fetchChapters(pathData.otherFiles))
              ..addedAttachments
                  .addAll(await _fetchAttachments(pathData.otherFiles))),
      );
    }

    final Set<String> successGroup = {};
    final Set<String> failGroup = {};
    final Set<String> seasonsStr = {};
    // Get available seasons through directory names;
    for (var dir in pathData.directories) {
      final season = await _fetchSeason(dir.name);
      if (season != null) {
        seasonsStr.add(season);
      }
    }
    // Get available seasons through video file names;
    for (var vid in pathData.videos) {
      final season = await _fetchSeason(vid.title);
      if (season != null) {
        seasonsStr.add(season);
      }
    }

    final List<Season> seasons = [];

    // Assign Season 01 if no seasons found but multiple videos found.
    if (seasonsStr.isEmpty && pathData.videos.isNotEmpty) {
      final List<Video> videos = [];
      for (var v in pathData.videos) {
        final Set<File> relatedFiles = {};
        // Get files with same name as the video
        relatedFiles.addAll(pathData.otherFiles
            .where((element) => element.title == v.title)
            .toSet());
        // Get files with the same folder name as the video
        relatedFiles.addAll(pathData.otherFiles
            .where((element) => element.parent.name == v.title)
            .toSet());

        videos.add(Video(
          mainFile: v,
          season: 1,
          episode: await _fetchEpisode(v.title),
        )
          ..addedSubtitles.addAll(await _fetchSubtitles(relatedFiles.toList()))
          ..addedAudios.addAll(await _fetchAudios(relatedFiles.toList()))
          ..addedChapters.addAll(await _fetchChapters(relatedFiles.toList()))
          ..addedAttachments
              .addAll(await _fetchAttachments(relatedFiles.toList())));
      }
      // Sort by file name
      videos.sort((a, b) => compareNatural(a.mainFile.name, b.mainFile.name));
      seasons.add(Season(number: 1, videos: videos));
      successGroup.add('Season 01');
    } else {
      for (var s in seasonsStr) {
        final seasonInt = int.parse(s.replaceAll(RegExp(r'[^0-9]'), ''));
        final List<Video> videos = [];
        for (var v in pathData.videos) {
          if (v.title.contains(s)) {
            final Set<File> relatedFiles = {};
            // Get files with same name as the video
            relatedFiles.addAll(pathData.otherFiles
                .where((element) => element.title == v.title)
                .toSet());
            // Get files with the same folder name as the video
            relatedFiles.addAll(pathData.otherFiles
                .where((element) => element.parent.name == v.title)
                .toSet());

            videos.add(Video(
              mainFile: v,
              season: seasonInt,
              episode: await _fetchEpisode(v.title),
            )
              ..addedSubtitles
                  .addAll(await _fetchSubtitles(relatedFiles.toList()))
              ..addedAudios.addAll(await _fetchAudios(relatedFiles.toList()))
              ..addedChapters
                  .addAll(await _fetchChapters(relatedFiles.toList()))
              ..addedAttachments
                  .addAll(await _fetchAttachments(relatedFiles.toList())));
          }
        }

        if (videos.isNotEmpty) {
          // Sort by file name
          videos
              .sort((a, b) => compareNatural(a.mainFile.name, b.mainFile.name));
          seasons.add(Season(number: seasonInt, videos: videos));
          successGroup.add('Season $seasonInt');
        } else {
          failGroup.add('Season $seasonInt');
        }
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
    final extractSeason = RegExp(r'Season.\d+|S.\d+', caseSensitive: false);
    if (extractSeason.hasMatch(fileName)) {
      final result = extractSeason.firstMatch(fileName)![0].toString();
      return result;
    } else {
      return null;
    }
  }

  static Future<int?> _fetchEpisode(String fileName) async {
    int? result;
    // Extract the episode string
    final episodeFullStr = RegExp(
      r'Episode.\d+|E.\d+|Episode \d+|E \d+',
      caseSensitive: false,
    ).stringMatch(fileName);
    if (episodeFullStr != null) {
      // Extract the episode number
      final episodeNumStr = RegExp(
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

  static Future<List<AddedTrack>> _fetchChapters(
      List<File> relatedFiles) async {
    return relatedFiles
        .where((element) => AppData.chapterFormats.contains(element.extension))
        .map((e) => AddedTrack(file: e))
        .toList();
  }

  static Future<List<AddedTrack>> _fetchAttachments(
      List<File> relatedFiles) async {
    return relatedFiles
        .where((element) =>
            AppData.fontFormats.contains(element.extension) ||
            AppData.imageFormats.contains(element.extension))
        .map((e) => AddedTrack(file: e))
        .toList();
  }
}

class GroupingResult {
  Show show;
  Set<String> failedGroups;
  GroupingResult(this.show, {this.failedGroups = const {}});
}
