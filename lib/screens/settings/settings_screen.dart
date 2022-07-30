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
    return Consumer<AppSettingsNotifier>(
      builder: (context, appSettings, child) {
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
                          title: Text('Directory scan limit', style: FluentTheme.of(context).typography.body),
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: NumberBox(
                              placementMode: SpinButtonPlacementMode.compact,
                              initialValue: appSettings.recursiveLimit,
                              step: 1,
                              min: 20,
                              max: 150,
                              onChanged: (value) {
                                if (value != null) {
                                  appSettings.setRecursiveLimit(value.toInt());
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
                        child: const Text('Create new'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            FluentPageRoute(
                              builder: (context) {
                                return ProfilePage(
                                  index: 0,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: profiles.items.mapIndexed(
                          (index, e) {
                            final isDefault = e.name == 'Default' || e.name == 'None';
                            return Card(
                              padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                              borderRadius: BorderRadius.circular(4),
                              child: ListTile(
                                title: Text(e.name),
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
                                                      index: index,
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
                                                    return DeleteDialog('profile', e.name);
                                                  }).then(
                                                (value) {
                                                  if (value ?? false) {
                                                    context.read<ShowQueueListNotifier>().deletedProfile(index);
                                                    context.read<ShowListNotifier>().deletedProfile(index);
                                                    profiles.removeProfile(index);
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
                      leading: const Icon(FluentIcons.view_all2),
                      header: const Text('View Mode'),
                      trailing: Text(
                        appSettings.viewMode.name.toTitleCase(),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: ViewMode.values
                            .map(
                              (e) => Padding(
                                padding:
                                    ViewMode.values.last == e ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10.0),
                                child: RadioButton(
                                  content: Text(e.name.toTitleCase()),
                                  checked: appSettings.viewMode == e,
                                  onChanged: (value) {
                                    appSettings.setViewMode(e);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
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
                                padding:
                                    ViewMode.values.last == e ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10.0),
                                child: RadioButton(
                                  content: Text(e.name.toTitleCase()),
                                  checked: appSettings.themeMode == e,
                                  onChanged: (value) {
                                    appSettings.setThemeMode(e);
                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                      Future.delayed(const Duration(milliseconds: 200), () {
                                        appSettings.applyWindowEffect(appSettings.windowEffect, context);
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
            const InfoLabel(
              label: 'About',
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                softWrap: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
