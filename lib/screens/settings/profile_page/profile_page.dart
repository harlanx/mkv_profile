import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/app_data.dart';
import '../../../models/models.dart';
import '../../../utilities/utilities.dart';

import 'profile_page_dialogs.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({
    Key? key,
    required this.sourceProfile,
    required this.isNew,
  }) : super(key: key) {
    if (isNew) {
      // Default profile (Shouldn't be deleted nor edited) so we just clone it.
      // This is for creating new profile.
      editProfile = sourceProfile.copyWith(name: 'My New Profile');
    } else {
      // This is for editing existing profiles.
      editProfile = sourceProfile.copyWith();
    }
  }
  final UserProfile sourceProfile;
  late final UserProfile editProfile;
  final bool isNew;
  late final showTitleCtrl =
      TextEditingController(text: editProfile.showTitleFormat);
  late final videoTitleCtrl =
      TextEditingController(text: editProfile.videoTitleFormat);
  late final audioTitleCtrl =
      TextEditingController(text: editProfile.audioTitleFormat);
  late final subtitleTitleCtrl =
      TextEditingController(text: editProfile.subtitleTitleFormat);
  late final videoExtraCtrl =
      TextEditingController(text: editProfile.videoExtraOptions);
  late final audioExtraCtrl =
      TextEditingController(text: editProfile.audioExtraOptions);
  late final subtitleExtraCtrl =
      TextEditingController(text: editProfile.subtitleExtraOptions);
  late final attachmentExtraCtrl =
      TextEditingController(text: editProfile.attachmentExtraOptions);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async => await _onWillPop(context),
      child: NavigationView(
        appBar: FluentAppBar(context: context),
        content: ChangeNotifierProvider<UserProfile>.value(
          value: editProfile,
          builder: (context, child) {
            return Consumer<UserProfile>(
              builder: (context, profile, child) {
                return ScaffoldPage(
                  padding: EdgeInsets.zero,
                  header: CommandBarCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 8.0),
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: CommandBar(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      primaryItems: [
                        CommandBarButton(
                          icon: const Icon(FluentIcons.save),
                          label: Text(l10n.save),
                          onPressed: () => _saveChanges(context),
                        ),
                        CommandBarButton(
                          icon: const Icon(FluentIcons.cancel),
                          label: Text(l10n.cancel),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                  ),
                  content: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.name,
                            style: theme.typography.title,
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () => _updateNameDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expander(
                        header: Text(l10n.titleTemplate('Show')),
                        trailing: Text(editProfile.showTitleFormat),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: showTitleCtrl,
                              onChanged: (value) {
                                editProfile.update(showTitleFormat: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            InfoLabel(
                              label: l10n.availableVariables('Show'),
                              labelStyle: theme.typography.bodyStrong,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: '${l10n.note}: ',
                                      style: theme.typography.bodyStrong,
                                      children: [
                                        TextSpan(
                                          text: l10n.showTitleNote,
                                          style: theme.typography.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    runSpacing: 6,
                                    spacing: 6,
                                    children: [
                                      for (var variable
                                          in UserProfile.showTitleVars) ...[
                                        Button(
                                          child: Text(variable),
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                    ClipboardData(
                                                        text: variable))
                                                .then((_) {
                                              displayInfoBar(context,
                                                  builder: (context, close) {
                                                return InfoBar(
                                                  title: Text(l10n.copiedHint),
                                                  action: IconButton(
                                                    icon: const Icon(
                                                        FluentIcons.clear),
                                                    onPressed: close,
                                                  ),
                                                  severity:
                                                      InfoBarSeverity.info,
                                                );
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.titleTemplate('Video')),
                        trailing: Text(editProfile.videoTitleFormat),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: videoTitleCtrl,
                              onChanged: (value) {
                                editProfile.update(videoTitleFormat: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            InfoLabel(
                              label: l10n.availableVariables('Video'),
                              labelStyle: theme.typography.bodyStrong,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: '${l10n.note}: ',
                                      style: theme.typography.bodyStrong,
                                      children: [
                                        TextSpan(
                                          text: l10n.videoTitleNote,
                                          style: theme.typography.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    runSpacing: 6,
                                    spacing: 6,
                                    children: [
                                      for (var variable
                                          in UserProfile.videoTitleVars) ...[
                                        Button(
                                          child: Text(variable),
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                    ClipboardData(
                                                        text: variable))
                                                .then((_) {
                                              displayInfoBar(context,
                                                  builder: (context, close) {
                                                return InfoBar(
                                                  title: Text(l10n.copiedHint),
                                                  action: IconButton(
                                                    icon: const Icon(
                                                        FluentIcons.clear),
                                                    onPressed: close,
                                                  ),
                                                  severity:
                                                      InfoBarSeverity.info,
                                                );
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.titleTemplate('Audio')),
                        trailing: Text(editProfile.audioTitleFormat),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: audioTitleCtrl,
                              onChanged: (value) {
                                editProfile.update(subtitleTitleFormat: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            InfoLabel(
                              label: l10n.availableVariables('Audio'),
                              labelStyle: theme.typography.bodyStrong,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: '${l10n.note}: ',
                                      style: theme.typography.bodyStrong,
                                      children: [
                                        TextSpan(
                                          text: l10n.audioTitleNote,
                                          style: theme.typography.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    runSpacing: 6,
                                    spacing: 6,
                                    children: [
                                      for (var variable
                                          in UserProfile.audioTitleVars) ...[
                                        Button(
                                          child: Text(variable),
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                    ClipboardData(
                                                        text: variable))
                                                .then((_) {
                                              displayInfoBar(context,
                                                  builder: (context, close) {
                                                return InfoBar(
                                                  title: Text(l10n.copiedHint),
                                                  action: IconButton(
                                                    icon: const Icon(
                                                        FluentIcons.clear),
                                                    onPressed: close,
                                                  ),
                                                  severity:
                                                      InfoBarSeverity.info,
                                                );
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.titleTemplate('Subtitle')),
                        trailing: Text(editProfile.subtitleTitleFormat),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: subtitleTitleCtrl,
                              onChanged: (value) {
                                editProfile.update(subtitleTitleFormat: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            InfoLabel(
                              label: l10n.availableVariables('Subtitle'),
                              labelStyle: theme.typography.bodyStrong,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: '${l10n.note}: ',
                                      style: theme.typography.bodyStrong,
                                      children: [
                                        TextSpan(
                                          text: l10n.subtitleTitleNote,
                                          style: theme.typography.body,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    direction: Axis.horizontal,
                                    runSpacing: 6,
                                    spacing: 6,
                                    children: [
                                      for (var variable
                                          in UserProfile.subtitleTitleVars) ...[
                                        Button(
                                          child: Text(variable),
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                    ClipboardData(
                                                        text: variable))
                                                .then((_) {
                                              displayInfoBar(context,
                                                  builder: (context, close) {
                                                return InfoBar(
                                                  title: Text(l10n.copiedHint),
                                                  action: IconButton(
                                                    icon: const Icon(
                                                        FluentIcons.clear),
                                                    onPressed: close,
                                                  ),
                                                  severity:
                                                      InfoBarSeverity.info,
                                                );
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.trackExtraOptions('Video')),
                        trailing: Text(
                          editProfile.videoExtraOptions,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: videoExtraCtrl,
                              onChanged: (value) {
                                editProfile.update(videoExtraOptions: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                text: l10n.extraOptions,
                                children: [
                                  WidgetSpan(
                                    child: Tooltip(
                                      message: 'MKVMerge ${l10n.documentation}',
                                      child: RichText(
                                        text: TextSpan(
                                          text: ' [?]',
                                          style: theme.typography.bodyStrong
                                              ?.copyWith(
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const url =
                                                  r'https://mkvtoolnix.download/doc/mkvmerge.html';
                                              if (await canLaunchUrl(
                                                  Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url));
                                              }
                                            },
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ': ${l10n.extraOptionsHint}',
                                  ),
                                ],
                              ),
                              style: theme.typography.bodyStrong,
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.trackExtraOptions('Audio')),
                        trailing: Text(
                          editProfile.audioExtraOptions,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: audioExtraCtrl,
                              onChanged: (value) {
                                editProfile.update(audioExtraOptions: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                text: l10n.extraOptions,
                                children: [
                                  WidgetSpan(
                                    child: Tooltip(
                                      message: 'MKVMerge ${l10n.documentation}',
                                      child: RichText(
                                        text: TextSpan(
                                          text: ' [?]',
                                          style: theme.typography.bodyStrong
                                              ?.copyWith(
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const url =
                                                  r'https://mkvtoolnix.download/doc/mkvmerge.html';
                                              if (await canLaunchUrl(
                                                  Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url));
                                              }
                                            },
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ': ${l10n.extraOptionsHint}',
                                  ),
                                ],
                              ),
                              style: theme.typography.bodyStrong,
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.trackExtraOptions('Subtitle')),
                        trailing: Text(
                          editProfile.subtitleExtraOptions,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: subtitleExtraCtrl,
                              onChanged: (value) {
                                editProfile.update(subtitleExtraOptions: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                text: l10n.extraOptions,
                                children: [
                                  WidgetSpan(
                                    child: Tooltip(
                                      message: 'MKVMerge ${l10n.documentation}',
                                      child: RichText(
                                        text: TextSpan(
                                          text: ' [?]',
                                          style: theme.typography.bodyStrong
                                              ?.copyWith(
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const url =
                                                  r'https://mkvtoolnix.download/doc/mkvmerge.html';
                                              if (await canLaunchUrl(
                                                  Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url));
                                              }
                                            },
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ': ${l10n.extraOptionsHint}',
                                  ),
                                ],
                              ),
                              style: theme.typography.bodyStrong,
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.trackExtraOptions('Attachment')),
                        trailing: Text(
                          editProfile.attachmentExtraOptions,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBox(
                              controller: attachmentExtraCtrl,
                              onChanged: (value) {
                                editProfile.update(
                                    attachmentExtraOptions: value);
                              },
                            ),
                            const SizedBox(height: 10),
                            Text.rich(
                              TextSpan(
                                text: l10n.extraOptions,
                                children: [
                                  WidgetSpan(
                                    child: Tooltip(
                                      message: 'MKVMerge ${l10n.documentation}',
                                      child: RichText(
                                        text: TextSpan(
                                          text: ' [?]',
                                          style: theme.typography.bodyStrong
                                              ?.copyWith(
                                            color: Colors.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const url =
                                                  r'https://mkvtoolnix.download/doc/mkvmerge.html';
                                              if (await canLaunchUrl(
                                                  Uri.parse(url))) {
                                                await launchUrl(Uri.parse(url));
                                              }
                                            },
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ': ${l10n.extraOptionsHint}',
                                  ),
                                ],
                              ),
                              style: theme.typography.bodyStrong,
                            ),
                          ],
                        ),
                      ),
                      Expander(
                        header: Text(l10n.selectLanguageToInclude),
                        trailing: Visibility(
                          visible: profile.defaultLanguage.isNotEmpty,
                          child: Text(profile.defaultLanguage.isNotEmpty
                              ? AppData.languageCodes
                                  .identifyByCode(profile.defaultLanguage)
                                  .name
                              : ''),
                        ),
                        content: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(' ${l10n.languages}: '),
                                  Flexible(
                                    child: AutoSuggestBox<LanguageCode>(
                                      key: const Key('Search Languages'),
                                      trailingIcon:
                                          const Icon(FluentIcons.search),
                                      sorter: (text, items) =>
                                          Utilities.searchSorter(text, items),
                                      onSelected: (selected) {
                                        if (selected.value != null) {
                                          profile.updateLanguages(
                                              selected.value!.iso6393);
                                        }
                                      },
                                      items: List.from(
                                        AppData.languageCodes.items.map(
                                          (code) {
                                            return AutoSuggestBoxItem(
                                              value: code,
                                              label: code.fullCleanName,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: InfoLabel(
                                  label: ' ${l10n.selectedLanguages}: ',
                                  child: ReorderableListView.builder(
                                    shrinkWrap: true,
                                    buildDefaultDragHandles: false,
                                    itemCount: editProfile.languages.length,
                                    onReorder: (oldIndex, newIndex) =>
                                        editProfile.reorderLanguages(
                                            oldIndex, newIndex),
                                    proxyDecorator: (child, index, animation) =>
                                        _proxyDecorator(
                                            child, index, animation),
                                    itemBuilder: (context, index) {
                                      final code = AppData.languageCodes
                                          .identifyByCode(profile.languages
                                              .elementAt(index));

                                      final isDefault = code.iso6393 ==
                                          editProfile.defaultLanguage;
                                      return ReorderableDragStartListener(
                                        key: ValueKey(code),
                                        index: index,
                                        child: FluentTheme(
                                          data: theme,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            onPressed: () {},
                                            leading: SizedBox(
                                              height: 30,
                                              child: Center(
                                                child: Checkbox(
                                                  semanticLabel: 'isDefault',
                                                  checked: isDefault,
                                                  onChanged: (val) => profile
                                                      .updateDefaultLanguage(
                                                          code.iso6393),
                                                ),
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                  FluentIcons.remove),
                                              onPressed: () =>
                                                  editProfile.updateLanguages(
                                                      code.iso6393, false),
                                            ),
                                            title: SizedBox(
                                              height: 28,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (code.warn) ...[
                                                    Tooltip(
                                                      message:
                                                          l10n.nonIso6392Hint,
                                                      child: const Icon(
                                                          FluentIcons.warning),
                                                    ),
                                                    const SizedBox(width: 6),
                                                  ],
                                                  Flexible(
                                                    child: Text(code.fullName),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expander(
                        header: Text(l10n.selectTrackFlagsAndReorder),
                        content: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(' ${l10n.flags}: '),
                                  Flexible(
                                    child: AutoSuggestBox<String>(
                                      key: const Key('Search Flags'),
                                      trailingIcon:
                                          const Icon(FluentIcons.search),
                                      onSelected: (selected) {
                                        if (selected.value != null) {
                                          profile
                                              .updateFlagOrder(selected.value!);
                                        }
                                      },
                                      items: List.from(
                                        TrackProperties.flagNames.map(
                                          (flag) {
                                            return AutoSuggestBoxItem(
                                              value: flag,
                                              label: flag,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(' ${l10n.selectedFlags}: '),
                              Flexible(
                                child: ReorderableListView.builder(
                                  shrinkWrap: true,
                                  buildDefaultDragHandles: false,
                                  itemCount:
                                      editProfile.defaultFlagOrder.length,
                                  onReorder: (oldIndex, newIndex) => editProfile
                                      .reorderFlagOrder(oldIndex, newIndex),
                                  proxyDecorator: (child, index, animation) =>
                                      _proxyDecorator(child, index, animation),
                                  itemBuilder: (context, index) {
                                    final flag = editProfile.defaultFlagOrder
                                        .elementAt(index);
                                    return ReorderableDragStartListener(
                                      key: ValueKey(flag),
                                      index: index,
                                      child: FluentTheme(
                                        data: theme,
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          onPressed: () {},
                                          trailing: IconButton(
                                            icon:
                                                const Icon(FluentIcons.remove),
                                            onPressed: () => profile
                                                .updateFlagOrder(flag, false),
                                          ),
                                          title: SizedBox(
                                            height: 28,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(flag),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expander(
                        header: Text(l10n.replaceTexts),
                        trailing: FilledButton(
                          onPressed: () => _textModifierDialog(context,
                              UserProfile.defaultModifiers.first, true),
                          child: Text(l10n.add),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List<Card>.from(
                            editProfile.modifiers.map(
                              (e) => Card(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 4.0),
                                borderRadius: BorderRadius.circular(4),
                                child: ListTile(
                                  title: Text(
                                    e.replaceablesPreview,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    l10n.replacementPreview(
                                        e.replacementPreview),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(FluentIcons.edit),
                                        onPressed: () => _textModifierDialog(
                                            context, e, false),
                                      ),
                                      IconButton(
                                        icon: const Icon(FluentIcons.delete),
                                        onPressed: () =>
                                            editProfile.deleteModifier(e.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Checkbox(
                        content: Text(l10n.useFolderNameAsSource),
                        checked: editProfile.useFolderName,
                        onChanged: (value) =>
                            editProfile.update(useFolderName: value),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    if (editProfile == sourceProfile) {
      return true;
    }
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesHint),
        actions: [
          FilledButton(
            child: Text(l10n.save),
            onPressed: () {
              // Close dialog
              Navigator.pop(context, false);

              // Close profile page
              _saveChanges(context);
            },
          ),
          Button(
            child: Text(l10n.discard),
            onPressed: () => Navigator.pop(context, true),
          ),
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _saveChanges(BuildContext context) {
    if (isNew) {
      editProfile.id =
          DateTime.now().millisecondsSinceEpoch + editProfile.hashCode;
      AppData.profiles.add(
        editProfile.id,
        editProfile,
      );
    } else {
      sourceProfile.update(
        defaultLanguage: editProfile.defaultLanguage,
        showTitleFormat: editProfile.showTitleFormat,
        videoTitleFormat: editProfile.videoTitleFormat,
        audioTitleFormat: editProfile.audioTitleFormat,
        subtitleTitleFormat: editProfile.subtitleTitleFormat,
        videoExtraOptions: editProfile.videoExtraOptions,
        audioExtraOptions: editProfile.audioExtraOptions,
        subtitleExtraOptions: editProfile.subtitleExtraOptions,
        attachmentExtraOptions: editProfile.attachmentExtraOptions,
        languages: editProfile.languages,
        defaultFlagOrder: editProfile.defaultFlagOrder,
        name: editProfile.name,
        modifiers: editProfile.modifiers,
        useFolderName: editProfile.useFolderName,
      );
      AppData.profiles.refresh();
    }
    Navigator.pop(context);
  }

  void _updateNameDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => NameDialog(profile: editProfile),
    );
    if (result != null) {
      editProfile.update(name: result);
    }
  }

  void _textModifierDialog(
      BuildContext context, TextModifier modifier, bool isNew) async {
    await showDialog<TextModifier>(
      context: context,
      builder: (context) => TextModifierDialog(
        profile: editProfile,
        sourceModifier: modifier,
        isNew: isNew,
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return mt.Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }
}
