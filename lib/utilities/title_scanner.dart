import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'utilities.dart';

class TitleScanner {
  static String scanTitle(InputBasic inputNotifier) {
    var profile = inputNotifier.profile;
    var show = inputNotifier.item;
    String rawTitle = extractRawTitle(show, profile);
    String showTitle = profile.titleFormat;
    Map<String, String> format = {};

    MediaInfo mediaInfo;
    if (show is Movie) {
      mediaInfo = show.video.info;
    } else {
      show as Series;
      mediaInfo = show.seasons.first.videos.first.info;
    }

    format['%duration%'] = Duration(
            milliseconds: (mediaInfo.media.videoInfo.duration * 1000).toInt())
        .formatDuration();
    format['%encoding%'] = mediaInfo.media.videoInfo.encoding;
    format['%frames%'] = mediaInfo.media.videoInfo.frameRate.toString();
    format['%height%'] = mediaInfo.media.videoInfo.height.toString();
    format['%size%'] = mediaInfo.media.generalInfo.fileSize.formatBytes();
    format['%title%'] = extractTitle(rawTitle, profile);
    format['%width%'] = mediaInfo.media.videoInfo.width.toString();
    format['%year%'] = extractYear(rawTitle);

    format.forEach((key, value) {
      showTitle = showTitle.replaceFirst(key, value);
    });

    bool hasMovieVariables =
        showTitle.contains(RegExp('(?<=\\<M)(.*?)(?=\\>)'));
    bool hasSeriesVariables =
        showTitle.contains(RegExp('(?<=\\<S)(.*?)(?=\\>)'));

    if (show is Movie && hasSeriesVariables) {
      showTitle = showTitle.replaceAll(RegExp('(?<=\\<S)(.*?)(?=\\>)'), '');
    }

    if (show is Series && hasMovieVariables) {
      showTitle = showTitle.replaceAll(RegExp('(?<=\\<M)(.*?)(?=\\>)'), '');
    }

    showTitle = showTitle.replaceAll(RegExp('<M|<S|>'), '');

    return showTitle;
  }

  /// Get raw title from files and consider user preference.
  static String extractRawTitle(Show show, UserProfile profile) {
    String fileTitle;
    if (show is Movie) {
      fileTitle = show.video.mainFile.name;
    } else {
      show as Series;
      fileTitle = show.seasons.first.videos.first.mainFile.name;
    }

    return profile.useFolderName ? show.directory.name : fileTitle;
  }

  /// Title scanner by removing the matched strings using the list [UserProfile.removeString]
  static String extractTitle(String rawTitle, UserProfile profile) {
    for (var i in profile.removeString) {
      rawTitle = rawTitle.replaceAll(
          RegExp(i, caseSensitive: profile.caseSensitive), '');
    }

    for (var i in profile.replaceString) {
      rawTitle = rawTitle.replaceAll(
          RegExp('\\$i', caseSensitive: profile.caseSensitive), ' ');
    }

    if (profile.removeLanguageTitle) {
      for (var language in AppData.languageCodes.items) {
        rawTitle = rawTitle.replaceAll(language.normalName, '');
      }
    }

    // Replace whitespaces to single whitespace and trim end for any whitespace.
    rawTitle = rawTitle.replaceAll(RegExp(r"\s+"), ' ').trim();

    return rawTitle;
  }

  static String extractYear(String rawTitle) {
    var year = RegExp(r'\b\d{4}\b').stringMatch(rawTitle);
    if (year != null) {
      if (int.parse(year) > 1440) {
        return year;
      }
    }
    return '';
  }

  /// Scan episode name and remove the string result from [extractTitle]
  static String scanEpisode(
      UserProfile profile, int season, String title, Video video) {
    // If Profile (None) is selected just return the unmodified title
    if (profile.id == 0) return video.info.media.generalInfo.title;
    String episodeTitle = profile.episodeTitleFormat;

    // Scan for episode number with prefix
    String episode = RegExp(r'Episode.\d+|E.\d+', caseSensitive: false)
            .stringMatch(video.mainFile.name) ??
        '01';

    // Remove the prefix and extract the number only
    episode = RegExp(r'\d+', caseSensitive: false).stringMatch(episode)!;

    Map<String, String> format = {};
    format['%duration%'] = Duration(
            milliseconds: (video.info.media.videoInfo.duration * 1000).toInt())
        .formatDuration();
    format['%encoding%'] = video.info.media.videoInfo.encoding;
    format['%episode%'] = episode;
    format['%frames%'] = video.info.media.videoInfo.frameRate.toString();
    format['%height%'] = video.info.media.videoInfo.height.toString();
    format['%season%'] = season.toString().padLeft(2, '0');
    format['%size%'] = video.info.media.generalInfo.fileSize.formatBytes();
    format['%title%'] = title;
    format['%width%'] = video.info.media.videoInfo.width.toString();

    format.forEach((key, value) {
      episodeTitle = episodeTitle.replaceFirst(key, value);
    });

    return episodeTitle;
  }
}
