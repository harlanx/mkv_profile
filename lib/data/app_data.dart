import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:merge2mkv/screens/screens.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:merge2mkv/models/models.dart';

import 'app_settings_notifier.dart';
import 'user_profiles_notifier.dart';
import 'output_notifier.dart';

export 'app_settings_notifier.dart';
export 'shows_notifier.dart';
export 'tasks_notifier.dart';
export 'user_profiles_notifier.dart';
export 'output_notifier.dart';

class AppData extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  void updatePage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  static const String kAppTitle = 'Merge2MKV';
  static final mainNavigatorKey = GlobalKey<NavigatorState>();
  static final List<String> videoFormats = [
    'avi',
    'mov',
    'mp4',
    'mpeg',
    'mpg',
    'm4v',
    'mkv'
  ];
  static const List<String> subtitleFormats = ['srt', 'sub', 'ass', 'ssa'];
  static const List<String> fontFormats = ['ttf', 'otf'];
  static late final LanguageCodes languageCodes;
  static late final AppSettingsNotifier appSettings;
  static late final UserProfilesNotifier profiles;
  static late final OutputNotifier outputs;

  static final GlobalKey<TaskScreenState> taskStateKey = GlobalKey();
  static final GlobalKey<OutputScreenState> outputStateKey = GlobalKey();

  static init() async {
    // Ready binaries for usage
    await _loadAssets();
    // Loads from json file
    languageCodes = await LanguageCodes.load();
    // Loads from share preferences xml file
    await SharedPrefs.init().then((value) {
      appSettings = AppSettingsNotifier.load();
      profiles = UserProfilesNotifier.load();
      outputs = OutputNotifier.load();
    });
  }

  // Do own styles.
  static final lightTheme = FluentThemeData.light().copyWith(
    focusTheme: FocusThemeData(glowFactor: is10footScreen() ? 2.0 : 0.0),
    accentColor: appSettings.systemAccentColor,
    visualDensity: VisualDensity.standard,
  );

  // Do own styles.
  static final darkTheme = FluentThemeData.dark().copyWith(
    visualDensity: VisualDensity.standard,
    accentColor: appSettings.systemAccentColor,
    focusTheme: FocusThemeData(glowFactor: is10footScreen() ? 2.0 : 0.0),
  );

  static save() async {
    appSettings.save();
    profiles.save();
  }

  // Copy app assets to the same folder as the executable and placed onto a folder named utilities
  static Future<void> _loadAssets() async {
    // Directory of out executable
    final Directory exeDir = File(Platform.resolvedExecutable).parent;
    // External Tools' File Names
    const String mediainfoFile = 'MediaInfo.dll';
    const String mkvmergeFile = 'mkvmerge.exe';
    // Check if it already exist
    if (await File('${exeDir.path}\bin\$mediainfoFile').exists() ||
        await File('${exeDir.path}\bin\$mkvmergeFile').exists()) {
      return;
    }

    // Load from Assets
    final ByteData mediaInfoData =
        await rootBundle.load('assets/mediainfo/$mediainfoFile');
    final ByteData mkvmergeData =
        await rootBundle.load('assets/mkvmerge/$mkvmergeFile');

    // Read Bytes
    final List<int> mediaInfoBytes = mediaInfoData.buffer
        .asUint8List(mediaInfoData.offsetInBytes, mediaInfoData.lengthInBytes);
    final List<int> mkvmergeBytes = mkvmergeData.buffer
        .asUint8List(mkvmergeData.offsetInBytes, mkvmergeData.lengthInBytes);

    // Create the file with zero bytes.
    final File mediainfoDll = await File('${exeDir.path}\\bin\\$mediainfoFile')
        .create(recursive: true);
    final File mkvmergeExe = await File('${exeDir.path}\\bin\\$mkvmergeFile')
        .create(recursive: true);

    // Fill in the empty files
    await mediainfoDll.writeAsBytes(mediaInfoBytes, flush: true);
    await mkvmergeExe.writeAsBytes(mkvmergeBytes, flush: true);
  }
}
