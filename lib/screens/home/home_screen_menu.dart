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
    var shows = context.read<ShowListNotifier>();
    var tasks = context.read<TaskListNotifier>();
    var profiles = context.read<UserProfilesNotifier>();

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
                      label: const Text('Add folder'),
                      onPressed: () async => await _openFolder(context),
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.delete),
                      label: const Text('Remove All'),
                      onPressed: shows.items.isEmpty
                          ? null
                          : () {
                              shows.removeAll();
                              selectedID.value = null;
                            },
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.build_queue_new),
                      label: const Text('Add to queue'),
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
                              label: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(FluentIcons.boards),
                                  SizedBox(width: 6),
                                  Text('Profiles:'),
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
    var shows = context.read<ShowListNotifier>();
    var paths = await getDirectoryPaths();

    shows.add(paths);
  }
}
