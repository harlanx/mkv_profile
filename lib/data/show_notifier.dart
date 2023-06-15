import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:async/async.dart';

import '../models/models.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';
import 'app_data.dart';

class ShowNotifier extends InputBasic with ChangeNotifier {
  ShowNotifier(
    final Show show,
    UserProfile profile,
  ) : super(show: show, profile: profile);

  final Set<String> expandedTrees = {};
  final _memoizer = AsyncMemoizer();

  void refresh() => notifyListeners();

  Future<void> loadInfo() async {
    return await _memoizer.runOnce(() async {
      MetadataScanner.load();
      MetadataScanner.active = true;
      final videos =
          show is Movie ? [(show as Movie).video] : (show as Series).allVideos;
      for (var v in videos) {
        await v.loadInfo();
        for (var addedAudio in v.addedAudios) {
          await addedAudio.loadInfo();
        }
        for (var addedSub in v.addedSubtitles) {
          await addedSub.loadInfo();
        }
      }
      MetadataScanner.unload();
      MetadataScanner.active = false;
    });
  }

  void _previewProfile() {
    show.title = TitleScanner.show(this);
    if (show is Movie) {
      final movie = show as Movie;
      movie.video.fileTitle = TitleScanner.video(movie.video, false, profile);
      movie.video.title = movie.video.fileTitle;
      _previewTracks(movie.video);
    } else {
      for (var v in (show as Series).allVideos) {
        v.fileTitle = TitleScanner.video(v, true, profile);
        v.title = v.fileTitle;
        _previewTracks(v);
      }
    }
  }

  void _previewTracks(Video v) {
    _assignDefault([...v.embeddedAudios, ...v.addedAudios]);
    _assignDefault([...v.embeddedSubtitles, ...v.addedSubtitles]);
    sortTracks();
    for (var a in [...v.embeddedAudios, ...v.addedAudios]) {
      a.title = TitleScanner.audio(a, profile);
    }
    for (var s in [...v.embeddedSubtitles, ...v.addedSubtitles]) {
      s.title = TitleScanner.subtitle(s, profile);
    }
  }

  void _assignDefault(List<TrackProperties> tracks) {
    for (var track in tracks) {
      if (profile.languages.contains(track.language.iso6393)) {
        track.include = true;
        final orderableFlags =
            track.flags.values.where((e) => e.name != 'default').toList();

        if (track.language.iso6393 == profile.defaultLanguage) {
          for (String flagOrder in profile.defaultFlagOrder) {
            if (flagOrder == 'default' &&
                orderableFlags.every((flag) => flag.value == false)) {
              track.flags['default']!.value = true;
            } else {
              if (track.flags[flagOrder]!.value) {
                track.flags['default']!.value = true;
              } else {
                track.flags['default']!.value = false;
              }
            }
            break;
          }
        } else {
          track.flags['default']!.value = false;
        }
      } else {
        track.include = false;
      }
    }
  }

  /// Sort the tracks by their flags in the following order:
  /// include, Alphabetically, Default,
  /// Original Language, Forced, Commentary,
  /// HearingImpaired, VisualImpaired, TextDescription
  void sortTracks() {
    final videos = [];
    if (show is Movie) {
      final movie = show as Movie;
      videos.add(movie.video);
    } else {
      final series = show as Series;
      videos.addAll(series.allVideos);
    }

    for (var v in videos) {
      v.embeddedAudios.sort(_sortMethodA);
      v.addedAudios.sort(_sortMethodA);
      v.embeddedSubtitles.sort(_sortMethodA);
      v.addedSubtitles.sort(_sortMethodA);
    }
  }

  /// This sort method will not consider other flags.
  /// If it is Default = true and TextDescription = true, it will be placed at the first order.
  int _sortMethodA(TrackProperties a, TrackProperties b) {
    final flags = a.flags;

    if (a.include == b.include) {
      if (a.language.cleanName == b.language.cleanName) {
        for (int i = 0; i < flags.length; i++) {
          final aValue = a.flagByIndex(i).value;
          final bValue = b.flagByIndex(i).value;
          if (aValue != bValue) {
            return aValue ? -1 : 1;
          }
        }
      } else {
        return compareNatural(a.language.cleanName, b.language.cleanName);
      }
    } else if (a.include) {
      return -1;
    } else {
      return 1;
    }

    return 0;
  }

  /// This sort method will consider other flags.
  /// If it is Default = true and TextDescription = true, it will be placed at the last order.
  /// ignore: unused_element
  int _sortMethodB(TrackProperties a, TrackProperties b) {
    final flags = a.flags;
    if (a.include == b.include) {
      if (a.language.cleanName == b.language.cleanName) {
        for (int i = flags.length; i > flags.length; i--) {
          if (a.flagByIndex(i).value != b.flagByIndex(i).value) {
            if (b.flagByIndex(i).value) {
              return -1;
            } else {
              return 1;
            }
          }
        }
      } else {
        return compareNatural(a.language.cleanName, b.language.cleanName);
      }
    } else if (a.include) {
      return -1;
    } else {
      return 1;
    }

    return 0;
  }

  void updateProfile(UserProfile profile) {
    this.profile = profile;
    _previewProfile();
    notifyListeners();
  }

  void addToExpanded(String path) {
    expandedTrees.add(path);
  }

  void removeFromExpanded(String path) {
    expandedTrees.remove(path);
  }
}

class ShowListNotifier extends ChangeNotifier {
  final Map<int, ShowNotifier> _items = {};
  Map<int, ShowNotifier> get items => _items;

  Future<void> add(List<String?> paths) async {
    // While it would be better to put this checker
    // in the MetadataScanner by consistency I think it's more effecient
    // to check before it scans for files since it won't be processed by
    // MetadataScanner anyways if the MediaInfo tool isn't working.
    if (await AppData.checkMediaInfo()) {
      final List<ScanError> failedPaths = [];
      for (var path in paths) {
        if (path != null) {
          if (await PathScanner.isDirectory(path)) {
            try {
              if (!items.values.any((e) => e.show.directory.path == path)) {
                final result = await PathScanner.scan(path);
                if (result.failedGroups.isNotEmpty) {
                  failedPaths.add(ScanError(
                      'No subtitles found for: ${result.failedGroups.join(', ')}',
                      path));
                }
                _items.addAll({
                  path.hashCode: ShowNotifier(
                      result.show, AppData.profiles.items.entries.first.value)
                });
                notifyListeners();
              }
            } catch (e) {
              failedPaths.add(ScanError(e.toString(), path));
            }
          }
        }
      }
      if (failedPaths.isNotEmpty) {
        showDialog<void>(
          context: AppData.mainNavigatorKey.currentContext!,
          builder: (context) => ParserResultDialog(failedPaths: failedPaths),
        );
      }
    } else {
      showDialog<void>(
        context: AppData.mainNavigatorKey.currentContext!,
        builder: (context) => const ToolNotExistDialog(
          toolName: 'MediaInfo',
          info:
              'This app relies on MediaInfo.dll (64 bit) to fetch metadata/info of a file. Please configure in Settings > Misc > MediaInfo then browse for the correct .dll file.',
        ),
      );
    }
  }

  void remove(int id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }

  void modifiedProfile(UserProfile profile) {
    for (var showN in _items.values) {
      if (showN.profile != profile) return;
      showN.updateProfile(AppData.profiles.items.entries.first.value);
    }
  }
}
