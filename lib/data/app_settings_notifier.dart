import 'package:fluent_ui/fluent_ui.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_theme/system_theme.dart';

import '../data/app_data.dart';
import '../utilities/utilities.dart';

enum WindowsFluentEffect {
  disabled(WindowEffect.disabled),
  transparent(WindowEffect.transparent),
  acrylic(WindowEffect.acrylic),
  mica(WindowEffect.mica),
  tabbed(WindowEffect.tabbed);

  const WindowsFluentEffect(this.value);
  final WindowEffect value;
}

enum AccentMode {
  system,
  custom,
}

class AppSettingsNotifier extends ChangeNotifier {
  AppSettingsNotifier({
    this.recursiveLimit = 20,
    this.maximumProcess = 1,
    this.themeMode = ThemeMode.system,
    this.accentMode = AccentMode.custom,
    this.customAccent = const Color(0xff468600),
    this.locale = const Locale('en'),
    this.windowEffect = WindowsFluentEffect.disabled,
    this.windowSize = const Size(1280, 720),
    this.isMaximized = false,
    this.folderPanelWidth = 300,
    this.infoPanelWidth = 500,
  })  : mediaInfoPath =
            '${AppData.exeDir.path}\\data\\flutter_assets\\assets\\mediainfo\\MediaInfo.dll',
        mkvMergePath =
            '${AppData.exeDir.path}\\data\\flutter_assets\\assets\\mkvmerge\\mkvmerge.exe';

  int recursiveLimit;
  int maximumProcess;
  ThemeMode themeMode;
  AccentMode accentMode;
  Color customAccent;
  Locale locale;
  WindowsFluentEffect windowEffect;
  Size windowSize;
  bool isMaximized;

  // Width sizes
  double folderPanelWidth;
  double infoPanelWidth;

  // Tools path
  String mediaInfoPath;
  String mkvMergePath;

  AppSettingsNotifier fromJson(Map<String, dynamic> json) {
    return AppSettingsNotifier(
      recursiveLimit: json['recursiveLimit'],
      maximumProcess: json['maximumProcess'],
      themeMode: ThemeMode.values.byName(json['themeMode']),
      accentMode: AccentMode.values.byName(json['accentMode']),
      customAccent: Color(json['customAccent']),
      locale: Locale(json['locale']),
      windowEffect: WindowsFluentEffect.values.byName(json['windowEffect']),
      windowSize: Size(
        json['windowSize']['width'],
        json['windowSize']['height'],
      ),
      isMaximized: json['isMaximized'],
      folderPanelWidth: json['folderPanelWidth'],
      infoPanelWidth: json['infoPanelWidth'],
    )
      ..mediaInfoPath = json['mediaInfoPath']
      ..mkvMergePath = json['mkvMergePath'];
  }

  Map<String, dynamic> toJson() => {
        'recursiveLimit': recursiveLimit,
        'maximumProcess': maximumProcess,
        'themeMode': themeMode.name,
        'accentMode': accentMode.name,
        'customAccent': customAccent.value,
        'locale': locale.languageCode,
        'windowEffect': windowEffect.name,
        'windowSize': {'width': windowSize.width, 'height': windowSize.height},
        'isMaximized': isMaximized,
        'folderPanelWidth': folderPanelWidth,
        'infoPanelWidth': infoPanelWidth,
        'mediaInfoPath': mediaInfoPath,
        'mkvMergePath': mkvMergePath,
      };

  void load() {
    final appSettingsJson = SharedPrefs.getString('AppSettings');

    if (appSettingsJson != null) {
      final data = fromJson(jsonDecode(appSettingsJson));
      recursiveLimit = data.recursiveLimit;
      maximumProcess = data.maximumProcess;
      themeMode = data.themeMode;
      accentMode = data.accentMode;
      customAccent = data.customAccent;
      locale = data.locale;
      windowEffect = data.windowEffect;
      windowSize = data.windowSize;
      isMaximized = data.isMaximized;
      folderPanelWidth = data.folderPanelWidth;
      infoPanelWidth = data.infoPanelWidth;
      mediaInfoPath = data.mediaInfoPath;
      mkvMergePath = data.mkvMergePath;
    }
  }

  Future<void> save() async {
    await SharedPrefs.setString('AppSettings', jsonEncode(this));
  }

  void setRecursiveLimit(int limit) {
    recursiveLimit = limit;
    notifyListeners();
  }

  void setMaximumProcess(int limit) {
    maximumProcess = limit;
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    // For default window title bar
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

  void setAccentMode(AccentMode accentMode) {
    this.accentMode = accentMode;
    notifyListeners();
  }

  void setAccentColor(Color customAccent) {
    this.customAccent = customAccent;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }

  Future<void> setWindowEffect(
      BuildContext context, WindowsFluentEffect effect) async {
    windowEffect = effect;
    notifyListeners();
    await Window.setEffect(
      effect: windowEffect.value,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
      ].contains(effect.value)
          ? FluentTheme.of(context).micaBackgroundColor.withOpacity(0.05)
          : Colors.transparent,
      dark: FluentTheme.of(context).brightness.isDark,
    );
  }

  Future<void> updateMediaInfoPath(String path) async {
    mediaInfoPath = path;
    await AppData.checkMediaInfo();
    notifyListeners();
  }

  Future<void> updateMkvMergePath(String path) async {
    mkvMergePath = path;
    await AppData.checkMkvMerge();
    notifyListeners();
  }

  /// The color algorithm for Windows' accent is not made for public.
  ///
  /// See discussion here:
  /// https://github.com/MicrosoftDocs/windows-dev-docs/issues/1673
  ///
  /// So when set to custom, we'll just have to rely on flex_color_scheme package
  /// and few modifications to approximately match it.
  AccentColor get accentColor {
    if (accentMode == AccentMode.system) {
      return _systemAccent;
    }
    return _customAccent;
  }

  late AccentColor _systemAccent;

  set currentSystemAccent(SystemAccentColor systemAccent) {
    _systemAccent = AccentColor.swatch({
      'darkest': systemAccent.darkest,
      'darker': systemAccent.darker,
      'dark': systemAccent.dark,
      'normal': systemAccent.accent,
      'light': systemAccent.light,
      'lighter': systemAccent.lighter,
      'lightest': systemAccent.lightest,
    });
  }

  AccentColor get _customAccent {
    // You can create schemes using SeedColorScheme.fromSeeds or FlexSchemeColor.from
    // but they generate very different schemes.
    // We'll just prefer SeedColorScheme since it providers more color options.
    final colorScheme = SeedColorScheme.fromSeeds(
      primaryKey: customAccent,
      tones: FlexTones.vivid(
          WidgetsBinding.instance.platformDispatcher.platformBrightness),
    );

    final tones = FlexCorePalette.fromSeeds(
      primary: colorScheme.primary.value,
    ).primary;
    final lighter = HSLColor.fromColor(Color(tones.get(60)));
    final isThemeDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    final isLighterSpec = lighter.hue >= 39.0 && lighter.hue <= 194;
    final higherSpecColor = HSLColor.fromColor(Color(tones.get(60)))
        .withSaturation(1.0)
        .withLightness(0.65);
    final lowerSpecColor = HSLColor.fromColor(Color(tones.get(60)))
        .withSaturation(1.0)
        .withLightness(0.55);
    final newLighter = (isThemeDark && isLighterSpec)
        ? lowerSpecColor.toColor()
        : higherSpecColor.toColor();

    return AccentColor.swatch({
      'darkest': Color(tones.get(10)),
      'darker': Color(tones.get(20)),
      'dark': Color(tones.get(40)),
      'normal': customAccent,
      'light': Color(tones.get(50)),
      'lighter': newLighter,
      'lightest': Color(tones.get(70)),
    });
  }

  FluentThemeData get lightTheme => FluentThemeData(
        brightness: Brightness.light,
        accentColor: accentColor,
        visualDensity: VisualDensity.standard,
        navigationPaneTheme: NavigationPaneThemeData(
          highlightColor: accentColor,
          backgroundColor: windowEffect.value != WindowEffect.disabled
              ? Colors.transparent
              : null,
        ),
        tooltipTheme: const TooltipThemeData(
          padding: EdgeInsets.all(8),
          showDuration: Duration.zero,
          waitDuration: Duration.zero,
        ),
        infoBarTheme: InfoBarThemeData(
          decoration: (severity) {
            late Color color;
            final theme = FluentThemeData.light();
            switch (severity) {
              case InfoBarSeverity.info:
                // Microsoft UI's InfoBar info background has transparency.
                // Override to menu color.
                color = theme.menuColor;
                break;
              case InfoBarSeverity.warning:
                color = theme.resources.systemFillColorCautionBackground;
                break;
              case InfoBarSeverity.success:
                color = theme.resources.systemFillColorSuccessBackground;
                break;
              case InfoBarSeverity.error:
                color = theme.resources.systemFillColorCriticalBackground;
                break;
            }
            return BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: theme.resources.cardStrokeColorDefault,
              ),
            );
          },
        ),
      );

  FluentThemeData get darkTheme => FluentThemeData(
        brightness: Brightness.dark,
        accentColor: accentColor,
        visualDensity: VisualDensity.standard,
        navigationPaneTheme: NavigationPaneThemeData(
          highlightColor: accentColor,
          backgroundColor: windowEffect.value != WindowEffect.disabled
              ? Colors.transparent
              : null,
        ),
        tooltipTheme: const TooltipThemeData(
          padding: EdgeInsets.all(8),
          showDuration: Duration.zero,
          waitDuration: Duration.zero,
        ),
        infoBarTheme: InfoBarThemeData(
          decoration: (severity) {
            late Color color;
            final theme = FluentThemeData.dark();
            switch (severity) {
              case InfoBarSeverity.info:
                // Microsoft UI's InfoBar info background has transparency.
                // Override to menu color.
                color = theme.menuColor;
                break;
              case InfoBarSeverity.warning:
                color = theme.resources.systemFillColorCautionBackground;
                break;
              case InfoBarSeverity.success:
                color = theme.resources.systemFillColorSuccessBackground;
                break;
              case InfoBarSeverity.error:
                color = theme.resources.systemFillColorCriticalBackground;
                break;
            }
            return BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: theme.resources.cardStrokeColorDefault,
              ),
            );
          },
        ),
      );
}
