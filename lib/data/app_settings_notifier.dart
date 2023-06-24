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
  WindowsFluentEffect windowEffect;
  Size windowSize;
  bool isMaximized;

  // Width sizes
  double folderPanelWidth;
  double infoPanelWidth;

  // Tools path
  String mediaInfoPath;
  String mkvMergePath;

  AppSettingsNotifier fromJson(String source) {
    final Map<String, dynamic> json = jsonDecode(source);
    return AppSettingsNotifier(
      recursiveLimit: json['recursiveLimit'],
      maximumProcess: json['maximumProcess'],
      themeMode: ThemeMode.values.byName(json['themeMode']),
      accentMode: AccentMode.values.byName(json['accentMode']),
      customAccent: Color(json['customAccent']),
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
      final data = fromJson(appSettingsJson);
      recursiveLimit = data.recursiveLimit;
      maximumProcess = data.maximumProcess;
      themeMode = data.themeMode;
      accentMode = data.accentMode;
      customAccent = data.customAccent;
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

  Future<void> setThemeMode(ThemeMode themeMode) async {
    // reload system_theme
    // this is currently the only way to reload the system's accent color
    // there's no built in listener in flutter for system accent color yet
    await SystemTheme.accentColor.load();

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

  void setAccentMode(AccentMode accentMode) async {
    if (accentMode == AccentMode.system) {
      await SystemTheme.accentColor.load();
    }

    this.accentMode = accentMode;
    notifyListeners();
  }

  void setCustomAccent(Color customAccent) {
    this.customAccent = customAccent;
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

    // You can create schemes using SeedColorScheme.fromSeeds or FlexSchemeColor.from
    // but they generate very different schemes.
    // We'll just prefer SeedColorScheme since it providers more color options.
    final colorScheme = SeedColorScheme.fromSeeds(
      primaryKey: customAccent,
      tones: FlexTones.material(
          WidgetsBinding.instance.platformDispatcher.platformBrightness),
    );

    final tones = FlexCorePalette.fromSeeds(
      primary: colorScheme.primary.value,
    ).primary.asList;
    final accentHue = HSLColor.fromColor(customAccent).hue;
    final bool modify = ((accentHue >= 0 && accentHue <= 60) ||
        accentHue >= 200 && accentHue <= 360);
    final lighter = modify
        ? Color(tones[6]).saturate(1).lighten(12)
        : Color(tones[6]).lighten(30);
    return AccentColor.swatch({
      'darkest': Color(tones[2]).brighten(2).saturate(1),
      'darker': Color(tones[3]).lighten(5),
      'dark': Color(tones[4]).lighten(5),
      'normal': customAccent,
      'light': Color(tones[7]).lighten(5),
      'lighter': lighter,
      'lightest': Color(tones[9]).saturate(1).lighten(12),
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
