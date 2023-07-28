import 'package:fluent_ui/fluent_ui.dart';

import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../models/models.dart';
import '../../utilities/utilities.dart';

class HomeScreenMenuBar extends StatelessWidget {
  const HomeScreenMenuBar({super.key, required this.selectedID});
  final ValueNotifier<int?> selectedID;

  @override
  Widget build(BuildContext context) {
    final shows = context.read<ShowListNotifier>();
    final tasks = context.read<TaskListNotifier>();
    final profiles = context.read<UserProfilesNotifier>();
    final l10n = AppLocalizations.of(context);

    return CommandBarCard(
      child: ValueListenableBuilder<int?>(
        valueListenable: selectedID,
        builder: (context, id, _) {
          return Row(
            children: [
              Flexible(
                child: CommandBar(
                  overflowBehavior: CommandBarOverflowBehavior.scrolling,
                  overflowItemAlignment: MainAxisAlignment.end,
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.fabric_new_folder),
                      label: Text(l10n.addFolder),
                      onPressed: () async => await _openFolder(context),
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.delete),
                      label: Text(l10n.removeAll),
                      onPressed: shows.items.isEmpty
                          ? null
                          : () {
                              shows.removeAll();
                              selectedID.value = null;
                            },
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.build_queue_new),
                      label: Text(l10n.addToQueue),
                      onPressed: selectedID.value != null
                          ? () => tasks.add(shows.items[selectedID.value]!)
                          : null,
                    ),
                  ],
                ),
              ),
              if (selectedID.value != null)
                ChangeNotifierProvider<ShowNotifier>.value(
                  value: shows.items[selectedID.value]!,
                  child: Consumer<ShowNotifier>(
                    builder: (context, show, child) {
                      return IntrinsicWidth(
                        child: CommandBar(
                          overflowBehavior: CommandBarOverflowBehavior.noWrap,
                          primaryItems: [
                            CommandBarCombobox<UserProfile>(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(FluentIcons.boards),
                                  const SizedBox(width: 6),
                                  Text('${l10n.profiles}:'),
                                ],
                              ),
                              value: show.profile,
                              width: 200,
                              items: List.from(
                                profiles.items.values.map(
                                  (e) => ComboBoxItem<UserProfile>(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value != null) {
                                  show.updateProfile(value);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openFolder(BuildContext context) async {
    final shows = context.read<ShowListNotifier>();
    final paths = await getDirectoryPaths();

    await shows.add(paths);
  }
}
