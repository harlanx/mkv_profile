import 'package:flutter/gestures.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';
import 'package:win32/win32.dart';
import 'package:intl/intl.dart';

import '../../../data/app_data.dart';
import '../../../utilities/utilities.dart';
import '../settings_screen_dialogs.dart';
import 'profile_page/profile_page.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<UserProfilesNotifier>();
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return InfoLabel(
      label: l10n.preferences,
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
            Card(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.fabric_folder_search),
                  const SizedBox(width: 6),
                  Text(
                    l10n.directoryScanLimit,
                    style: theme.typography.body,
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Selector<AppSettingsNotifier, int>(
                      selector: (p0, p1) => p1.recursiveLimit,
                      builder: (context, value, child) {
                        return NumberBox<int>(
                          value: value,
                          mode: SpinButtonPlacementMode.compact,
                          largeChange: 5,
                          smallChange: 1,
                          min: 20,
                          max: 150,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<AppSettingsNotifier>()
                                  .setRecursiveLimit(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Card(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.processing),
                  const SizedBox(width: 6),
                  Text.rich(
                    TextSpan(
                      text: '${l10n.maxActiveProcess} ',
                      children: [
                        WidgetSpan(
                          child: Tooltip(
                            message: l10n.maxActiveProcessHint,
                            child: RichText(
                              text: TextSpan(
                                text: '[?]',
                                style: theme.typography.bodyStrong?.copyWith(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    const url =
                                        'https://www.reddit.com/r/mkvtoolnix/comments/pee0h0/comment/hawy8bv/?utm_source=reddit&utm_medium=web2x&context=3';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    style: theme.typography.body,
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Selector<AppSettingsNotifier, int>(
                      selector: (p0, p1) => p1.maximumProcess,
                      builder: (context, value, child) {
                        return NumberBox<int>(
                          value: value,
                          mode: SpinButtonPlacementMode.compact,
                          largeChange: 3,
                          smallChange: 1,
                          min: 1,
                          max: 30,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<AppSettingsNotifier>()
                                  .setMaximumProcess(value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expander(
              leading: const Icon(FluentIcons.boards),
              header: Text(l10n.profiles),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.chevron_up_end6),
                        const SizedBox(width: 8),
                        Text(l10n.import),
                      ],
                    ),
                    onPressed: () async {
                      final XFile? file = await openFile(
                        acceptedTypeGroups: [
                          const XTypeGroup(
                            extensions: ['json'],
                          ),
                        ],
                      );
                      if (file != null) {
                        await profiles.import(file.path);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Button(
                    onPressed: () async {
                      final FileSaveLocation? output = await getSaveLocation(
                        suggestedName:
                            'MKVProfile_${DateFormat('MMddy_HmsSSS').format(DateTime.now())}',
                        initialDirectory: FOLDERID_Downloads,
                        acceptedTypeGroups: [
                          const XTypeGroup(
                            extensions: ['json'],
                          ),
                        ],
                        confirmButtonText: l10n.save,
                      );
                      if (output != null) {
                        final outputPath = '${output.path}.json';
                        await profiles.export(outputPath);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.chevron_down_end6),
                        const SizedBox(width: 8),
                        Text(l10n.export),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.circle_addition_solid),
                        const SizedBox(width: 8),
                        Text(l10n.create),
                      ],
                    ),
                    onPressed: () async {
                      final int? profileID = await showDialog<int?>(
                        context: context,
                        builder: (context) => CreateProfileDialog(
                            templates: profiles.items.values.toList()),
                      );
                      if (context.mounted && profileID != null) {
                        await Navigator.push(
                          context,
                          FluentPageRoute(
                            builder: (context) {
                              return ProfilePage(
                                sourceProfile: profiles.items[profileID]!,
                                isNew: true,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.from(
                  profiles.items.values.map(
                    (p) {
                      // Default profiles' id
                      final isDefault = p.id <= 2;
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
                                                sourceProfile: p,
                                                isNew: false,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(FluentIcons.delete),
                                onPressed: !isDefault
                                    ? () async {
                                        await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return DeleteDialog(
                                                  l10n.profile, p.name);
                                            }).then(
                                          (value) {
                                            if (value ?? false) {
                                              // Set profile to none if it's assigned to anything before it gets deleted.
                                              context
                                                  .read<ShowListNotifier>()
                                                  .modifiedProfile(p);
                                              context
                                                  .read<TaskListNotifier>()
                                                  .modifiedProfile(p);
                                              profiles.remove(p.id);
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
