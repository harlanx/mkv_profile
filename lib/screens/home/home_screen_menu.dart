import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:provider/provider.dart';

class HomeScreenMenuBar extends StatelessWidget {
  const HomeScreenMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    var shows = context.watch<ShowListNotifier>();
    var tasks = context.read<TaskListNotifier>();
    var profiles = context.read<UserProfilesNotifier>();
    var hasSelected = context.select<ShowListNotifier, int?>(
            (showsList) => showsList.selectedID) !=
        null;

    return CommandBarCard(
      child: Row(
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
                  onPressed:
                      shows.items.isEmpty ? null : () => shows.removeAll(),
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.build_queue_new),
                  label: const Text('Add to queue'),
                  onPressed: hasSelected
                      ? () => tasks.add(shows.items[shows.selectedID!]!)
                      : null,
                ),
              ],
            ),
          ),
          if (hasSelected)
            ChangeNotifierProvider<ShowNotifier>.value(
              value: shows.items[shows.selectedID]!,
              child: Consumer<ShowNotifier>(
                builder: (context, show, child) {
                  return IntrinsicWidth(
                    child: CommandBar(
                      overflowBehavior: CommandBarOverflowBehavior.noWrap,
                      primaryItems: [
                        CommandBarCombobox<UserProfile>(
                          icon: const Icon(FluentIcons.boards),
                          label: const Text('Profiles:'),
                          value: show.profile,
                          width: 200,
                          items: profiles.items.values
                              .map((e) => ComboBoxItem<UserProfile>(
                                  value: e, child: Text(e.name)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) show.updateProfile(value);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openFolder(BuildContext context) async {
    var shows = context.read<ShowListNotifier>();
    await FilePicker.platform.getDirectoryPath().then((path) {
      if (path != null) shows.add([path]);
    });
  }
}
