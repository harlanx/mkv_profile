import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:package_info_plus/package_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart' show rootBundle;

import '../screens/screens.dart';
import '../services/mediainfo_wrapper.dart';
import '../utilities/utilities.dart';
import '../models/models.dart';

import 'app_settings_notifier.dart';
import 'user_profiles_notifier.dart';
import 'tasks_notifier.dart';
import 'output_notifier.dart';

export 'page_notifier.dart';
export 'app_settings_notifier.dart';
export 'show_notifier.dart';
export 'tasks_notifier.dart';
export 'user_profiles_notifier.dart';
export 'output_notifier.dart';

class AppData {
  static late final PackageInfo appInfo;
  static const appTitle = 'MKV Profile';
  static const projectURL = r'https://github.com/harlanx/mkv_profile';
  static const mediainfoURL =
      r'https://mediaarea.net/en/MediaInfo/Download/Windows';
  static const mkvmergeURL =
      r'https://mkvtoolnix.download/downloads.html#windows';

  static List<int> defaultAccents = [
    0xffb4831d,
    0xffd85a00,
    0xff6a3310,
    0xff468600,
  ];

  static final mainNavigatorKey = GlobalKey<NavigatorState>();
  // Directory of our executable
  static final exeDir = File(Platform.resolvedExecutable).parent;
  static final defaultMediaInfoPath =
      '${exeDir.path}\\data\\flutter_assets\\assets\\mediainfo\\MediaInfo.dll';
  static final defaultMKVMergePath =
      '${exeDir.path}\\data\\flutter_assets\\assets\\mkvmerge\\mkvmerge.exe';
  // External tools' file names in assets
  static const _mediainfoFile = 'MediaInfo.dll';
  static const _mkvmergeFile = 'mkvmerge.exe';

  static bool mediaInfoLoaded = false;
  static bool mkvMergeLoaded = false;

  static final List<String> videoFormats = [
    'avi',
    'mov',
    'mp4',
    'mpeg',
    'mpg',
    'm4v',
    'mkv',
  ];
  static const List<String> audioFormats = [
    'aac',
    'flac',
    'm4a',
    'mp3',
    'ogg',
    'opus',
    'wav',
  ];
  static const List<String> subtitleFormats = [
    'srt',
    'ass',
    'ssa',
  ];
  static const List<String> chapterFormats = [
    'ogm',
    'txt',
    'xml',
  ];
  static const List<String> fontFormats = [
    'ttf',
    'otf',
  ];

  static const List<String> imageFormats = [
    'jpg',
    'jpeg',
    'png',
  ];

  static final languageCodes = LanguageCodes();
  static final appSettings = AppSettingsNotifier();
  static final profiles = UserProfilesNotifier();
  static final tasks = TaskListNotifier();
  static final outputs = OutputNotifier();

  static final taskStateKey = GlobalKey<TasksScreenState>();
  static final outputStateKey = GlobalKey<OutputsScreenState>();

  static Future<void> init() async {
    appInfo = await PackageInfo.fromPlatform();
    // Loads from json file
    await languageCodes.load();
    // Loads from sharedpreferences xml file
    await SharedPrefs.init().then((_) {
      appSettings.load();
      profiles.load();
      outputs.load();
    });
    // Check tools if working
    await _checkTools();
  }

  static Future<void> save() async {
    if (kReleaseMode) {
      await appSettings.save();
      await profiles.save();
      await outputs.save();
    }
  }

  static Future<void> _checkTools() async {
    await checkMediaInfo();
    await checkMkvMerge();
  }

  static Future<bool> checkMediaInfo() async {
    final file = File(appSettings.mediaInfoPath);
    mediaInfoLoaded = false;
    if (await file.exists() && file.name == _mediainfoFile) {
      try {
        final miw = MediaInfoWrapper(dllPath: file.path);
        final result = miw.option('Info_Version');
        miw.library.unload();
        if (result.isNotEmpty && result.contains('MediaInfoLib')) {
          mediaInfoLoaded = true;
          return true;
        }
      } catch (_) {
        // The specified library might be incorrect.
      }
    }
    return false;
  }

  static Future<bool> checkMkvMerge() async {
    final file = File(appSettings.mkvMergePath);
    mkvMergeLoaded = false;
    if (await file.exists() && file.name == _mkvmergeFile) {
      try {
        final result =
            (await Process.run(file.path, ['--version'])).stdout as String;
        if (result.isNotEmpty && result.contains('mkvmerge')) {
          mkvMergeLoaded = true;
          return true;
        }
      } catch (_) {
        // The specified library might be incorrect.
      }
    }
    return false;
  }
}
