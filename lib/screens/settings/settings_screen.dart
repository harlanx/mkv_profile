import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as mt;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win32/win32.dart';

import '../../data/app_data.dart';
import '../../services/app_services.dart';
import '../../utilities/utilities.dart';

import 'settings_screen_dialogs.dart';
import 'profile_page/profile_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      key: const PageStorageKey('Settings'),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      header: PageHeader(title: Text(AppLocalizations.of(context).settings)),
      children: const [
        PreferencesSection(),
        PersonalizationSection(),
        MiscSection(),
      ],
    );
  }
}

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsNotifier>();
    final profiles = context.watch<UserProfilesNotifier>();
    return InfoLabel(
      label: AppLocalizations.of(context).preferences,
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
                    AppLocalizations.of(context).directoryScanLimit,
                    style: FluentTheme.of(context).typography.body,
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: NumberBox<int>(
                      value: appSettings.recursiveLimit,
                      mode: SpinButtonPlacementMode.compact,
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
                      text: '${AppLocalizations.of(context).maxActiveProcess} ',
                      children: [
                        WidgetSpan(
                          child: Tooltip(
                            message: AppLocalizations.of(context)
                                .maxActiveProcessHint,
                            child: RichText(
                              text: TextSpan(
                                text: '[?]',
                                style: FluentTheme.of(context)
                                    .typography
                                    .bodyStrong
                                    ?.copyWith(
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
                    style: FluentTheme.of(context).typography.body,
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: NumberBox<int>(
                      value: appSettings.maximumProcess,
                      mode: SpinButtonPlacementMode.compact,
                      largeChange: 3,
                      smallChange: 1,
                      min: 1,
                      max: 30,
                      onChanged: (value) {
                        if (value != null) {
                          appSettings.setMaximumProcess(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expander(
              leading: const Icon(FluentIcons.boards),
              header: Text(AppLocalizations.of(context).profiles),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.chevron_up_end6),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).import),
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
                        profiles.import(file.path);
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
                        confirmButtonText: AppLocalizations.of(context).save,
                      );
                      if (output != null) {
                        final outputPath = '${output.path}.json';
                        profiles.export(outputPath);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.chevron_down_end6),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).export),
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
                        Text(AppLocalizations.of(context).create),
                      ],
                    ),
                    onPressed: () async {
                      final int? profileID = await showDialog<int?>(
                        context: context,
                        builder: (context) => CreateProfileDialog(
                            templates: profiles.items.values.toList()),
                      );
                      if (context.mounted && profileID != null) {
                        Navigator.push(
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
                                                  AppLocalizations.of(context)
                                                      .profile,
                                                  p.name);
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

class PersonalizationSection extends StatelessWidget {
  const PersonalizationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsNotifier>();
    return InfoLabel(
      label: AppLocalizations.of(context).personalization,
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
                  const Icon(FluentIcons.globe),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).language,
                    style: FluentTheme.of(context).typography.body,
                  ),
                  const Spacer(),
                  ComboBox<String>(
                    value: appSettings.locale.languageCode,
                    items: [
                      for (var locale in AppLocalizations.supportedLocales)
                        ComboBoxItem(
                          value: locale.languageCode,
                          child: RichText(
                            text: TextSpan(
                              text: locale.flagEmoji,
                              style: FluentTheme.of(context)
                                  .typography
                                  .body
                                  ?.copyWith(
                                      fontFamily: 'NotoColorEmojiWindows'),
                              children: [
                                TextSpan(
                                  text: ' ${locale.name}',
                                  style: FluentTheme.of(context)
                                      .typography
                                      .bodyStrong,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        appSettings.setLocale(
                          AppLocalizations.supportedLocales
                              .singleWhere((sl) => sl.languageCode == value),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Expander(
              leading: const Icon(FluentIcons.circle_half_full),
              header: Text(AppLocalizations.of(context).theme),
              trailing: Text(
                appSettings.themeMode.name.titleCased,
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.from(
                  ThemeMode.values.map(
                    (e) => Padding(
                      padding: ThemeMode.values.last == e
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(bottom: 10.0),
                      child: RadioButton(
                        content: Text(e.name.titleCased),
                        checked: appSettings.themeMode == e,
                        onChanged: (value) async {
                          appSettings.setThemeMode(e);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await Future.delayed(
                                const Duration(milliseconds: 150), () async {
                              await appSettings.setWindowEffect(
                                  context, appSettings.windowEffect);
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expander(
              leading: const Icon(FluentIcons.format_painter),
              header: Text(AppLocalizations.of(context).windowEffect),
              trailing: Text(appSettings.windowEffect.name.titleCased),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.from(
                  WindowsFluentEffect.values.map(
                    (e) => Padding(
                      padding: WindowsFluentEffect.values.last == e
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(bottom: 10.0),
                      child: RadioButton(
                        content: Text(e.name.titleCased),
                        checked: appSettings.windowEffect == e,
                        onChanged: (value) {
                          appSettings.setWindowEffect(context, e);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expander(
              leading: const Icon(FluentIcons.color),
              header: Text(AppLocalizations.of(context).accent),
              trailing: Card(
                backgroundColor: FluentTheme.of(context).accentColor,
                child: const SizedBox(
                  height: 4,
                  width: 4,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).mode}: ',
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                      ComboBox<AccentMode>(
                        value: appSettings.accentMode,
                        items: List.from(
                          AccentMode.values.map(
                            (e) => ComboBoxItem<AccentMode>(
                              value: e,
                              child: Text(e.name.titleCased),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            appSettings.setAccentMode(val);
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      for (var color in FluentTheme.of(context)
                          .accentColor
                          .swatch
                          .entries) ...[
                        Container(
                          height: 20,
                          width: 20,
                          color: color.value,
                        ),
                      ],
                      if (kDebugMode) ...[
                        const SizedBox(width: 6),
                        Builder(
                          builder: (context) {
                            final color = HSLColor.fromColor(
                                FluentTheme.of(context).accentColor);
                            return Row(
                              children: [
                                Text(color.hue.toString()),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  Visibility(
                    visible: appSettings.accentMode == AccentMode.custom,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: mt.Material(
                        child: ColorPicker(
                          color: appSettings.customAccent,
                          enableOpacity: false,
                          enableTonalPalette: false,
                          showColorCode: true,
                          showRecentColors: true,
                          enableShadesSelection: false,
                          recentColors: [
                            for (var colorInt in AppData.defaultAccents) ...[
                              Color(colorInt),
                            ],
                          ],
                          pickersEnabled: const {
                            ColorPickerType.both: false,
                            ColorPickerType.primary: true,
                            ColorPickerType.accent: false,
                            ColorPickerType.bw: false,
                            ColorPickerType.custom: false,
                            ColorPickerType.wheel: true,
                          },
                          onColorChanged: (val) {
                            appSettings.setAccentColor(val);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiscSection extends StatelessWidget {
  const MiscSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettingsNotifier>();

    return InfoLabel(
      label: AppLocalizations.of(context).misc,
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
            Expander(
              leading: const Icon(FluentIcons.packages),
              header: Text(AppLocalizations.of(context).tools),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context).toolLocation('MediaInfo')}: ',
                      children: [
                        TextSpan(
                          text: '[${AppLocalizations.of(context).download}]',
                          style: FluentTheme.of(context)
                              .typography
                              .bodyStrong
                              ?.copyWith(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = AppData.mediainfoURL;
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextBox(
                          readOnly: true,
                          controller: TextEditingController(
                              text: appSettings.mediaInfoPath),
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Tooltip(
                              message: AppData.mediaInfoLoaded
                                  ? AppLocalizations.of(context)
                                      .toolFound('MediaInfo')
                                  : AppLocalizations.of(context)
                                      .toolNotFound('MediaInfo'),
                              child: Icon(
                                AppData.mediaInfoLoaded
                                    ? FluentIcons.check_mark
                                    : FluentIcons.warning,
                              ),
                            ),
                          ),
                          suffix: Tooltip(
                            message: MetadataScanner.active
                                ? AppLocalizations.of(context)
                                    .toolCannotChange('MediaInfo')
                                : AppLocalizations.of(context)
                                    .toolBrowse('MediaInfo'),
                            child: IconButton(
                              icon: const Icon(
                                  FluentIcons.open_folder_horizontal),
                              onPressed: MetadataScanner.active
                                  ? null
                                  : () async {
                                      final file = await openFile(
                                        initialDirectory:
                                            File(appSettings.mediaInfoPath)
                                                .parent
                                                .path,
                                        acceptedTypeGroups: [
                                          const XTypeGroup(
                                            label: 'MediaInfo',
                                            extensions: ['dll'],
                                          ),
                                        ],
                                      );
                                      if (file != null) {
                                        await appSettings
                                            .updateMediaInfoPath(file.path);
                                      }
                                    },
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Reset and use the default tool path',
                        child: IconButton(
                          icon: const Icon(FluentIcons.reset),
                          onPressed: () async {
                            await appSettings.updateMediaInfoPath(
                                AppData.defaultMediaInfoPath);
                          },
                        ),
                      ),
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context).toolLocation('MKVMerge')}: ',
                      children: [
                        TextSpan(
                          text: '[${AppLocalizations.of(context).download}]',
                          style: FluentTheme.of(context)
                              .typography
                              .bodyStrong
                              ?.copyWith(color: Colors.blue, fontSize: 12),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = AppData.mkvmergeURL;
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: TextBox(
                          readOnly: true,
                          controller: TextEditingController(
                              text: appSettings.mkvMergePath),
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Tooltip(
                              message: AppData.mkvMergeLoaded
                                  ? AppLocalizations.of(context)
                                      .toolFound('MKVMerge')
                                  : AppLocalizations.of(context)
                                      .toolNotFound('MKVMerge'),
                              child: Icon(
                                AppData.mkvMergeLoaded
                                    ? FluentIcons.check_mark
                                    : FluentIcons.warning,
                              ),
                            ),
                          ),
                          suffix: Tooltip(
                            message: ShowMerger.active
                                ? AppLocalizations.of(context)
                                    .toolCannotChange('MKVMerge')
                                : AppLocalizations.of(context)
                                    .toolBrowse('MKVMerge'),
                            child: IconButton(
                              icon: const Icon(
                                  FluentIcons.open_folder_horizontal),
                              onPressed: ShowMerger.active
                                  ? null
                                  : () async {
                                      final file = await openFile(
                                        initialDirectory:
                                            File(appSettings.mkvMergePath)
                                                .parent
                                                .path,
                                        acceptedTypeGroups: [
                                          const XTypeGroup(
                                            label: 'mkvmerge',
                                            extensions: ['exe'],
                                          )
                                        ],
                                      );
                                      if (file != null) {
                                        await appSettings
                                            .updateMkvMergePath(file.path);
                                      }
                                    },
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Reset and use the default tool path',
                        child: IconButton(
                          icon: const Icon(FluentIcons.reset),
                          onPressed: () async {
                            await appSettings.updateMkvMergePath(
                                AppData.defaultMKVMergePath);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const AboutTile(),
          ],
        ),
      ),
    );
  }
}

class AboutTile extends StatefulWidget {
  const AboutTile({
    super.key,
  });

  @override
  State<AboutTile> createState() => _AboutTileState();
}

class _AboutTileState extends State<AboutTile> {
  late final PackageInfo packageInfo;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  late final future = fetchPackageInfo();
  final isCheckingUpdate = ValueNotifier<bool>(false);

  Future<void> fetchPackageInfo() async {
    await _memoizer.runOnce(() async {
      packageInfo = await PackageInfo.fromPlatform();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expander(
      leading: const Icon(FluentIcons.info),
      header: Text(AppLocalizations.of(context).about),
      trailing: ValueListenableBuilder<bool>(
          valueListenable: isCheckingUpdate,
          builder: (context, value, child) {
            return Button(
              onPressed: !value
                  ? () async {
                      try {
                        isCheckingUpdate.value = true;
                        final url = Uri.https('api.github.com',
                            'repos/harlanx/mkv_profile/releases');
                        await http.get(url).then((response) async {
                          final List<dynamic> json = jsonDecode(response.body);
                          if (json.isNotEmpty) {
                            final String latestVersion = json.first['tag_name'];
                            if (Utilities.isNewVersionAvailable(
                                packageInfo.version,
                                latestVersion.replaceAll('v', ''))) {
                              await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return NewUpdateDialog(latestVersion);
                                  }).then((value) async {
                                if (value ??= false) {
                                  final url = json.first['html_url'];
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url));
                                  }
                                }
                              });
                            } else {
                              await displayInfoBar(context,
                                  builder: (context, close) {
                                return InfoBar(
                                  title: Text(AppLocalizations.of(context)
                                      .youAreUsingLatestVersion),
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                  severity: InfoBarSeverity.info,
                                );
                              });
                            }
                          }
                        });
                      } catch (_) {}
                      isCheckingUpdate.value = false;
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...[
                    if (value)
                      SizedBox(
                        height: FluentTheme.of(context).iconTheme.size,
                        width: FluentTheme.of(context).iconTheme.size,
                        child: const ProgressRing(),
                      )
                    else
                      const Icon(FluentIcons.history)
                  ],
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).checkUpdate),
                ],
              ),
            );
          }),
      content: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${AppLocalizations.of(context).appName}: ',
                      children: [
                        TextSpan(
                          text: packageInfo.appName,
                          style: FluentTheme.of(context).typography.body,
                        ),
                      ],
                    ),
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  Text.rich(
                    TextSpan(
                      text: '${AppLocalizations.of(context).version}: ',
                      children: [
                        TextSpan(
                          text: packageInfo.version,
                          style: FluentTheme.of(context).typography.body,
                        ),
                      ],
                    ),
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  Text.rich(
                    TextSpan(
                      text: '${AppLocalizations.of(context).build}: ',
                      children: [
                        TextSpan(
                          text: packageInfo.buildNumber.toString(),
                          style: FluentTheme.of(context).typography.body,
                        ),
                      ],
                    ),
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'GitHub: ',
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            const url = AppData.projectURL;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                          child: Image.asset(
                            'assets/icons/mkv_profile.png',
                            width: 64,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  Text(
                    AppLocalizations.of(context).appDescription,
                    style: FluentTheme.of(context).typography.body,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
    );
  }
}
