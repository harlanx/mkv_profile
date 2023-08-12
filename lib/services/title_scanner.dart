import '../models/models.dart';
import '../utilities/utilities.dart';

class TitleScanner {
  /// Get source title to be used considering user preference.
  /// This is only for the show title
  static String _sourceTitle(Show show, UserProfile profile) {
    String fileTitle;
    if (show is Movie) {
      fileTitle = show.video.mainFile.title;
    } else {
      show as Series;
      fileTitle = show.allVideos.first.mainFile.title;
    }

    return profile.useFolderName ? show.directory.name : fileTitle;
  }

  /// Title scanner by replacing the matched strings using the list [UserProfile.modifiers]
  static String _showTitle(String source, List<TextModifier> modifiers) {
    var fileTitle = source
        .split(RegExp(r'(?:E(?:pisode)?\.?\s?\d{2}|Episode(?:\s?\d{2})?)\b'))
        .first;
    for (var i in modifiers) {
      for (var j in i.replaceables) {
        fileTitle = fileTitle.replaceAll(
            RegExp(j.regexSafe, caseSensitive: false), i.replacement);
      }
    }

    // Replace whitespaces to single whitespace and trim end for any whitespace.
    final result = fileTitle.singleSpace.trim();
    if (result == ' ') {
      return '';
    }
    return result;
  }

  /// Title scanner by replacing the matched strings using the list [UserProfile.modifiers]
  static String _episodeTitle(String source, List<TextModifier> modifiers) {
    var episodeTitle = '';
    final possibleTitles = source
        .split(RegExp(r'(?:E(?:pisode)?\.?\s?\d{2}|Episode(?:\s?\d{2})?)\b'));
    if (possibleTitles.length >= 2) {
      episodeTitle = possibleTitles.last;
      for (var i in modifiers) {
        for (var j in i.replaceables) {
          episodeTitle = episodeTitle.replaceAll(
              RegExp(j.regexSafe, caseSensitive: i.caseSensitive),
              i.replacement);
        }
      }
    }

    // Replace whitespaces to single whitespace and trim end for any whitespace.
    final result = episodeTitle.singleSpace.trim();
    if (result == ' ') {
      return '';
    }
    return result;
  }

  static String _year(String source) {
    final year = RegExp(r'\b\d{4}\b', caseSensitive: false).stringMatch(source);
    if (year != null) {
      if (int.parse(year) > 1440) {
        return year;
      }
    }
    return '';
  }

  static String show(InputBasic input) {
    final profile = input.profile;
    final show = input.show;
    final rawTitle = _sourceTitle(show, profile);
    String titleFormat = profile.showTitleFormat;

    if (titleFormat.isEmpty) return rawTitle;

    MediaInfo info;
    if (show is Movie) {
      info = show.video.info;
    } else {
      show as Series;
      info = show.allVideos.first.info;
    }

    final videoInfo = info.videoInfo.first;

    final Map<String, String> formats = {};
    // Setting variable values
    formats['%duration%'] =
        Duration(milliseconds: (videoInfo.duration * 1000).toInt()).format();
    formats['%encoding%'] = videoInfo.encoding;
    formats['%frame_rate%'] = videoInfo.frameRate.toString();
    formats['%height%'] = videoInfo.height.toString();
    formats['%size%'] = info.generalInfo.fileSize.formatByteSize();
    formats['%show_title%'] = _showTitle(rawTitle, profile.modifiers);
    formats['%width%'] = videoInfo.width.toString();
    formats['%year%'] = _year(rawTitle);

    // Applying variable values
    formats.forEach((key, value) {
      final variable = key.replaceAll('%', '');
      final pattern = RegExp('%[^%]*$variable[^%]*%');
      if (pattern.hasMatch(titleFormat)) {
        if (value.isEmpty) {
          titleFormat = titleFormat.replaceAll(pattern, '');
        } else {
          // Allows more than one same variable
          titleFormat = titleFormat.replaceAllMapped(pattern, (match) {
            final originalPlaceholder = match.group(0);
            final replacedPlaceholder =
                originalPlaceholder!.replaceAll(variable, value);
            return replacedPlaceholder.replaceAll('%', '');
          });
          // Doesn't work with more than one same variable
          // final matches = pattern.allMatches(titleFormat);
          // final startPattern = RegExp('%[^%]*$variable');
          // final endPattern = RegExp('$variable[^%]*%');
          // final startMatch = startPattern.firstMatch(titleFormat);
          // final endMatch = endPattern.firstMatch(titleFormat);

          // if (startMatch != null && endMatch != null) {
          //   final start = startMatch.start;
          //   final end = endMatch.end;
          //   final originalPlaceholder = titleFormat.substring(start, end);
          //   titleFormat = titleFormat.replaceFirst(
          //       originalPlaceholder,
          //       originalPlaceholder
          //           .replaceAll(variable, value)
          //           .replaceAll('%', ''));
          // }
        }
      }
    });

    return titleFormat.singleSpace.trim();
  }

  static String video(String showTitle, Video video, UserProfile profile) {
    String titleFormat = profile.videoTitleFormat;
    final videoInfo = video.info.videoInfo.first;

    if (titleFormat.isEmpty) return video.mainFile.title;

    final Map<String, String> formats = {};
    formats['%language%'] = video.language.cleanName;
    formats['%duration%'] =
        Duration(milliseconds: (videoInfo.duration * 1000).toInt()).format();
    formats['%encoding%'] = videoInfo.encoding;
    formats['%episode_number%'] =
        video.episode?.toString().padLeft(2, '0') ?? '';
    formats['%format%'] = videoInfo.format;
    formats['%frame_rate%'] = videoInfo.frameRate.toString();
    formats['%height%'] = videoInfo.height.toString();
    formats['%season_number%'] = video.season?.toString().padLeft(2, '0') ?? '';
    formats['%size%'] = video.info.generalInfo.fileSize.formatByteSize();
    formats['%show_title%'] = showTitle;
    formats['%episode_title%'] =
        _episodeTitle(video.mainFile.title, profile.modifiers);
    formats['%width%'] = videoInfo.width.toString();
    formats['%year%'] = _year(video.mainFile.title);

    formats.forEach((key, value) {
      final variable = key.replaceAll('%', '');
      final pattern = RegExp('%[^%]*$variable[^%]*%');
      if (pattern.hasMatch(titleFormat)) {
        if (value.isEmpty) {
          titleFormat = titleFormat.replaceAll(pattern, '');
        } else {
          titleFormat = titleFormat.replaceAllMapped(pattern, (match) {
            final originalPlaceholder = match.group(0);
            final replacedPlaceholder =
                originalPlaceholder!.replaceAll(variable, value);
            return replacedPlaceholder.replaceAll('%', '');
          });
        }
      }
    });

    return titleFormat.singleSpace.trim();
  }

  static String audio(TrackProperties track, UserProfile profile) {
    String titleFormat = profile.audioTitleFormat;
    final Map<String, String> formats = {};
    final bool isEmbedded = track is EmbeddedTrack;

    // Reflection is kinda bad in flutter so just use type casting to access property.
    final AudioInfo trackInfo =
        isEmbedded ? track.info : (track as AddedTrack).info;

    if (titleFormat.isEmpty) return trackInfo.title ?? '';

    formats['%language%'] = track.language.cleanName;
    formats['%format%'] = trackInfo.format;
    formats['%bit_rate%'] = trackInfo.bitRate.formatBitSpeed();
    formats['%channels%'] = trackInfo.channels.toString();
    formats['%sampling_rate%'] = trackInfo.samplingRate.formatFrequency();
    for (var audioFlag in track.flags.entries) {
      formats['%${audioFlag.key}%'] = audioFlag.value.titleVar;
    }

    formats.forEach((key, value) {
      final variable = key.replaceAll('%', '');
      final pattern = RegExp('%[^%]*$variable[^%]*%');
      if (pattern.hasMatch(titleFormat)) {
        if (value.isEmpty) {
          titleFormat = titleFormat.replaceAll(pattern, '');
        } else {
          titleFormat = titleFormat.replaceAllMapped(pattern, (match) {
            final originalPlaceholder = match.group(0);
            final replacedPlaceholder =
                originalPlaceholder!.replaceAll(variable, value);
            return replacedPlaceholder.replaceAll('%', '');
          });
        }
      }
    });

    return titleFormat.singleSpace.trim();
  }

  static String subtitle(TrackProperties track, UserProfile profile) {
    String titleFormat = profile.subtitleTitleFormat;
    final Map<String, String> formats = {};
    final bool isEmbedded = track is EmbeddedTrack;

    final TextInfo trackInfo =
        isEmbedded ? track.info : (track as AddedTrack).info;

    if (titleFormat.isEmpty) return trackInfo.title ?? '';

    formats['%language%'] = track.language.cleanName;
    formats['%format%'] = trackInfo.format;
    for (var subtitleFlag in track.flags.entries) {
      formats['%${subtitleFlag.key}%'] = subtitleFlag.value.titleVar;
    }

    formats.forEach((key, value) {
      final variable = key.replaceAll('%', '');
      final pattern = RegExp('%[^%]*$variable[^%]*%');
      if (pattern.hasMatch(titleFormat)) {
        if (value.isEmpty) {
          titleFormat = titleFormat.replaceAll(pattern, '');
        } else {
          titleFormat = titleFormat.replaceAllMapped(pattern, (match) {
            final originalPlaceholder = match.group(0);
            final replacedPlaceholder =
                originalPlaceholder!.replaceAll(variable, value);
            return replacedPlaceholder.replaceAll('%', '');
          });
        }
      }
    });

    return titleFormat.singleSpace.trim();
  }
}
