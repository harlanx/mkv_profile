import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/services/app_services.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class FileGrouper {
  static Future<GroupingResult> group(PathData pathData) async {
    if (pathData.videos.length > 1) {
      Set<String> successGroup = {};
      Set<String> failGroup = {};
      Set<String> seasonsStr = {};
      // Get available seasons through directory names;
      for (var dir in pathData.directories) {
        if (_checkSeason(dir.name) != null) {
          seasonsStr.add(_checkSeason(dir.name)!);
        }
      }
      // Get available seasons through video file names;
      for (var vid in pathData.videos) {
        if (_checkSeason(vid.title) != null) {
          seasonsStr.add(_checkSeason(vid.title)!);
        }
      }

      List<Seasons> seasons = [];
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
                subtitles: _checkSubtitles(relatedFiles.toList()),
              ),
            );
          }
        }
        // If no subtitle file found for the video, remove it from the list
        // Remove this line if planning on managing mkv files.
        videos.removeWhere((element) => element.subtitles.isEmpty);
        if (videos.isNotEmpty) {
          seasons.add(Seasons(season: seasonInt, videos: videos));
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
    var videoFile = pathData.videos.first;
    return GroupingResult(
      Movie(
        directory: pathData.mainDir,
        video: Video(
          mainFile: videoFile,
          subtitles: _checkSubtitles(pathData.otherFiles),
        ),
      ),
    );
  }

  static List<Subtitle> _checkSubtitles(List<File> relatedFiles) {
    return relatedFiles
        .where((element) => AppData.subtitleFormats.contains(element.extension))
        .map((e) => Subtitle(e))
        .toList();
  }

  static String? _checkSeason(String fileName) {
    RegExp extractSeason = RegExp(r'Season.\d+|S.\d+', caseSensitive: false);
    if (extractSeason.hasMatch(fileName)) {
      var result = extractSeason.firstMatch(fileName)![0].toString();
      return result;
    } else {
      return null;
    }
  }
}

class GroupingResult {
  Show show;
  Set<String> failedGroups;
  GroupingResult(this.show, {this.failedGroups = const {}});
}
