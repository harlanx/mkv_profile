import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' as mt;

import 'package:fluent_ui/fluent_ui.dart';

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
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Folder'),
      content: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          SelectableText.rich(
            TextSpan(
              text: 'Source:\n',
              children: [
                TextSpan(
                  text: season != null
                      ? show.title
                      : show.directory.name.noBreakHyphen,
                  style: FluentTheme.of(context).typography.body?.copyWith(
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
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
          Text(
            'Folder Title:',
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
          Form(
            key: _formKey,
            child: TextFormBox(
              controller: _titleCtrl,
              style: FluentTheme.of(context).typography.body,
              maxLines: 1,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
              validator: (value) {
                if (value != null) {
                  if (value.isEmpty) {
                    return 'Folder name cannot be empty';
                  }
                  if (!value.isValidFileName) {
                    return 'Folder name contains invalid characters';
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
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text('Save'),
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
  const VideoTitleDialog({super.key, required this.v});
  final Video v;

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
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Video'),
      content: mt.Material(
        color: Colors.transparent,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            SelectableText.rich(
              TextSpan(
                text: 'Source:\n',
                children: [
                  TextSpan(
                    text: widget.v.mainFile.name.noBreakHyphen,
                    style: FluentTheme.of(context).typography.body?.copyWith(
                          color: Colors.blue,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await widget.v.mainFile.revealInExplorer();
                      },
                  ),
                ],
              ),
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            Text(
              'Output File Title:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            Form(
              key: _formKey,
              child: TextFormBox(
                controller: fileTitleCtrl,
                style: FluentTheme.of(context).typography.body,
                maxLines: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                validator: (value) {
                  if (value != null) {
                    if (value.isEmpty) {
                      return 'File name cannot be empty';
                    }
                    if (!value.isValidFileName) {
                      return 'File name contains invalid characters';
                    }
                  }
                  return null;
                },
              ),
            ),
            Text(
              'Track Title:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            TextBox(controller: trackTitleCtrl),
            Text(
              'Language:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            AutoSuggestBox<LanguageCode>(
              controller: languageCtrl,
              onSelected: (selected) {
                if (selected.value != null) {
                  language = selected.value!;
                }
              },
              focusNode: languageNode,
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
            const SizedBox(height: 10),
            Wrap(
              direction: Axis.horizontal,
              runSpacing: 6,
              spacing: 6,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: include,
                  builder: (context, value, child) {
                    return Tooltip(
                      message:
                          'Enable to include this item in the merging process.',
                      child: mt.ChoiceChip(
                        avatar: const Icon(FluentIcons.link),
                        label: const Text('Include'),
                        selected: value,
                        selectedColor: FluentTheme.of(context).accentColor,
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
                        message: flagEntry.key.descripton,
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
                          selectedColor: FluentTheme.of(context).accentColor,
                          onSelected: (val) {
                            flagEntry.value.value = val;
                            flagEntry.key.value = val;
                          },
                        ),
                      );
                    },
                  ),
                ],
                ValueListenableBuilder<bool>(
                  valueListenable: removeChapters,
                  builder: (context, value, child) {
                    return Tooltip(
                      message:
                          'Enable to remove all of the embedded chapters.\nIt is usually found in mkv files and can be hand generated on a chapter editor or merged using a chapter file.',
                      child: mt.ChoiceChip(
                        avatar: const Icon(mt.Icons.label_off_rounded),
                        label: const Text('Remove Chapters'),
                        selected: value,
                        selectedColor: FluentTheme.of(context).accentColor,
                        onSelected: (val) {
                          removeChapters.value = val;
                        },
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: removeAttachments,
                  builder: (context, value, child) {
                    return Tooltip(
                      message:
                          'Enable to remove all of the embedded attachments.\nIt is usually found in mkv files with custom image poster thumbnail and rarely on ass/ssa subtitles with non-embedded font on itself.',
                      child: mt.ChoiceChip(
                        avatar: const Icon(mt.Icons.link_off_rounded),
                        label: const Text('Remove Attachments'),
                        selected: value,
                        selectedColor: FluentTheme.of(context).accentColor,
                        onSelected: (val) {
                          removeAttachments.value = val;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.v.fileTitle = fileTitleCtrl.text;
              widget.v.update(
                title: trackTitleCtrl.text,
                language: language,
                include: include.value,
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
  late final initialLanguage = language.cleanName;
  late final languageCtrl = TextEditingController(text: initialLanguage);
  final languageNode = FocusNode();
  late final include = ValueNotifier(widget.track.include);
  late final Map<Flag, ValueNotifier<bool>> flagNotifiers = {
    for (var flag in widget.track.flags.values) flag: ValueNotifier(flag.value)
  };

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
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: Text(widget.trackType),
      content: mt.Material(
        color: Colors.transparent,
        child: FluentTheme(
          data: FluentTheme.of(context).copyWith(
            tooltipTheme: TooltipTheme.of(context).merge(
              const TooltipThemeData(
                padding: EdgeInsets.all(8),
                showDuration: Duration.zero,
                waitDuration: Duration.zero,
              ),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Text.rich(
                TextSpan(
                  text: 'Source (${embedded ? 'Embedded' : 'File'}):\n',
                  children: [
                    TextSpan(
                      text: embedded
                          ? (widget.track as EmbeddedTrack).uid
                          : (widget.track as AddedTrack)
                              .file
                              .name
                              .noBreakHyphen,
                      style: FluentTheme.of(context).typography.body?.copyWith(
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
                style: FluentTheme.of(context).typography.bodyStrong,
              ),
              Text(
                'Track Title:',
                style: FluentTheme.of(context).typography.bodyStrong,
              ),
              TextBox(controller: titleCtrl),
              Text(
                'Language:',
                style: FluentTheme.of(context).typography.bodyStrong,
              ),
              AutoSuggestBox<LanguageCode>(
                controller: languageCtrl,
                focusNode: languageNode,
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
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                direction: Axis.horizontal,
                runSpacing: 6,
                spacing: 6,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: include,
                    builder: (context, value, child) {
                      return Tooltip(
                        message:
                            'Enable to include this item in the merging process.',
                        child: mt.ChoiceChip(
                          avatar: const Icon(FluentIcons.link),
                          label: const Text('Include'),
                          selected: value,
                          selectedColor: FluentTheme.of(context).accentColor,
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
                          message: flagEntry.key.descripton,
                          child: mt.ChoiceChip(
                            avatar: Icon(
                              IconData(
                                flagEntry.key.iconData['id'],
                                fontFamily:
                                    flagEntry.key.iconData['fontFamily'],
                                fontPackage:
                                    flagEntry.key.iconData['fontPackage'],
                              ),
                            ),
                            label: Text(flagEntry.key.name),
                            selected: value,
                            selectedColor: FluentTheme.of(context).accentColor,
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
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            widget.track.update(
              title: titleCtrl.text,
              language: language,
              include: include.value,
            );
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
