import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'utilities.dart';

class TitleScanner {
  static const String yearExp = r'\b\d{4}\b';
  static String scan(ShowNotifier showNotifier) {
    var show = showNotifier.item;
    var fileTitle = '';
    if (show is Movie) {
      fileTitle = show.video.mainFile.name;
    } else {
      show as Series;
      fileTitle = show.seasons.first.videos.first.mainFile.name;
    }

    var profile = AppData.profiles.items.elementAt(showNotifier.profileIndex);
    var showTitle = profile.useFolderName ? show.directory.name : fileTitle;
    for (var i in profile.stringToRemove) {
      showTitle = showTitle.replaceAll(
          RegExp(i, caseSensitive: profile.caseSensitive), '');
    }

    for (var i in profile.stringToSpace) {
      if(i == '.') i = '\\.';
      showTitle = showTitle.replaceAll(RegExp(i), ' ');
    }

    String? season = RegExp(r'Season.\d+|S.\d+', caseSensitive: false)
        .stringMatch(showTitle);
    String? year = RegExp(yearExp).stringMatch(showTitle);

    showTitle = showTitle.replaceAll(year ?? '', '');
    showTitle = showTitle.replaceAll(season ?? '', '');

    if (year != null && profile.includeYear) {
      showTitle += ' ($year)';
    }

    // Replace whitespaces to single whitespace.
    showTitle = showTitle.replaceAll(RegExp(r"\s+"), ' ').trim();

    return showTitle;
  }

  static String scanEpisode(String seriesTitle, File video) {
    String? seasonEpisode =
        RegExp(r'S.\d+E.\d+', caseSensitive: false).stringMatch(video.name);

    return '$seriesTitle - ${seasonEpisode ?? ''}';
  }
}

class SubtitleScanner {
  static void scan(File subFile) {
    if (subFile.extension != 'srt') return;
  }
}
