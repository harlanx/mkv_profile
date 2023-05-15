import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import '../data/app_data.dart';
import '../screens/main_screen.dart';

void main() async {
  // flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  // system_theme
  // We could use windows_ui package instead but as of
  // writing this app it has some dependency constraint issues.
  await SystemTheme.accentColor.load();
  // flutter_acrylic
  await Window.initialize();
  await Window.hideWindowControls();
  // window_manager
  await WindowManager.instance.ensureInitialized();
  // this app
  await AppData.init();

  var windowOptions = WindowOptions(
    fullScreen: AppData.appSettings.isMaximized,
    size: AppData.appSettings.windowSize,
    minimumSize: const Size(800, 500),
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    center: true,
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    await windowManager.show();
    // Handles default title bar theme changes at startup
    // await windowManager.setBrightness(
    //   SystemTheme.isDarkMode ? Brightness.dark : Brightness.light,
    // );
  });
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
      await AppData.save().then((value) async {
        await windowManager.destroy();
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    // Update app theme when user changes dark or light mode in windows personalization settings
    AppData.appSettings.setThemeMode(AppData.appSettings.themeMode);

    // Force update window effect since it won't match the thememode light
    // and dark mode colors if changed on runtime.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        AppData.appSettings.setWindowEffect(
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
        return FluentApp(
          //showPerformanceOverlay: true,
          debugShowCheckedModeBanner: false,
          title: AppData.appTitle,
          navigatorKey: AppData.mainNavigatorKey,
          color: appSettings.accentColor,
          themeMode: appSettings.themeMode,
          theme: appSettings.lightTheme,
          darkTheme: appSettings.darkTheme,
          initialRoute: '/',
          home: const MainScreen(),
        );
      },
    );
  }
}
