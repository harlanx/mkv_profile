import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import '../data/app_data.dart';
import '../screens/main_screen.dart';
import '../utilities/utilities.dart';

void main() async {
  // flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  // this app
  await AppData.init();
  // system_theme
  await SystemTheme.accentColor.load();
  // flutter_acrylic
  await Window.initialize();
  await Window.hideWindowControls();
  // window_manager
  await windowManager.ensureInitialized();

  final windowOptions = WindowOptions(
    minimumSize: const Size(800, 500),
    size: AppData.appSettings.windowSize,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    center: true,
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
  );

  // Causes app frame freeze on hot reload or hot restart so don't await this one.
  // ignore: unawaited_futures
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    if (AppData.appSettings.isMaximized) {
      await windowManager.maximize();
    }

    // Handles default title bar theme changes at startup
    // await windowManager.setBrightness(
    //   SystemTheme.isDarkMode ? Brightness.dark : Brightness.light,
    // );
  });
  // Disables any printing in production.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (AppData.tasks.active) {
      await windowManager.minimize();
    } else {
      await AppData.save();
      await windowManager.destroy();
    }
    super.onWindowClose();
  }

  @override
  void onWindowResize() async {
    AppData.appSettings.windowSize = await windowManager.getSize();
    super.onWindowResize();
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    AppData.appSettings.isMaximized = true;
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    AppData.appSettings.isMaximized = false;
  }

  @override
  void didChangePlatformBrightness() {
    // Update app theme when user changes dark or light mode in windows personalization settings
    AppData.appSettings.setThemeMode(AppData.appSettings.themeMode);

    // Force update window effect since it won't match the thememode light
    // and dark mode colors if changed on runtime.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 150), () async {
        await AppData.appSettings.setWindowEffect(
            AppData.mainNavigatorKey.currentContext!,
            AppData.appSettings.windowEffect);
      });
    });

    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PageNotifier>(
          create: (context) => PageNotifier(),
        ),
        ChangeNotifierProvider<ShowListNotifier>(
            create: (_) => ShowListNotifier()),
        ChangeNotifierProvider<TaskListNotifier>.value(value: AppData.tasks),
        ChangeNotifierProvider<AppSettingsNotifier>.value(
            value: AppData.appSettings),
        ChangeNotifierProvider<OutputNotifier>.value(value: AppData.outputs),
        ChangeNotifierProvider<UserProfilesNotifier>.value(
            value: AppData.profiles),
      ],
      builder: (context, _) {
        final appSettings = context.watch<AppSettingsNotifier>();
        return SystemThemeBuilder(
          builder: (context, systemAccent) {
            appSettings.currentSystemAccent = systemAccent;
            return FluentApp(
              //showPerformanceOverlay: true,
              debugShowCheckedModeBanner: false,
              title: AppData.appTitle,
              navigatorKey: AppData.mainNavigatorKey,
              color: appSettings.accentColor,
              themeMode: appSettings.themeMode,
              theme: appSettings.lightTheme,
              darkTheme: appSettings.darkTheme,
              localizationsDelegates: [
                // Defined localizations that isn't available from fluent_ui package yet.
                // Use i18n manager for locally managing translations
                // though unmaintained, it's still working as expected
                // https://github.com/gilmarsquinelato/i18n-manager
                CustomFluentLocalizationDelegate(),
                // fluent_ui localization delegate
                FluentLocalizations.delegate,
                // Generated localization delegates
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: const [...AppLocalizations.supportedLocales],
              locale: appSettings.locale,
              localeResolutionCallback: (locale, supportedLocales) {
                if (AppLocalizations.supportedLocales.contains(locale)) {
                  return locale;
                }
                // Locale fallback
                return const Locale('en');
              },
              initialRoute: '/',
              home: const MainScreen(),
            );
          },
        );
      },
    );
  }
}
