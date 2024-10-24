import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as mt;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/app_data.dart';
import '../../models/models.dart';
import '../../utilities/utilities.dart';

class FolderTitleDialog extends StatelessWidget {
  FolderTitleDialog({super.key, required this.show, this.season});
  final Show show;
  final Season? season;
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(
      text: season == null ? show.title : season!.folderTitle);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600),
      title: Text(l10n.folder),
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          SelectableText.rich(
            TextSpan(
              text: '${l10n.source}:\n',
              children: [
                TextSpan(
                  text: season != null
                      ? show.title
                      : show.directory.name.noBreakHyphen,
                  style: theme.typography.bodyStrong?.copyWith(
                    color: season != null ? null : Colors.blue,
                  ),
                  recognizer: season != null
                      ? null
                      : (TapGestureRecognizer()
                        ..onTap = () async {
                          await show.directory.revealInExplorer();
                        }),
                  children: [
                    if (season != null) ...[
                      const TextSpan(text: '\\'),
                      TextSpan(text: season!.folderTitle),
                    ],
                  ],
                ),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          Text(
            '${l10n.folderTitle}:',
            style: theme.typography.bodyStrong,
          ),
          Form(
            key: _formKey,
            child: TextFormBox(
              controller: _titleCtrl,
              style: theme.typography.body,
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              validator: (value) {
                if (value != null) {
                  if (value.isEmpty) {
                    return l10n.itemNameCantBeEmpty(l10n.folder);
                  }
                  if (!value.isValidFileName) {
                    return l10n.itemNameContainInvalid(l10n.folder);
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(l10n.save),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (season == null) {
                show.title = _titleCtrl.text;
              } else {
                season!.folderTitle = _titleCtrl.text;
              }
              Navigator.pop(context, true);
            }
          },
        ),
      ],
    );
  }
}

class VideoTitleDialog extends StatefulWidget {
  const VideoTitleDialog({
    super.key,
    required this.v,
    required this.show,
  });
  final Video v;
  final Show show;

  @override
  State<VideoTitleDialog> createState() => _VideoTitleDialogState();
}

class _VideoTitleDialogState extends State<VideoTitleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final String? initialTitle = widget.v.title;
  late final fileTitleCtrl = TextEditingController(text: widget.v.fileTitle);
  late final trackTitleCtrl = TextEditingController(text: initialTitle);
  late LanguageCode language = widget.v.language;
  late final initialLanguage = language.cleanName;
  late final languageCtrl = TextEditingController(text: initialLanguage);
  final languageNode = FocusNode();
  late final include = ValueNotifier(widget.v.include);
  late final Map<Flag, ValueNotifier<bool>> flagNotifiers = {
    for (var flag in widget.v.flags.values) flag: ValueNotifier(flag.value)
  };
  late final removeChapters = ValueNotifier(widget.v.removeChapters);
  late final removeAttachments = ValueNotifier(widget.v.removeAttachments);
  late final extraCtrl = TextEditingController(text: widget.v.extraOptions);
  late final sameAsOutput =
      ValueNotifier(fileTitleCtrl.text == trackTitleCtrl.text);

  @override
  void initState() {
    super.initState();
    languageNode.addListener(() {
      if (!languageNode.hasFocus && languageCtrl.text.isEmpty) {
        languageCtrl.text = initialLanguage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.video),
          Tooltip(
            message: l10n.copyCommandHint,
            child: IconButton(
              icon: const Icon(FluentIcons.text_document_settings),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(
                        text: widget.v.command(widget.show).join(' ')))
                    .then((_) {
                  if (context.mounted) {
                    displayInfoBar(context, builder: (context, close) {
                      return InfoBar(
                        title: Text(l10n.copiedHint),
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                        severity: InfoBarSeverity.info,
                      );
                    });
                  }
                });
              },
            ),
          ),
        ],
      ),
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          SelectableText.rich(
            TextSpan(
              text: '${l10n.source}:\n',
              children: [
                TextSpan(
                  text: widget.v.mainFile.name.noBreakHyphen,
                  style:
                      theme.typography.bodyStrong?.copyWith(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await widget.v.mainFile.revealInExplorer();
                    },
                ),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          InfoLabel(
            label: '${l10n.outputFileTitle}:',
            labelStyle: theme.typography.bodyStrong,
            child: Form(
              key: _formKey,
              child: TextFormBox(
                controller: fileTitleCtrl,
                style: theme.typography.body,
                maxLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                onChanged: (value) {
                  if (sameAsOutput.value) {
                    trackTitleCtrl.text = fileTitleCtrl.text;
                  }
                },
                validator: (value) {
                  if (value != null) {
                    if (value.isEmpty) {
                      return l10n.itemNameCantBeEmpty(l10n.file);
                    }
                    if (!value.isValidFileName) {
                      return l10n.itemNameContainInvalid(l10n.file);
                    }
                  }
                  return null;
                },
              ),
            ),
          ),
          InfoLabel(
            label: '${l10n.trackTitle}:',
            labelStyle: theme.typography.bodyStrong,
            child: ValueListenableBuilder<bool>(
                valueListenable: sameAsOutput,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Tooltip(
                        message: l10n.sameAsOutput,
                        child: Checkbox(
                          checked: value,
                          onChanged: (val) {
                            final result = val ?? false;
                            if (result) {
                              trackTitleCtrl.text = fileTitleCtrl.text;
                            }
                            sameAsOutput.value = result;
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: TextBox(
                          enabled: !value,
                          controller: trackTitleCtrl,
                        ),
                      ),
                    ],
                  );
                }),
          ),
          InfoLabel(
            label: '${l10n.language}:',
            labelStyle: theme.typography.bodyStrong,
            child: AutoSuggestBox<LanguageCode>(
              controller: languageCtrl,
              focusNode: languageNode,
              sorter: (text, items) => Utilities.searchSorter(text, items),
              onSelected: (selected) {
                if (selected.value != null) {
                  language = selected.value!;
                }
              },
              items: List.from(
                AppData.languageCodes.items.map(
                  (code) => AutoSuggestBoxItem<LanguageCode>(
                    value: code,
                    label: code.cleanName,
                    child: Text(
                      code.cleanName,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
            ),
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
                        style: theme.typography.bodyStrong?.copyWith(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url =
                                r'https://mkvtoolnix.download/doc/mkvmerge.html';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                    ),
                  ),
                ),
                TextSpan(text: ': ${l10n.extraOptionsHint}'),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          TextBox(controller: extraCtrl),
          const SizedBox(height: 10),
          mt.Material(
            color: Colors.transparent,
            child: Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              spacing: 6,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: include,
                  builder: (context, value, child) {
                    return Tooltip(
                      message: l10n.include_description,
                      child: mt.ChoiceChip(
                        avatar: const Icon(FluentIcons.link),
                        label: Text(l10n.include),
                        selected: value,
                        selectedColor: theme.accentColor,
                        onSelected: (val) {
                          include.value = val;
                        },
                      ),
                    );
                  },
                ),
                for (var flagEntry in flagNotifiers.entries) ...[
                  ValueListenableBuilder<bool>(
                    valueListenable: flagEntry.value,
                    builder: (context, value, child) {
                      return Tooltip(
                        message:
                            l10n.flag_descriptions(flagEntry.key.definedKey),
                        child: mt.ChoiceChip(
                          avatar: Icon(
                            IconData(
                              flagEntry.key.iconData['id'],
                              fontFamily: flagEntry.key.iconData['fontFamily'],
                              fontPackage:
                                  flagEntry.key.iconData['fontPackage'],
                            ),
                          ),
                          label: Text(flagEntry.key.name),
                          selected: value,
                          selectedColor: theme.accentColor,
                          onSelected: (val) {
                            flagEntry.value.value = val;
                            flagEntry.key.value = val;
                          },
                        ),
                      );
                    },
                  ),
                ],
                if (widget.v.embeddedChapters.isNotEmpty ||
                    widget.v.embeddedAttachments.isNotEmpty) ...[
                  Divider(
                    direction: Axis.vertical,
                    size: 15,
                    style: theme.dividerTheme.merge(
                      const DividerThemeData(
                        verticalMargin: EdgeInsets.symmetric(vertical: 3),
                      ),
                    ),
                  ),
                  if (widget.v.embeddedChapters.isNotEmpty)
                    ValueListenableBuilder<bool>(
                      valueListenable: removeChapters,
                      builder: (context, value, child) {
                        return Tooltip(
                          message: l10n.remove_chapters_description,
                          child: mt.ChoiceChip(
                            avatar: const Icon(mt.Icons.label_off_rounded),
                            label: Text(l10n.removeChapters),
                            selected: value,
                            selectedColor: theme.accentColor,
                            onSelected: (val) {
                              removeChapters.value = val;
                            },
                          ),
                        );
                      },
                    ),
                  if (widget.v.embeddedAttachments.isNotEmpty)
                    ValueListenableBuilder<bool>(
                      valueListenable: removeAttachments,
                      builder: (context, value, child) {
                        return Tooltip(
                          message: l10n.remove_attachments_description,
                          child: mt.ChoiceChip(
                            avatar: const Icon(mt.Icons.link_off_rounded),
                            label: Text(l10n.removeAttachments),
                            selected: value,
                            selectedColor: theme.accentColor,
                            onSelected: (val) {
                              removeAttachments.value = val;
                            },
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(l10n.save),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.v.fileTitle = fileTitleCtrl.text;
              widget.v.update(
                title: trackTitleCtrl.text,
                language: language,
                include: include.value,
                extraOptions: extraCtrl.text,
              );
              widget.v.removeChapters = removeChapters.value;
              widget.v.removeAttachments = removeAttachments.value;
              Navigator.pop(context, true);
            }
          },
        ),
      ],
    );
  }
}

class TrackDialog extends StatefulWidget {
  final String trackType;
  final TrackProperties track;

  const TrackDialog({
    super.key,
    required this.trackType,
    required this.track,
  });

  @override
  State<TrackDialog> createState() => _TrackDialogState();
}

class _TrackDialogState extends State<TrackDialog> {
  late final bool embedded = widget.track is EmbeddedTrack;
  late final String? initialTitle = widget.track.title;
  late final titleCtrl = TextEditingController(text: initialTitle);
  late LanguageCode language = widget.track.language;
  late final initialLanguage = language.fullCleanName;
  late final languageCtrl = TextEditingController(text: initialLanguage);
  final languageNode = FocusNode();
  late final include = ValueNotifier(widget.track.include);
  late final Map<Flag, ValueNotifier<bool>> flagNotifiers = {
    for (var flag in widget.track.flags.values) flag: ValueNotifier(flag.value)
  };
  late final extraCtrl = TextEditingController(text: widget.track.extraOptions);

  @override
  void initState() {
    super.initState();
    languageNode.addListener(() {
      if (!languageNode.hasFocus && languageCtrl.text.isEmpty) {
        languageCtrl.text = initialLanguage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600),
      title: Text(widget.trackType),
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Text.rich(
            TextSpan(
              text:
                  '${l10n.source} (${embedded ? l10n.embedded : l10n.file}):\n',
              children: [
                TextSpan(
                  text: embedded
                      ? [
                          (widget.track as EmbeddedTrack).uid,
                          (widget.track as EmbeddedTrack).sourceTitle ?? ''
                        ].join('\n')
                      : (widget.track as AddedTrack).file.name.noBreakHyphen,
                  style: theme.typography.bodyStrong?.copyWith(
                    color: embedded ? null : Colors.blue,
                  ),
                  recognizer: embedded
                      ? null
                      : (TapGestureRecognizer()
                        ..onTap = () async {
                          await (widget.track as AddedTrack)
                              .file
                              .revealInExplorer();
                        }),
                ),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          InfoLabel(
            label: '${l10n.trackTitle}:',
            labelStyle: theme.typography.bodyStrong,
            child: TextBox(controller: titleCtrl),
          ),
          InfoLabel(
            label: '${l10n.language}:',
            labelStyle: theme.typography.bodyStrong,
            child: AutoSuggestBox<LanguageCode>(
              controller: languageCtrl,
              focusNode: languageNode,
              sorter: (text, items) => Utilities.searchSorter(text, items),
              onSelected: (selected) {
                if (selected.value != null) {
                  language = selected.value!;
                }
              },
              items: List.from(
                AppData.languageCodes.items.map(
                  (code) => AutoSuggestBoxItem<LanguageCode>(
                    value: code,
                    label: code.fullCleanName,
                    child: Text(
                      code.fullCleanName,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ),
            ),
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
                        style: theme.typography.bodyStrong?.copyWith(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url =
                                r'https://mkvtoolnix.download/doc/mkvmerge.html';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                    ),
                  ),
                ),
                TextSpan(text: ': ${l10n.extraOptionsHint}'),
              ],
            ),
            style: theme.typography.bodyStrong,
          ),
          TextBox(controller: extraCtrl),
          const SizedBox(height: 10),
          mt.Material(
            color: Colors.transparent,
            child: Wrap(
              direction: Axis.horizontal,
              runSpacing: 6,
              spacing: 6,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: include,
                  builder: (context, value, child) {
                    return Tooltip(
                      message: l10n.include_description,
                      child: mt.ChoiceChip(
                        avatar: Icon(
                            embedded ? FluentIcons.link : FluentIcons.add_link),
                        label: Text(l10n.include),
                        selected: value,
                        selectedColor: theme.accentColor,
                        onSelected: (val) {
                          include.value = val;
                        },
                      ),
                    );
                  },
                ),
                for (var flagEntry in flagNotifiers.entries) ...[
                  ValueListenableBuilder<bool>(
                    valueListenable: flagEntry.value,
                    builder: (context, value, child) {
                      return Tooltip(
                        message:
                            l10n.flag_descriptions(flagEntry.key.definedKey),
                        child: mt.ChoiceChip(
                          avatar: Icon(
                            IconData(
                              flagEntry.key.iconData['id'],
                              fontFamily: flagEntry.key.iconData['fontFamily'],
                              fontPackage:
                                  flagEntry.key.iconData['fontPackage'],
                            ),
                          ),
                          label: Text(flagEntry.key.name),
                          selected: value,
                          selectedColor: theme.accentColor,
                          onSelected: (val) {
                            flagEntry.value.value = val;
                            flagEntry.key.value = val;
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(l10n.save),
          onPressed: () {
            widget.track.update(
              title: titleCtrl.text,
              language: language,
              include: include.value,
              extraOptions: extraCtrl.text,
            );
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}

class ExtraDialog extends StatelessWidget {
  ExtraDialog({
    super.key,
    required this.trackType,
    required this.track,
  });
  final String trackType;
  final TrackProperties track;
  late final bool embedded = track is EmbeddedTrack;
  late final include = ValueNotifier(track.include);
  late final extraCtrl = TextEditingController(text: track.extraOptions);
  late final _mainCtrl = ScrollController(),
      _vertical = ScrollController(),
      _horizontal = ScrollController();

  List<Widget> children(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final isChapter = trackType == l10n.chapter;

    if (isChapter) {
      if (embedded) {
        final info = ((track as EmbeddedTrack).info as MenuInfo);
        return [
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FixedColumnWidth(100),
              2: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  TableCell(
                      child: Text(
                    l10n.timeStamp,
                    style: theme.typography.bodyStrong,
                  )),
                  const TableCell(child: SizedBox.shrink()),
                  TableCell(
                      child: Text(
                    l10n.name,
                    style: theme.typography.bodyStrong,
                  )),
                ],
              ),
              for (var chapter in info.chapters) ...[
                TableRow(
                  children: [
                    TableCell(
                        child: Text(chapter.startsStamp.format(
                      includeDay: false,
                      daySymbol: '',
                      hourSymbol: '',
                      minuteSymbol: '',
                      secondSymbol: '',
                      millisecondSymbol: '',
                      delimiter: ':',
                      dayPad: 2,
                      hourPad: 2,
                      minutePad: 2,
                      secondPad: 2,
                      millisecondPad: 3,
                      ignoreZero: false,
                    ))),
                    const TableCell(child: SizedBox(height: 0)),
                    TableCell(child: Text(chapter.title)),
                  ],
                ),
              ],
            ],
          ),
        ];
      }
      final fileInfo = (track as AddedTrack).file.readAsStringSync();
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
          child: Text(
            fileInfo,
          ),
        ),
      ];
    }
    if (embedded) {
      final info = ((track as EmbeddedTrack).info as AttachmentInfo);
      return [
        Text('${l10n.name}: ${info.name}'),
        Text('${l10n.type}: ${info.type}'),
        Text('${l10n.size}: ${info.size.formatByteSize()}'),
      ];
    }
    final fileInfo = (track as AddedTrack).file;
    return [
      Text('${l10n.name}: ${fileInfo.name}'),
      Text('${l10n.type}: ${fileInfo.extension}'),
      Text('${l10n.size}: ${fileInfo.lengthSync().formatByteSize()}'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final isChapter = trackType == l10n.chapter;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600),
      title: Text(trackType),
      content: Scrollbar(
        controller: _mainCtrl,
        child: ListView(
          controller: _mainCtrl,
          shrinkWrap: true,
          children: [
            Text.rich(
              TextSpan(
                text:
                    '${l10n.source} (${embedded ? l10n.embedded : l10n.file}):\n',
                children: [
                  TextSpan(
                    text: embedded
                        ? (track as EmbeddedTrack).uid
                        : (track as AddedTrack).file.name.noBreakHyphen,
                    style: theme.typography.bodyStrong?.copyWith(
                      color: embedded ? null : Colors.blue,
                    ),
                    recognizer: embedded
                        ? null
                        : (TapGestureRecognizer()
                          ..onTap = () async {
                            await (track as AddedTrack).file.revealInExplorer();
                          }),
                  ),
                ],
              ),
              style: theme.typography.bodyStrong,
            ),
            Expander(
              header: Text(l10n.contentPreview),
              content: Container(
                decoration: isChapter && !embedded
                    ? BoxDecoration(
                        color: theme.micaBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      )
                    : null,
                constraints: const BoxConstraints(maxHeight: 500),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _horizontal,
                  notificationPredicate: (notif) => notif.depth == 1,
                  child: SingleChildScrollView(
                    controller: _vertical,
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      controller: _horizontal,
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: children(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!embedded) ...[
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
                            style: theme.typography.bodyStrong?.copyWith(
                              color: embedded ? null : Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                const url =
                                    r'https://mkvtoolnix.download/doc/mkvmerge.html';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                }
                              },
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ':'),
                  ],
                ),
                style: theme.typography.bodyStrong,
              ),
              TextBox(controller: extraCtrl),
              const SizedBox(height: 10),
              mt.Material(
                color: Colors.transparent,
                child: Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 6,
                  spacing: 6,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: include,
                      builder: (context, value, child) {
                        return Tooltip(
                          message: l10n.include_description,
                          child: mt.ChoiceChip(
                            avatar: Icon(embedded
                                ? FluentIcons.link
                                : FluentIcons.add_link),
                            label: Text(l10n.include),
                            selected: value,
                            selectedColor: theme.accentColor,
                            onSelected: (val) {
                              include.value = val;
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (embedded) ...[
          Button(
            child: Text(l10n.okay),
            onPressed: () => Navigator.pop(context, false),
          ),
        ] else ...[
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: Text(l10n.save),
            onPressed: () {
              track.update(
                include: include.value,
              );
              Navigator.pop(context, true);
            },
          ),
        ],
      ],
    );
  }
}
