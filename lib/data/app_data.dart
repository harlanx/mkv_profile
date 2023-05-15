import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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
  static const String appTitle = 'MKVProfile';
  static const String appDescription =
      '''Automatically manage and merge to mkv your downloaded series or movie files to the common conventions used by media players and media servers. The GUI is intentionally made simple and is designed for least user interactions by implementing per profile configuration to manage files and generate a command to be used on mkvmerge process.''';

  static const String projectURL = '''https://github.com/harlanx''';

  static List<int> defaultAccents = [
    0xffb4831d,
    0xffd85a00,
    0xff6a3310,
    0xff468600,
  ];

  static final mainNavigatorKey = GlobalKey<NavigatorState>();
  // Directory of our executable
  static final Directory exeDir = File(Platform.resolvedExecutable).parent;
  // External tools' file names in assets
  static const String _mediainfoFile = 'MediaInfo.dll';
  static const String _mkvmergeFile = 'mkvmerge.exe';

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

  static final LanguageCodes languageCodes = LanguageCodes();
  static final AppSettingsNotifier appSettings = AppSettingsNotifier();
  static final UserProfilesNotifier profiles = UserProfilesNotifier();
  static final TaskListNotifier tasks = TaskListNotifier();
  static final OutputNotifier outputs = OutputNotifier();

  static final GlobalKey<TasksScreenState> taskStateKey = GlobalKey();
  static final GlobalKey<OutputsScreenState> outputStateKey = GlobalKey();

  static init() async {
    // Loads from json file
    await languageCodes.load();
    // Loads from share preferences xml file
    await SharedPrefs.init().then((_) {
      if (kDebugMode) {
        SharedPrefs.clear();
      }
      appSettings.load();
      profiles.load();
      outputs.load();
    });
    // Check tools if working
    await _checkTools();
  }

  static Future<void> save() async {
    if (!kDebugMode) {
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
    var file = File(appSettings.mediaInfoPath);
    mediaInfoLoaded = false;
    if (await file.exists() && file.name == _mediainfoFile) {
      try {
        final miw = MediaInfoWrapper(dllPath: file.path);
        var result = miw.option('Info_Version');
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
    var file = File(appSettings.mkvMergePath);
    mkvMergeLoaded = false;
    if (await file.exists() && file.name == _mkvmergeFile) {
      try {
        String result = (await Process.run(file.path, ['--version'])).stdout;
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

  // /// Copy app tool assets to the same folder as the executable and place onto a folder named bin
  // static Future<void> _copyMediaInfo() async {
  //   appSettings.mediaInfoPath = '${exeDir.path}\\bin\\$_mediainfoFile';
  //   // Load from assets
  //   final ByteData mediaInfoData =
  //       await rootBundle.load('assets/mediainfo/$_mediainfoFile');
  //   // Read bytes
  //   final List<int> mediaInfoBytes = mediaInfoData.buffer
  //       .asUint8List(mediaInfoData.offsetInBytes, mediaInfoData.lengthInBytes);
  //   // Create the file with zero bytes.
  //   final File mediainfoDll =
  //       await File(appSettings.mediaInfoPath).create(recursive: true);
  //   // Fill in with byte data
  //   await mediainfoDll.writeAsBytes(mediaInfoBytes, flush: true);
  //   mediaInfoLoaded = true;
  // }

  // static Future<void> _copyMkvMerge() async {
  //   appSettings.mkvMergePath = '${exeDir.path}\\bin\\$_mkvmergeFile';
  //   final ByteData mkvmergeData =
  //       await rootBundle.load('assets/mkvmerge/$_mkvmergeFile');

  //   final List<int> mkvmergeBytes = mkvmergeData.buffer
  //       .asUint8List(mkvmergeData.offsetInBytes, mkvmergeData.lengthInBytes);

  //   final File mkvmergeExe =
  //       await File(appSettings.mkvMergePath).create(recursive: true);

  //   await mkvmergeExe.writeAsBytes(mkvmergeBytes, flush: true);
  //   mkvMergeLoaded = true;
  // }
}
