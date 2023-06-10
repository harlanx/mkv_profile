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
  static String _modifiedTitle(String rawTitle, List<TextModifier> modifiers) {
    for (var i in modifiers) {
      for (var j in i.replaceable) {
        rawTitle = rawTitle.replaceAll(
            RegExp(j.regexSafe, caseSensitive: i.caseSensitive), i.replacement);
      }
    }

    // Replace whitespaces to single whitespace and trim end for any whitespace.
    return rawTitle.singleSpace.trim();
  }

  static String _year(String rawTitle) {
    var year = RegExp(r'\b\d{4}\b', caseSensitive: false).stringMatch(rawTitle);
    if (year != null) {
      if (int.parse(year) > 1440) {
        return year;
      }
    }
    return '';
  }

  static String show(InputBasic input) {
    var profile = input.profile;
    var show = input.show;
    String rawTitle = _sourceTitle(show, profile);
    String titleFormat = profile.showTitleFormat;

    MediaInfo info;
    if (show is Movie) {
      info = show.video.info;
    } else {
      show as Series;
      info = show.allVideos.first.info;
    }

    var videoInfo = info.videoInfo.first;

    Map<String, String> formats = {};
    // Setting variable values
    formats['%duration%'] =
        Duration(milliseconds: (videoInfo.duration * 1000).toInt())
            .formatDuration();
    formats['%encoding%'] = videoInfo.encoding;
    formats['%frame_rate%'] = videoInfo.frameRate.toString();
    formats['%height%'] = videoInfo.height.toString();
    formats['%size%'] = info.generalInfo.fileSize.formatByteSize();
    formats['%title%'] = _modifiedTitle(rawTitle, profile.modifiers);
    formats['%width%'] = videoInfo.width.toString();
    formats['%year%'] = _year(rawTitle);

    // Applying variable values
    formats.forEach((key, value) {
      titleFormat = titleFormat.replaceFirst(key, value);
    });

    return titleFormat.singleSpace.trim();
  }

  static String video(Video video, bool isEpisode, UserProfile profile) {
    // If Profile (None) is selected just return the unmodified title
    if (profile.id == 0) return video.mainFile.title;

    String titleFormat = profile.videoTitleFormat;
    var videoInfo = video.info.videoInfo.first;

    Map<String, String> formats = {};
    formats['%language%'] = video.language.cleanName;
    formats['%duration%'] =
        Duration(milliseconds: (videoInfo.duration * 1000).toInt())
            .formatDuration();
    formats['%encoding%'] = videoInfo.encoding;
    formats['%episode%'] = video.episode?.toString().padLeft(2, '0') ?? '';
    formats['%frame_rate%'] = videoInfo.frameRate.toString();
    formats['%height%'] = videoInfo.height.toString();
    formats['%season%'] = video.season?.toString().padLeft(2, '0') ?? '';
    formats['%size%'] = video.info.generalInfo.fileSize.formatByteSize();
    formats['%title%'] =
        _modifiedTitle(video.mainFile.title, profile.modifiers);
    formats['%width%'] = videoInfo.width.toString();
    formats['%year%'] = _year(video.mainFile.title);

    formats.forEach((key, value) {
      titleFormat = titleFormat.replaceFirst(key, value);
    });

    return titleFormat.singleSpace.trim();
  }

  static String audio(TrackProperties audioTrack, UserProfile profile) {
    if (profile.id == 0) return audioTrack.title ?? '';

    String titleFormat = profile.audioTitleFormat;
    Map<String, String> formats = {};

    // Reflection is kinda bad in flutter so just use the good ol if-else
    // condition and type casting to access property.
    if (audioTrack is EmbeddedTrack) {
      final audioInfo = audioTrack.info as AudioInfo;
      formats['%language%'] = audioTrack.language.cleanName;
      formats['%format%'] = audioInfo.format;
      formats['%bit_rate%'] = audioInfo.bitRate.formatBitSpeed();
      formats['%channels%'] = audioInfo.channels.toString();
      formats['%sampling_rate%'] = audioInfo.samplingRate.formatFrequency();
      for (var audioFlag in audioTrack.flags.entries) {
        formats['%${audioFlag.key}%'] = audioFlag.value.titleVar;
      }
    } else {
      audioTrack as AddedTrack;
      final audioInfo = audioTrack.info as AudioInfo;
      formats['%language%'] = audioTrack.language.cleanName;
      formats['%format%'] = audioInfo.format;
      formats['%bitRate%'] = audioInfo.bitRate.formatBitSpeed();
      formats['%channels%'] = audioInfo.channels.toString();
      formats['%sampling_rate%'] = audioInfo.samplingRate.formatFrequency();
      for (var audioFlag in audioTrack.flags.entries) {
        formats['%${audioFlag.key}%'] = audioFlag.value.titleVar;
      }
    }

    formats.forEach((key, value) {
      titleFormat = titleFormat.replaceFirst(key, value);
    });

    return titleFormat.singleSpace.trim();
  }

  static String subtitle(TrackProperties subtitleTrack, UserProfile profile) {
    if (profile.id == 0) return subtitleTrack.title ?? '';

    String titleFormat = profile.subtitleTitleFormat;
    Map<String, String> formats = {};

    if (subtitleTrack is EmbeddedTrack) {
      final subtitleInfo = subtitleTrack.info as TextInfo;
      formats['%language%'] = subtitleTrack.language.cleanName;
      formats['%format%'] = subtitleInfo.format;
      for (var subtitleFlag in subtitleTrack.flags.entries) {
        formats['%${subtitleFlag.key}%'] = subtitleFlag.value.titleVar;
      }
    } else {
      subtitleTrack as AddedTrack;
      final subtitleInfo = subtitleTrack.info as TextInfo;
      formats['%language%'] = subtitleTrack.language.cleanName;
      formats['%format%'] = subtitleInfo.format;
      for (var subtitleFlag in subtitleTrack.flags.entries) {
        formats['%${subtitleFlag.key}%'] = subtitleFlag.value.titleVar;
      }
    }

    formats.forEach((key, value) {
      titleFormat = titleFormat.replaceFirst(key, value);
    });

    return titleFormat.singleSpace.trim();
  }
}
