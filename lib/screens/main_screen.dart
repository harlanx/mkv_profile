import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShowListNotifier>(create: (_) => ShowListNotifier()),
        ChangeNotifierProvider<ShowQueueListNotifier>(create: (_) => ShowQueueListNotifier()),
        ChangeNotifierProvider<UserProfilesNotifier>.value(value: AppData.profiles),
      ],
      child: NavigationView(
        appBar: FluentAppBar(),
        pane: NavigationPane(
          selected: appData.currentPage,
          onChanged: (index) => appData.updatePage(index),
          displayMode: PaneDisplayMode.auto,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Home'),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.build_queue),
              title: const Text('Queue'),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.test_impact_solid),
              title: const Text('Testing'),
            ),
          ],
          footerItems: [
            PaneItemSeparator(),
            PaneItem(icon: const Icon(FluentIcons.settings), title: const Text('Settings')),
          ],
        ),
        content: NavigationBody(
          index: appData.currentPage,
          children: screens,
        ),
      ),
    );
  }
}
