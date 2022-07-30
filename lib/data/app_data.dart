import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:path/path.dart';

import 'app_settings_notifier.dart';
import 'user_profiles_notifier.dart';

export 'app_settings_notifier.dart';
export 'shows_notifier.dart';
export 'user_profiles_notifier.dart';

class AppData extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  void updatePage(int index) {
    _currentPage = index;
    notifyListeners();
  }

  static const String kAppTitle = 'Merge2MKV';
  static final mainNavigatorKey = GlobalKey<NavigatorState>();
  static final List<String> videoFormats = ['avi', 'mov', 'mp4', 'mpeg', 'mpg', 'm4v', 'mkv'];
  static const List<String> subtitleFormats = ['srt', 'sub', 'ass', 'ssa'];
  static const List<String> fontFormats = ['ttf', 'otf'];
  static late final LanguageCodes languageCodes;
  static late final AppSettingsNotifier appSettings;
  static late final UserProfilesNotifier profiles;

  static init() async {
    // Loads from json file
    languageCodes = await LanguageCodes.load();
    // Loads from share preferences xml file
    await SharedPrefs.init().then((value) {
      appSettings = AppSettingsNotifier.load();
      profiles = UserProfilesNotifier.load();
    });

    //_loadAssets();
  }

  // Do own styles.
  static final lightTheme = ThemeData.light().copyWith(
    focusTheme: FocusThemeData(glowFactor: is10footScreen() ? 2.0 : 0.0),
    accentColor: appSettings.systemAccentColor,
    visualDensity: VisualDensity.standard,
  );

  // Do own styles.
  static final darkTheme = ThemeData.dark().copyWith(
    visualDensity: VisualDensity.standard,
    accentColor: appSettings.systemAccentColor,
    focusTheme: FocusThemeData(glowFactor: is10footScreen() ? 2.0 : 0.0),
  );

  static save() async {
    appSettings.save();
    profiles.save();
  }

  static _loadAssets() async {
    // AssetManifest.json is only built when app is compiled.
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Directory directory = File(Platform.resolvedExecutable).parent;
    final utilitiesPath = join(directory.path, "utilities/");
    final List<String> mediaInfoFiles =
        json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/mediainfo/')).toList();
    final List<String> mkvmergeFiles =
        json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/mkvmerge/')).toList();

    for (var i in mediaInfoFiles) {
      File file = File(normalize(join(utilitiesPath, i.split('/').last)));
      if (!file.existsSync()) {
        file.createSync(recursive: true);
        final assetBytes = await rootBundle.load(i);
        final assetBuffer = assetBytes.buffer.asUint8List(assetBytes.offsetInBytes, assetBytes.lengthInBytes);
        file.writeAsBytesSync(assetBuffer);
      }
    }

    for (var i in mkvmergeFiles) {
      File file = File(normalize(join(utilitiesPath, i.split('/').last)));
      if (!file.existsSync()) {
        file.createSync(recursive: true);
        final assetBytes = await rootBundle.load(i);
        final assetBuffer = assetBytes.buffer.asUint8List(assetBytes.offsetInBytes, assetBytes.lengthInBytes);
        file.writeAsBytesSync(assetBuffer);
      }
    }
  }
}
