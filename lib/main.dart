import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // flutter bindings
  await SystemTheme.accentColor.load(); // system_theme
  await WindowManager.instance.ensureInitialized(); // window_manager
  await Window.initialize(); // flutter_acrylic
  Window.hideWindowControls(); // hide window controls of flutter_acrylic
  await AppData.init(); // this app

  var windowOptions = WindowOptions(
    fullScreen: AppData.appSettings.isMaximized,
    size: AppData.appSettings.windowSize,
    minimumSize: const Size(800, 500),
    titleBarStyle: TitleBarStyle.hidden,
    center: true,
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 200), () {
        AppData.appSettings
            .applyWindowEffect(AppData.appSettings.windowEffect, context);
      });
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    AppData.save();
    super.onWindowClose();
  }

  @override
  void didChangePlatformBrightness() async {
    SystemTheme.accentColor.load(); // reload system_theme
    AppData.appSettings
        .setThemeMode(AppData.appSettings.themeMode); // update app theme
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AppData.appSettings.applyWindowEffect(
          AppData.appSettings.windowEffect, context); // update window effect
    });
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>.value(value: AppData()),
        ChangeNotifierProvider<AppSettingsNotifier>.value(
            value: AppData.appSettings),
        ChangeNotifierProvider<ShowListNotifier>(
            create: (_) => ShowListNotifier()),
        ChangeNotifierProvider<TaskListNotifier>(
            create: (_) => TaskListNotifier()),
        ChangeNotifierProvider<OutputNotifier>.value(value: AppData.outputs),
        ChangeNotifierProvider<UserProfilesNotifier>.value(
            value: AppData.profiles),
      ],
      builder: (context, _) {
        final appSettings = context.watch<AppSettingsNotifier>();
        return FluentApp(
          title: AppData.kAppTitle,
          navigatorKey: AppData.mainNavigatorKey,
          debugShowCheckedModeBanner: false,
          color: appSettings.systemAccentColor,
          themeMode: appSettings.themeMode,
          theme: AppData.lightTheme,
          darkTheme: AppData.darkTheme,
          initialRoute: '/',
          routes: {'/': (context) => const MainScreen()},
          builder: (context, child) {
            return NavigationPaneTheme(
              data: NavigationPaneThemeData(
                highlightColor: appSettings.systemAccentColor,
                backgroundColor:
                    appSettings.windowEffect.value != WindowEffect.disabled
                        ? Colors.transparent
                        : null,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
