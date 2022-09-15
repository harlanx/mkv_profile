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
    return NavigationView(
      appBar: FluentAppBar(),
      pane: NavigationPane(
        selected: appData.currentPage,
        onChanged: (index) => appData.updatePage(index),
        displayMode: PaneDisplayMode.auto,
        size: const NavigationPaneSize(openMaxWidth: 200),
        items: [
          PaneItem(
            key: const Key('/screens/home'),
            icon: const Icon(FluentIcons.home),
            title: const Text('Home'),
            body: HomeScreen(),
          ),
          PaneItem(
            key: const Key('/screens/task'),
            icon: const Icon(FluentIcons.build_queue),
            title: const Text('Tasks'),
            body: TaskScreen(
              key: AppData.taskStateKey,
            ),
          ),
          PaneItem(
            key: const Key('/screens/output'),
            icon: const Icon(FluentIcons.task_list),
            title: const Text('Output'),
            body: OutputScreen(
              key: AppData.outputStateKey,
            ),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            key: const Key('/screens/settings'),
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: const SettingsScreen(),
          ),

          // Page for testing various components.
          // TODO: Remove/Comment out in Production
          PaneItem(
            key: const Key('/screens/testing'),
            icon: const Icon(FluentIcons.test_impact_solid),
            title: const Text('Testing'),
            body: const TestScreen(),
          ),
        ],
      ),
    );
  }
}
