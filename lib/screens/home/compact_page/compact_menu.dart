import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:provider/provider.dart';

class CompactMenuBar extends StatelessWidget {
  const CompactMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    var shows = context.watch<ShowListNotifier>();
    var showsQueue = context.read<ShowQueueListNotifier>();
    var profiles = context.read<UserProfilesNotifier>();
    var hasSelected = context.select<ShowListNotifier, int?>((showsList) => showsList.selectedIndex) != null;

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
                  onPressed: () => _openFolder(context),
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.delete),
                  label: const Text('Remove All'),
                  onPressed: () => shows.removeShows(),
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.build_queue_new),
                  label: const Text('Add to queue'),
                  onPressed: hasSelected ? () => showsQueue.addQueue(shows.items[shows.selectedIndex!]) : null,
                ),
              ],
            ),
          ),
          if (hasSelected)
            ChangeNotifierProvider.value(
              value: shows.items.elementAt(shows.selectedIndex!),
              child: Consumer<ShowNotifier>(
                builder: (context, show, child) {
                  return IntrinsicWidth(
                    child: CommandBar(
                      overflowBehavior: CommandBarOverflowBehavior.noWrap,
                      primaryItems: [
                        CommandBarCombobox<int>(
                          icon: const Icon(FluentIcons.boards),
                          label: const Text('Profiles:'),
                          value: show.profileIndex,
                          width: 200,
                          items: profiles.items
                              .mapIndexed((index, e) => ComboboxItem<int>(value: index, child: Text(e.name)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) show.updateProfileIndex(value);
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

  _openFolder(BuildContext context) async {
    var shows = context.read<ShowListNotifier>();
    await FilePicker.platform.getDirectoryPath().then((path) {
      if (path != null) shows.addShow([path]);
    });
  }
}
