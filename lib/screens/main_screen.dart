import 'package:flutter/foundation.dart' as foundation;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../screens/screens.dart';
import '../services/app_services.dart';
import '../utilities/utilities.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Selector<PageNotifier, int>(
      selector: (context, page) => page.current,
      builder: (context, currentPage, child) {
        return NavigationView(
          appBar: FluentAppBar(context: context),
          pane: NavigationPane(
            selected: currentPage,
            onChanged: (index) => context.read<PageNotifier>().update(index),
            displayMode: PaneDisplayMode.auto,
            size: const NavigationPaneSize(openMaxWidth: 200),
            items: [
              PaneItem(
                key: const Key('/home'),
                icon: const Icon(FluentIcons.home),
                title: Text(l10n.home),
                body: HomeScreen(),
              ),
              PaneItem(
                key: const Key('/tasks'),
                icon: const Icon(FluentIcons.build_queue),
                title: Text(l10n.tasks),
                infoBadge: Selector<TaskListNotifier, Map<int, TaskNotifier>>(
                  selector: (context, tasks) => tasks.items,
                  shouldRebuild: (previous, next) => true,
                  builder: (context, items, _) {
                    final theme = FluentTheme.of(context);
                    if (items.isEmpty) {
                      return const SizedBox.shrink();
                    } else {
                      return InfoBadge(
                        color: theme.accentColor,
                        source: Text('${items.length}'),
                      );
                    }
                  },
                ),
                body: TasksScreen(
                  key: AppData.taskStateKey,
                ),
              ),
              PaneItem(
                key: const Key('/outputs'),
                icon: const Icon(FluentIcons.task_list),
                title: Text(l10n.outputs),
                body: OutputsScreen(
                  key: AppData.outputStateKey,
                ),
              ),
            ],
            footerItems: [
              PaneItemSeparator(),
              PaneItem(
                key: const Key('/settings'),
                icon: const Icon(FluentIcons.settings),
                title: Text(l10n.settings),
                body: const SettingsScreen(),
              ),
              if (foundation.kDebugMode) ...[
                PaneItem(
                  key: const Key('/testing'),
                  icon: const Icon(FluentIcons.test_impact_solid),
                  title: const Text('Testing Page'),
                  body: const TestScreen(),
                ),
                PaneItemAction(
                  key: const Key('/testing_button'),
                  icon: const Icon(FluentIcons.ctrl_button),
                  title: const Text('Pane Test Button'),
                  onTap: () {
                    MetadataScanner.active = !MetadataScanner.active;
                    ShowMerger.active = !ShowMerger.active;
                    debugPrint(MetadataScanner.active.toString() +
                        ShowMerger.active.toString());
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
