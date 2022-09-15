import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:system_theme/system_theme.dart';
//import 'package:system_theme/system_theme.dart';
//import 'package:window_manager/window_manager.dart';

enum ViewMode { normal, compact }

enum WindowsFluentEffect {
  disabled(WindowEffect.disabled),
  transparent(WindowEffect.transparent),
  acrylic(WindowEffect.acrylic),
  mica(WindowEffect.mica),
  tabbed(WindowEffect.tabbed);

  const WindowsFluentEffect(this.value);
  final WindowEffect value;
}

class AppSettingsNotifier extends ChangeNotifier {
  int recursiveLimit;
  ThemeMode themeMode;
  WindowsFluentEffect windowEffect;
  Size windowSize;
  bool isMaximized;

  // Width sizes for ViewMode.Compact
  double folderPanelWidth;
  double infoPanelWidth;

  AppSettingsNotifier({
    this.recursiveLimit = 50,
    this.themeMode = ThemeMode.system,
    this.windowEffect = WindowsFluentEffect.disabled,
    this.windowSize = const Size(1280, 720),
    this.isMaximized = false,
    this.folderPanelWidth = 300,
    this.infoPanelWidth = 500,
  });

  factory AppSettingsNotifier.fromJson(String str) =>
      AppSettingsNotifier.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  AppSettingsNotifier.fromMap(Map<String, dynamic> json)
      : recursiveLimit = json['recursiveLimit'],
        themeMode = ThemeMode.values.byName(json['themeMode']),
        windowEffect = WindowsFluentEffect.values.byName(json['windowEffect']),
        windowSize =
            Size(json['windowSize']['width'], json['windowSize']['height']),
        isMaximized = json['isMaximized'],
        folderPanelWidth = json['folderPanelWidth'],
        infoPanelWidth = json['infoPanelWidth'];

  Map<String, dynamic> toMap() => {
        'recursiveLimit': recursiveLimit,
        'themeMode': themeMode.name,
        'windowEffect': windowEffect.name,
        'windowSize': {'width': windowSize.width, 'height': windowSize.height},
        'isMaximized': isMaximized,
        'folderPanelWidth': folderPanelWidth,
        'infoPanelWidth': infoPanelWidth,
      };

  void setRecursiveLimit(int limit) {
    recursiveLimit = limit;
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    // for default window title bar
    // switch (themeMode) {
    //   case ThemeMode.system:
    //     await windowManager.setBrightness(SystemTheme.isDarkMode ? Brightness.dark : Brightness.light);
    //     break;
    //   case ThemeMode.light:
    //     await windowManager.setBrightness(Brightness.light);
    //     break;
    //   case ThemeMode.dark:
    //     await windowManager.setBrightness(Brightness.dark);
    //     break;
    // }
    notifyListeners();
  }

  void setWindowEffect(WindowsFluentEffect effect) {
    windowEffect = effect;
    notifyListeners();
  }

  void applyWindowEffect(WindowsFluentEffect effect, BuildContext context) {
    Window.setEffect(
      effect: windowEffect.value,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
      ].contains(windowEffect.value)
          ? FluentTheme.of(context).micaBackgroundColor.withOpacity(0.05)
          : Colors.transparent,
      dark: SchedulerBinding.instance.window.platformBrightness.isDark,
    );
  }

  static AppSettingsNotifier load() {
    String? appSettingsJson = SharedPrefs.getString('AppSettings');

    if (appSettingsJson != null) {
      return AppSettingsNotifier.fromJson(appSettingsJson);
    } else {
      return AppSettingsNotifier();
    }
  }

  void save() {
    SharedPrefs.setString('AppSettings', toJson());
  }

  AccentColor get systemAccentColor {
    return AccentColor.swatch({
      'darkest': SystemTheme.accentColor.darkest,
      'darker': SystemTheme.accentColor.darker,
      'dark': SystemTheme.accentColor.dark,
      'normal': SystemTheme.accentColor.accent,
      'light': SystemTheme.accentColor.light,
      'lighter': SystemTheme.accentColor.lighter,
      'lightest': SystemTheme.accentColor.lightest,
    });
  }
}
