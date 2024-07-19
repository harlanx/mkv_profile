import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class FileGrouper {
  static Future<GroupingResult> group(PathData pathData) async {
    // Movie
    if (pathData.videos.length == 1) {
      final video = pathData.videos.first;
      return GroupingResult(
        Movie(
            directory: pathData.mainDir,
            video: Video(
              mainFile: video,
            )
              ..addedSubtitles
                  .addAll(await _fetchSubtitles(pathData.otherFiles))
              ..addedAudios.addAll(await _fetchAudios(pathData.otherFiles))
              ..addedChapters.addAll(await _fetchChapters(pathData.otherFiles))
              ..addedAttachments
                  .addAll(await _fetchAttachments(pathData.otherFiles))),
      );
    }

    // Series
    final Set<String> successGroup = {};
    final Set<String> failGroup = {};
    final Set<int> seasonNumbers = {};
    // Get available seasons through directory names;
    for (var dir in pathData.directories) {
      final season = await _fetchSeason(dir.name);
      if (season != null) {
        seasonNumbers.add(season);
      }
    }
    // Get available seasons through video file names;
    for (var vid in pathData.videos) {
      final season = await _fetchSeason(vid.title);
      if (season != null) {
        seasonNumbers.add(season);
      }
    }

    final List<Season> seasons = [];

    // Assign Season 01 if no seasons found but multiple videos found.
    if (seasonNumbers.isEmpty && pathData.videos.isNotEmpty) {
      const seasonNumber = 1;
      final List<Video> videos = [];
      for (var v in pathData.videos) {
        final videoEpisode = await _fetchEpisode(v.title);
        final Set<File> relatedFiles = {};
        // Get files with same name as the video
        relatedFiles.addAll(
            pathData.otherFiles.where((file) => file.title == v.title).toSet());
        // Get files with the same folder name as the video
        relatedFiles.addAll(pathData.otherFiles
            .where((file) => file.parent.name == v.title)
            .toSet());
        // Get files using S00E00 pattern
        final sePattern = RegExp(r'S\d{2}E\d{2}');
        relatedFiles.addAll(pathData.otherFiles.where((file) {
          final otherFileMatch = sePattern.firstMatch(file.title);
          final videoFileMatch = sePattern.firstMatch(v.title);
          if (otherFileMatch == null || videoFileMatch == null) {
            return false;
          }
          return otherFileMatch[0] == videoFileMatch[0];
        }).toSet());

        // Get files using season number in path and episode number in file title
        for (var otherFile in pathData.otherFiles) {
          final otherFileSeason = await _fetchSeason(otherFile.path);
          final otherFileEpisode = await _fetchEpisode(otherFile.title);
          if (otherFileSeason != null && otherFileEpisode != null) {
            if (seasonNumber == otherFileSeason &&
                videoEpisode == otherFileEpisode) {
              relatedFiles.add(otherFile);
            }
          }
        }

        videos.add(Video(
          mainFile: v,
          season: seasonNumber,
          episode: videoEpisode,
        )
          ..addedSubtitles.addAll(await _fetchSubtitles(relatedFiles.toList()))
          ..addedAudios.addAll(await _fetchAudios(relatedFiles.toList()))
          ..addedChapters.addAll(await _fetchChapters(relatedFiles.toList()))
          ..addedAttachments
              .addAll(await _fetchAttachments(relatedFiles.toList())));
      }
      // Sort by file name
      videos.sort((a, b) => compareNatural(a.mainFile.name, b.mainFile.name));
      seasons.add(Season(number: seasonNumber, videos: videos));
      successGroup.add('Season 01');
    } else {
      // Group files with detected season numbers
      for (var seasonNumber in seasonNumbers) {
        final List<Video> videos = [];
        final season = seasonNumber.toString().padLeft(2, '0');
        final seasonPattern = RegExp(
            'Season$season+|Season $season+|Season.$season+|S$season+|S.$season+|S $season+',
            caseSensitive: false);
        for (var v in pathData.videos) {
          if (v.path.contains(seasonPattern)) {
            final videoEpisode = await _fetchEpisode(v.title);
            final Set<File> relatedFiles = {};
            // Get files with same name as the video
            relatedFiles.addAll(pathData.otherFiles
                .where((element) => element.title == v.title)
                .toSet());
            // Get files with the same folder name as the video
            relatedFiles.addAll(pathData.otherFiles
                .where((element) => element.parent.name == v.title)
                .toSet());
            // Get files using S00E00 pattern
            final sePattern = RegExp(r'S\d{2}E\d{2}');
            relatedFiles.addAll(pathData.otherFiles.where((file) {
              final otherFileMatch = sePattern.firstMatch(file.title);
              final videoFileMatch = sePattern.firstMatch(v.title);
              if (otherFileMatch == null || videoFileMatch == null) {
                return false;
              }
              return otherFileMatch[0] == videoFileMatch[0];
            }).toSet());

            // Get files using season number in path and episode number in file title
            for (var otherFile in pathData.otherFiles) {
              final otherFileSeason = await _fetchSeason(otherFile.parent.path);
              final otherFileEpisode = await _fetchEpisode(otherFile.title);
              if (otherFileSeason != null && otherFileEpisode != null) {
                if (seasonNumber == otherFileSeason &&
                    videoEpisode == otherFileEpisode) {
                  relatedFiles.add(otherFile);
                }
              }
            }

            videos.add(Video(
              mainFile: v,
              season: seasonNumber,
              episode: videoEpisode,
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
          seasons.add(Season(number: seasonNumber, videos: videos));
          successGroup.add('Season $seasonNumber');
        } else {
          failGroup.add('Season $seasonNumber');
        }
      }
    }

    if (seasons.isEmpty) {
      throw 'No correlation between files has been detected.';
    }

    return GroupingResult(
      Series(
        directory: pathData.mainDir,
        seasons: seasons,
      ),
      failedGroups: Set.from(failGroup.difference(successGroup)),
    );
  }

  static Future<int?> _fetchSeason(String text) async {
    int? result;
    // Extract the season string
    final seasonPattern = RegExp(
      r'Season.\d+|\bS.\d+|Season \d+|\bS \d+',
      caseSensitive: false,
    );
    final seasonMatch = seasonPattern.stringMatch(text);
    if (seasonMatch != null) {
      // Extract the season number
      final numberPattern = RegExp(r'\d+', caseSensitive: false);
      final numberMatch = numberPattern.stringMatch(seasonMatch);
      if (numberMatch != null) {
        // Parse season number string to int
        result = int.parse(numberMatch);
      }
    }
    return result;
  }

  static Future<int?> _fetchEpisode(String text) async {
    int? result;
    // Extract the episode string
    final episodePattern = RegExp(
      r'Episode.\d+|E.\d+|Episode \d+|E \d+|(?<!Season\s|S\s)-?\b\d{2}\b',
      caseSensitive: false,
    );
    final episodeMatch = episodePattern.stringMatch(text);
    if (episodeMatch != null) {
      // Extract the season number
      final numberPattern = RegExp(r'\d+', caseSensitive: false);
      final numberMatch = numberPattern.stringMatch(episodeMatch);
      if (numberMatch != null) {
        // Parse season number string to int
        result = int.parse(numberMatch);
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
