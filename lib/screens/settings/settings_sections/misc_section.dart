import 'package:flutter/gestures.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:file_selector/file_selector.dart';
import 'package:version/version.dart';

import '../../../data/app_data.dart';
import '../../../services/app_services.dart';
import '../../../utilities/utilities.dart';
import '../settings_screen_dialogs.dart';

class MiscSection extends StatelessWidget {
  const MiscSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InfoLabel(
      label: l10n.misc,
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
            const ToolsTile(),
            AboutTile(),
          ],
        ),
      ),
    );
  }
}

class ToolsTile extends StatelessWidget {
  const ToolsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Expander(
      leading: const Icon(FluentIcons.packages),
      header: Text(l10n.tools),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: '${l10n.toolLocation('MediaInfo')}: ',
              children: [
                TextSpan(
                  text: '[${l10n.download}]',
                  style: theme.typography.bodyStrong?.copyWith(
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
          Selector<AppSettingsNotifier, String>(
            selector: (p0, p1) => p1.mediaInfoPath,
            builder: (context, value, child) {
              return Row(
                children: [
                  Flexible(
                    child: TextBox(
                      readOnly: true,
                      controller: TextEditingController(text: value),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Tooltip(
                          message: AppData.mediaInfoLoaded
                              ? l10n.toolFound('MediaInfo')
                              : l10n.toolNotFound('MediaInfo'),
                          child: Icon(
                            AppData.mediaInfoLoaded
                                ? FluentIcons.check_mark
                                : FluentIcons.warning,
                          ),
                        ),
                      ),
                      suffix: Tooltip(
                        message: MetadataScanner.active
                            ? l10n.toolCannotChange('MediaInfo')
                            : l10n.toolBrowse('MediaInfo'),
                        child: IconButton(
                          icon: const Icon(FluentIcons.open_folder_horizontal),
                          onPressed: MetadataScanner.active
                              ? null
                              : () async {
                                  await openFile(
                                    initialDirectory: File(value).parent.path,
                                    acceptedTypeGroups: [
                                      const XTypeGroup(
                                        label: 'MediaInfo',
                                        extensions: ['dll'],
                                      ),
                                    ],
                                  ).then((file) async {
                                    if (file != null) {
                                      await context
                                          .read<AppSettingsNotifier>()
                                          .updateMediaInfoPath(file.path);
                                    }
                                  });
                                },
                        ),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: l10n.resetAndUseDefault,
                    child: IconButton(
                      icon: const Icon(FluentIcons.reset),
                      onPressed: () async {
                        await context
                            .read<AppSettingsNotifier>()
                            .updateMediaInfoPath(AppData.defaultMediaInfoPath);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          Text.rich(
            TextSpan(
              text: '${l10n.toolLocation('MKVMerge')}: ',
              children: [
                TextSpan(
                  text: '[${l10n.download}]',
                  style: theme.typography.bodyStrong
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
          Selector<AppSettingsNotifier, String>(
            selector: (p0, p1) => p1.mkvMergePath,
            builder: (context, value, child) {
              return Row(
                children: [
                  Flexible(
                    child: TextBox(
                      readOnly: true,
                      controller: TextEditingController(text: value),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Tooltip(
                          message: AppData.mkvMergeLoaded
                              ? l10n.toolFound('MKVMerge')
                              : l10n.toolNotFound('MKVMerge'),
                          child: Icon(
                            AppData.mkvMergeLoaded
                                ? FluentIcons.check_mark
                                : FluentIcons.warning,
                          ),
                        ),
                      ),
                      suffix: Tooltip(
                        message: ShowMerger.active
                            ? l10n.toolCannotChange('MKVMerge')
                            : l10n.toolBrowse('MKVMerge'),
                        child: IconButton(
                          icon: const Icon(FluentIcons.open_folder_horizontal),
                          onPressed: ShowMerger.active
                              ? null
                              : () async {
                                  await openFile(
                                    initialDirectory: File(value).parent.path,
                                    acceptedTypeGroups: [
                                      const XTypeGroup(
                                        label: 'mkvmerge',
                                        extensions: ['exe'],
                                      )
                                    ],
                                  ).then((file) async {
                                    if (file != null) {
                                      await context
                                          .read<AppSettingsNotifier>()
                                          .updateMkvMergePath(file.path);
                                    }
                                  });
                                },
                        ),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: l10n.resetAndUseDefault,
                    child: IconButton(
                      icon: const Icon(FluentIcons.reset),
                      onPressed: () async {
                        await context
                            .read<AppSettingsNotifier>()
                            .updateMkvMergePath(AppData.defaultMKVMergePath);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutTile extends StatelessWidget {
  AboutTile({super.key});

  final isCheckingUpdate = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Expander(
      leading: const Icon(FluentIcons.info),
      header: Text(l10n.about),
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
                          final Map<String, dynamic> latestData = json.first;
                          final currentVersion =
                              Version.parse(AppData.appInfo.version);
                          final latestVersion = Version.parse(
                              latestData['tag_name'].replaceAll('v', ''));
                          if (latestVersion > currentVersion) {
                            await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return NewUpdateDialog(latestData);
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
                                title: Text(l10n.youAreUsingLatestVersion),
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
                      height: theme.iconTheme.size,
                      width: theme.iconTheme.size,
                      child: const ProgressRing(),
                    )
                  else
                    const Icon(FluentIcons.history)
                ],
                const SizedBox(width: 8),
                Text(l10n.checkUpdate),
              ],
            ),
          );
        },
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: '${l10n.appName}: ',
              children: [
                TextSpan(
                  text: AppData.appInfo.appName,
                  style: theme.typography.body,
                ),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          Text.rich(
            TextSpan(
              text: '${l10n.version}: ',
              children: [
                TextSpan(
                  text: AppData.appInfo.version,
                  style: theme.typography.body,
                ),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          Text.rich(
            TextSpan(
              text: '${l10n.build}: ',
              children: [
                TextSpan(
                  text: AppData.appInfo.buildNumber.toString(),
                  style: theme.typography.body,
                ),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GitHub: ',
                style: theme.typography.bodyStrong,
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
            l10n.appDescription,
            style: theme.typography.body,
          ),
        ],
      ),
    );
  }
}
