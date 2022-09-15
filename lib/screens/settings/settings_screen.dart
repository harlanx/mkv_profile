import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'profile_page/profile_page.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<UserProfilesNotifier>();
    final appSettings = context.watch<AppSettingsNotifier>();
    return ScaffoldPage.scrollable(
      key: const PageStorageKey('Settings'),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      header: const PageHeader(title: Text('Settings')),
      children: [
        InfoLabel(
          label: 'Preferences',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Card(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(4),
                    child: ListTile(
                      leading: const Icon(FluentIcons.fabric_folder_search),
                      title: Text('Directory scan limit',
                          style: FluentTheme.of(context).typography.body),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: NumberBox<int>(
                          value: appSettings.recursiveLimit,
                          mode: SpinButtonPlacementMode.none,
                          largeChange: 5,
                          smallChange: 1,
                          min: 20,
                          max: 150,
                          onChanged: (value) {
                            if (value != null) {
                              appSettings.setRecursiveLimit(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expander(
                  leading: const Icon(FluentIcons.boards),
                  header: const Text('Profiles'),
                  trailing: FilledButton(
                    child: const Text('Create'),
                    onPressed: () => _createProfileDialog(context),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: profiles.items.values.map(
                      (p) {
                        // Default profiles' id
                        final isDefault = p.id == 0 || p.id == 1 || p.id == 2;
                        return Card(
                          padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                          borderRadius: BorderRadius.circular(4),
                          child: ListTile(
                            title: Text(p.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FluentIcons.edit),
                                  onPressed: !isDefault
                                      ? () {
                                          Navigator.push(
                                            context,
                                            FluentPageRoute(
                                              builder: (context) {
                                                return ProfilePage(
                                                  id: p.id,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                                const SizedBox(width: 5),
                                IconButton(
                                  icon: const Icon(FluentIcons.delete),
                                  onPressed: !isDefault
                                      ? () async {
                                          await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return DeleteDialog(
                                                    'profile', p.name);
                                              }).then(
                                            (value) {
                                              if (value ?? false) {
                                                // Set profile to none if it's assigned to anything before it gets deleted.
                                                context
                                                    .read<TaskListNotifier>()
                                                    .modifiedProfile(p);
                                                context
                                                    .read<ShowListNotifier>()
                                                    .modifiedProfile(p);
                                                profiles.delete(p.id);
                                              }
                                            },
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        InfoLabel(
          label: 'Personalization',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                Expander(
                  leading: const Icon(FluentIcons.circle_half_full),
                  header: const Text('App Theme'),
                  trailing: Text(
                    appSettings.themeMode.name.toTitleCase(),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: ThemeMode.values
                        .map(
                          (e) => Padding(
                            padding: ViewMode.values.last == e
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(bottom: 10.0),
                            child: RadioButton(
                              content: Text(e.name.toTitleCase()),
                              checked: appSettings.themeMode == e,
                              onChanged: (value) {
                                appSettings.setThemeMode(e);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    appSettings.applyWindowEffect(
                                        appSettings.windowEffect, context);
                                  });
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expander(
                  leading: const Icon(FluentIcons.format_painter),
                  header: const Text('Window Effect'),
                  trailing: Text(appSettings.windowEffect.name.toTitleCase()),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: WindowsFluentEffect.values
                        .map(
                          (e) => Padding(
                            padding: WindowsFluentEffect.values.last == e
                                ? EdgeInsets.zero
                                : const EdgeInsets.only(bottom: 10.0),
                            child: RadioButton(
                              content: Text(e.name.toTitleCase()),
                              checked: appSettings.windowEffect == e,
                              onChanged: (value) async {
                                appSettings.setWindowEffect(e);
                                appSettings.applyWindowEffect(e, context);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        InfoLabel(
          label: 'About',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          child: const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Future<void> _createProfileDialog(BuildContext context) async {
    var templates = {0: 'Empty', 1: 'Movie', 2: 'Series'};
    var selected = ValueNotifier(0);
    return await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Create New Profile'),
        content: ValueListenableBuilder<int>(
          valueListenable: selected,
          builder: (context, value, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select Template: '),
                ComboBox<int>(
                  value: value,
                  onChanged: (choice) {
                    if (choice != null) selected.value = choice;
                  },
                  items: templates.entries
                      .map((e) => ComboBoxItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          FilledButton(
            child: const Text('Continue'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                FluentPageRoute(
                  builder: (context) {
                    return ProfilePage(
                      id: selected.value,
                    );
                  },
                ),
              );
            },
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
