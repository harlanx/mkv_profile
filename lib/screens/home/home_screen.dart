import 'package:fluent_ui/fluent_ui.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

import '../../data/app_data.dart';
import '../../models/models.dart';
import '../../utilities/utilities.dart';
import 'home_screen_menu.dart';
import 'home_screen_dialogs.dart';

final _selectedID = ValueNotifier<int?>(null);

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final _splitViewCtrl = MultiSplitViewController(areas: [
    Area(size: AppData.appSettings.folderPanelWidth, minimalSize: 300),
    Area(size: AppData.appSettings.infoPanelWidth, minimalSize: 500),
  ]);

  final _isDragging = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: HomeScreenMenuBar(selectedID: _selectedID),
      content: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final showList = context.watch<ShowListNotifier>();
    if (showList.items.isEmpty) {
      return DropTarget(
        enable: showList.items.isEmpty,
        onDragEntered: (detail) => _isDragging.value = true,
        onDragExited: (detail) => _isDragging.value = false,
        onDragDone: (xfile) async {
          await showList.add(xfile.files.map((e) => e.path).toList());
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: _isDragging,
          builder: (context, dragging, _) {
            return Container(
              padding: const EdgeInsets.all(5.0),
              color: dragging
                  ? FluentTheme.of(context)
                      .resources
                      .textFillColorDisabled
                      .withOpacity(0.15)
                  : null,
              child: Center(
                child: Text(
                  AppLocalizations.of(context).dropFoldersHere,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(dividerThickness: 3),
      child: MultiSplitView(
        controller: _splitViewCtrl,
        antiAliasingWorkaround: true,
        axis: Axis.horizontal,
        dividerBuilder: (p0, p1, p2, p3, p4, p5) {
          return Divider(
            direction: Axis.vertical,
            style: DividerThemeData(
              decoration: BoxDecoration(
                color: FluentTheme.of(context).cardColor,
              ),
            ),
          );
        },
        children: [
          InputPanel(
            isDragging: _isDragging,
            selectedID: _selectedID,
          ),
          InfoPanel(selectedID: _selectedID),
        ],
      ),
    );
  }
}

class InputPanel extends StatelessWidget {
  InputPanel({
    Key? key,
    required this.isDragging,
    required this.selectedID,
  }) : super(key: key);

  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> isDragging;
  final ValueNotifier<int?> selectedID;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShowListNotifier>(
      builder: (context, shows, child) {
        return DropTarget(
          onDragEntered: (detail) => isDragging.value = true,
          onDragExited: (detail) => isDragging.value = false,
          onDragDone: (xfile) async {
            await shows.add(xfile.files.map((e) => e.path).toList());
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: isDragging,
            builder: (context, dragging, _) {
              return Container(
                margin: const EdgeInsets.all(5.0),
                decoration: ShapeDecoration(
                  color: dragging
                      ? FluentTheme.of(context)
                          .resources
                          .textFillColorDisabled
                          .withOpacity(0.15)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0)),
                ),
                child: Scrollbar(
                  controller: _controller,
                  thumbVisibility: true,
                  style: const ScrollbarThemeData(
                    thickness: 2.0,
                    hoveringThickness: 5.0,
                    radius: Radius.zero,
                    hoveringRadius: Radius.circular(5.0),
                    mainAxisMargin: 0.0,
                    hoveringMainAxisMargin: 0.0,
                    crossAxisMargin: 5.0,
                    hoveringCrossAxisMargin: 3.5,
                    minThumbLength: 200.0,
                  ),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: shows.items.length,
                      itemBuilder: (_, index) => InputTile(
                        selectedID: selectedID,
                        ctx: context,
                        sln: shows,
                        id: shows.items.entries.elementAt(index).key,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class InputTile extends StatefulWidget {
  const InputTile({
    super.key,
    required this.selectedID,
    required this.ctx,
    required this.sln,
    required this.id,
  });

  final ValueNotifier<int?> selectedID;
  final BuildContext ctx;
  final ShowListNotifier sln;
  final int id;

  @override
  State<InputTile> createState() => _InputTileState();
}

class _InputTileState extends State<InputTile> {
  late final ShowNotifier sn = widget.sln.items[widget.id]!;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: FutureBuilder<void>(
        future: sn.loadInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Loading Animation
            return const InputTileShimmer();
          }

          return ValueListenableBuilder<int?>(
            valueListenable: widget.selectedID,
            builder: (context, value, _) {
              return ListTile.selectable(
                selected: widget.selectedID.value == widget.id,
                selectionMode: ListTileSelectionMode.single,
                leading: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(sn.show is Movie
                      ? '(${AppLocalizations.of(context).movie})'
                      : '(${AppLocalizations.of(context).series})'),
                ),
                title: Text(
                  sn.show.directory.name,
                  softWrap: false,
                  style: const TextStyle(overflow: TextOverflow.fade),
                ),
                subtitle: Text(
                  sn.show.directory.path,
                  softWrap: false,
                  style: const TextStyle(overflow: TextOverflow.fade),
                ),
                onPressed: () {
                  if (widget.selectedID.value == null ||
                      widget.selectedID.value != widget.id) {
                    widget.selectedID.value = widget.id;
                  } else {
                    widget.selectedID.value = null;
                  }
                },
                trailing: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Tooltip(
                    message: AppLocalizations.of(context).remove,
                    child: IconButton(
                      icon: const Icon(FluentIcons.remove),
                      onPressed: () {
                        widget.sln.remove(widget.id);
                        widget.selectedID.value = null;
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({
    Key? key,
    required this.selectedID,
  }) : super(key: key);

  final ValueNotifier<int?> selectedID;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedID,
      builder: (context, id, child) {
        if (id == null) {
          return Center(
            child: Text(
              AppLocalizations.of(context).selectFromList,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return ChangeNotifierProvider.value(
          value: context.watch<ShowListNotifier>().items[id]!,
          builder: (context, child) {
            return const MainNode();
          },
        );
      },
    );
  }
}

class MainNode extends StatefulWidget {
  const MainNode({super.key});

  @override
  State<MainNode> createState() => _MainNodeState();
}

class _MainNodeState extends State<MainNode> {
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _folderTitleDialog(
    BuildContext context,
    ShowNotifier notifier, [
    Season? season,
  ]) async {
    await showDialog<bool>(
      context: context,
      builder: (context) =>
          FolderTitleDialog(show: notifier.show, season: season),
    ).then((updated) {
      updated ??= false;
      if (updated) {
        notifier.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final isMovie = notifier.show is Movie;
    final theme = FluentTheme.of(context);

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Folder
        GestureDetector(
          onSecondaryTapUp: (details) async {
            final targetContext = menuAttachKey.currentContext;
            if (targetContext == null) return;

            final box = targetContext.findRenderObject() as RenderBox;
            final position = box.localToGlobal(
              details.localPosition,
              ancestor: Navigator.of(context).context.findRenderObject(),
            );

            await menuController.showFlyout(
              position: position,
              barrierDismissible: true,
              barrierColor: theme.resources.subtleFillColorTransparent,
              dismissWithEsc: true,
              transitionDuration: Duration.zero,
              builder: (context) {
                return MenuFlyout(
                  items: [
                    MenuFlyoutItem(
                      leading: const Icon(FluentIcons.edit),
                      text: Text(AppLocalizations.of(context).edit),
                      onPressed: () async {
                        Flyout.of(context).close();
                        await _folderTitleDialog(context, notifier);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: FlyoutTarget(
            controller: menuController,
            key: menuAttachKey,
            child: HyperlinkButton(
              onPressed: () async =>
                  await _folderTitleDialog(context, notifier),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.folder, size: 14),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                          text: notifier.show.title,
                          style: FluentTheme.of(context).typography.body),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Nodes
        if (isMovie) ...[
          VideoNode(padding: 0, video: (notifier.show as Movie).video)
        ] else ...[
          for (final season in (notifier.show as Series).seasons)
            SeasonNode(show: notifier.show, season: season)
        ],
      ],
    );
  }
}

class SeasonNode extends StatefulWidget {
  const SeasonNode({
    super.key,
    required this.show,
    required this.season,
  });
  final Show show;
  final Season season;

  @override
  State<SeasonNode> createState() => _SeasonNodeState();
}

class _SeasonNodeState extends State<SeasonNode> {
  late final expandKey =
      '${widget.show.directory.name}${'Season ${widget.season.number.toString().padLeft(2, '0')}'}';
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _folderTitleDialog(
    BuildContext context,
    ShowNotifier notifier, [
    Season? season,
  ]) async {
    await showDialog<bool>(
      context: context,
      builder: (context) =>
          FolderTitleDialog(show: notifier.show, season: season),
    ).then((updated) {
      updated ??= false;
      if (updated) {
        notifier.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final expand = notifier.expandedNodes.any((value) => value == expandKey);
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.edit),
                  text: Text(AppLocalizations.of(context).edit),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _folderTitleDialog(context, notifier);
                  },
                ),
              ],
            );
          },
        );
      },
      child: CustomExpander(
        initiallyExpanded: expand,
        animationDuration: Duration.zero,
        headerHeight: 30,
        levelPadding: 0.0,
        onStateChanged: (value) {
          if (value) {
            notifier.expandedNodes.add(expandKey);
          } else {
            notifier.expandedNodes.remove(expandKey);
          }
        },
        header: FlyoutTarget(
          controller: menuController,
          key: menuAttachKey,
          child: CustomHyperlinkButton(
            onPressed: () async =>
                await _folderTitleDialog(context, notifier, widget.season),
            child: Row(
              children: [
                const Icon(FluentIcons.folder),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                      text: widget.season.folderTitle,
                      style: FluentTheme.of(context).typography.body),
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final video in widget.season.videos)
              VideoNode(padding: 16, video: video),
          ],
        ),
      ),
    );
  }
}

// Video Node
class VideoNode extends StatefulWidget {
  const VideoNode({
    super.key,
    required this.padding,
    required this.video,
  });

  final double padding;
  final Video video;

  @override
  State<VideoNode> createState() => _VideoNodeState();
}

class _VideoNodeState extends State<VideoNode> {
  late final videoPadding = widget.padding;
  late final trackPadding = videoPadding + 16;
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();
  final _isDragging = ValueNotifier<bool>(false);

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _videoTitleDialog(
    BuildContext context,
    ShowNotifier notifier,
    Video video,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => VideoTitleDialog(v: video, show: notifier.show),
    ).then((updated) {
      updated ??= false;
      if (updated) {
        for (final chapter in video.embeddedChapters) {
          chapter.include = !video.removeChapters;
        }
        for (final attachment in video.embeddedAttachments) {
          attachment.include = !video.removeAttachments;
        }
        notifier.refresh();
      }
    });
  }

  Future<void> _addFiles(
      ShowNotifier notifier, Video video, List<String> paths) async {
    await video.addAudios(paths);
    await video.addSubtitles(paths);
    await video.addChapters(paths);
    await video.addAttachments(paths);

    for (final audio in video.addedAudios) {
      await audio.loadInfo();
    }
    for (final subtitle in video.addedSubtitles) {
      await subtitle.loadInfo();
    }
    notifier.refresh();
  }

  Future<void> _selectAudios(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: AppData.audioFormats),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addAudios(paths);
    for (final audio in video.addedAudios) {
      await audio.loadInfo();
    }
    notifier.refresh();
  }

  Future<void> _selectSubtitles(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: AppData.subtitleFormats),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addSubtitles(paths);
    for (final subtitle in video.addedSubtitles) {
      await subtitle.loadInfo();
    }
    notifier.refresh();
  }

  Future<void> _selectChapters(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: AppData.chapterFormats),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addChapters(paths);
    notifier.refresh();
  }

  Future<void> _selectAttachments(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(
            extensions: [...AppData.fontFormats, ...AppData.imageFormats]),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addAttachments(paths);
    notifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final expand = notifier.expandedNodes
        .any((value) => value == widget.video.mainFile.path);
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                if (widget.video.audios.isEmpty)
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.volume3),
                    text: Text(AppLocalizations.of(context).addAudios),
                    onPressed: () async {
                      Flyout.of(context).close();
                      await _selectAudios(notifier, widget.video);
                    },
                  ),
                if (widget.video.subtitles.isEmpty)
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.cc),
                    text: Text(AppLocalizations.of(context).addSubtitles),
                    onPressed: () async {
                      Flyout.of(context).close();
                      await _selectSubtitles(notifier, widget.video);
                    },
                  ),
                if (widget.video.chapters.isEmpty)
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.double_bookmark),
                    text: Text(AppLocalizations.of(context).addChapters),
                    onPressed: () async {
                      Flyout.of(context).close();
                      await _selectChapters(notifier, widget.video);
                    },
                  ),
                if (widget.video.attachments.isEmpty)
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.attach),
                    text: Text(AppLocalizations.of(context).addAttachments),
                    onPressed: () async {
                      Flyout.of(context).close();
                      await _selectAttachments(notifier, widget.video);
                    },
                  ),
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.edit),
                  text: Text(AppLocalizations.of(context).edit),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _videoTitleDialog(context, notifier, widget.video);
                  },
                ),
                MenuFlyoutSubItem(
                  leading: const Icon(FluentIcons.toggle_right),
                  text: const Text('Flags'),
                  items: (context) {
                    return [
                      for (final flagEntry in widget.video.flags.entries)
                        MenuFlyoutItem(
                          leading: Icon(
                            IconData(
                              flagEntry.value.iconData['id'],
                              fontFamily:
                                  flagEntry.value.iconData['fontFamily'],
                              fontPackage:
                                  flagEntry.value.iconData['fontPackage'],
                            ),
                            color: flagEntry.value.value
                                ? theme.accentColor
                                    .defaultBrushFor(theme.brightness)
                                : FluentTheme.of(context).inactiveColor,
                          ),
                          text: Text(flagEntry.value.name),
                          onPressed: () {
                            Flyout.maybeOf(Flyout.of(context)
                                    .rootFlyout
                                    .currentContext!)
                                ?.close();
                            flagEntry.value.value = !flagEntry.value.value;
                            notifier.refresh();
                          },
                        ),
                    ];
                  },
                ),
              ],
            );
          },
        );
      },
      child: DropTarget(
        onDragEntered: (detail) => _isDragging.value = true,
        onDragExited: (detail) => _isDragging.value = false,
        onDragDone: (xfile) async {
          final paths = xfile.files.map((e) => e.path).toList();
          await _addFiles(notifier, widget.video, paths);
        },
        child: ValueListenableBuilder(
          valueListenable: _isDragging,
          builder: (context, dragging, child) {
            return Container(
              decoration: ShapeDecoration(
                color: dragging
                    ? FluentTheme.of(context)
                        .resources
                        .textFillColorDisabled
                        .withOpacity(0.15)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0)),
              ),
              child: CustomExpander(
                initiallyExpanded: expand,
                animationDuration: Duration.zero,
                headerHeight: 30,
                levelPadding: videoPadding,
                onStateChanged: (value) {
                  if (value) {
                    notifier.expandedNodes.add(widget.video.mainFile.path);
                  } else {
                    notifier.expandedNodes.remove(widget.video.mainFile.path);
                  }
                },
                header: FlyoutTarget(
                  controller: menuController,
                  key: menuAttachKey,
                  child: CustomHyperlinkButton(
                    onPressed: () async => await _videoTitleDialog(
                        context, notifier, widget.video),
                    child: Row(
                      children: [
                        const Icon(FluentIcons.my_movies_t_v),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                                text:
                                    '${widget.video.fileTitle}.${widget.video.mainFile.extension}',
                                style: FluentTheme.of(context).typography.body),
                            textAlign: TextAlign.start,
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Audio Nodes
                    if (widget.video.audios.isNotEmpty)
                      AudioNodes(
                        trackPadding: trackPadding,
                        video: widget.video,
                      ),
                    // Subtitle Nodes
                    if (widget.video.subtitles.isNotEmpty)
                      SubtitleNodes(
                        trackPadding: trackPadding,
                        video: widget.video,
                      ),
                    if (widget.video.chapters.isNotEmpty)
                      // Chapter Nodes
                      ChapterNodes(
                        trackPadding: trackPadding,
                        video: widget.video,
                      ),
                    if (widget.video.attachments.isNotEmpty)
                      // Attachment Nodes
                      AttachmentNodes(
                        trackPadding: trackPadding,
                        video: widget.video,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AudioNodes extends StatefulWidget {
  const AudioNodes({
    super.key,
    required this.trackPadding,
    required this.video,
  });
  final double trackPadding;
  final Video video;

  @override
  State<AudioNodes> createState() => _AudioNodesState();
}

class _AudioNodesState extends State<AudioNodes> {
  late final expandKey = '${widget.video.mainFile.path}Audios';
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _selectAudios(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: AppData.audioFormats),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addAudios(paths);
    for (final audio in video.addedAudios) {
      await audio.loadInfo();
    }
    notifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final expand = notifier.expandedNodes.any((value) => value == expandKey);
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.volume3),
                  text: Text(AppLocalizations.of(context).addAudios),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _selectAudios(notifier, widget.video);
                  },
                ),
                if (widget.video.addedAudios.isNotEmpty) ...[
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.delete),
                    text: Text(AppLocalizations.of(context).removeAll),
                    onPressed: () {
                      Flyout.of(context).close();
                      widget.video.addedAudios.clear();
                      notifier.refresh();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
      child: CustomExpander(
        initiallyExpanded: expand,
        animationDuration: Duration.zero,
        headerHeight: 30,
        levelPadding: widget.trackPadding,
        onStateChanged: (value) {
          if (value) {
            notifier.expandedNodes.add(expandKey);
          } else {
            notifier.expandedNodes.remove(expandKey);
          }
        },
        header: FlyoutTarget(
          controller: menuController,
          key: menuAttachKey,
          child: Row(
            children: [
              Icon(
                FluentIcons.volume3,
                color: theme.accentColor.defaultBrushFor(theme.brightness),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                    text: AppLocalizations.of(context).audios,
                    style: FluentTheme.of(context).typography.body),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final audio in widget.video.audios)
              TrackNode(
                trackPadding: widget.trackPadding,
                video: widget.video,
                type: AppLocalizations.of(context).audio,
                track: audio,
              ),
          ],
        ),
      ),
    );
  }
}

class SubtitleNodes extends StatefulWidget {
  const SubtitleNodes({
    super.key,
    required this.trackPadding,
    required this.video,
  });
  final double trackPadding;
  final Video video;

  @override
  State<SubtitleNodes> createState() => _SubtitleNodesState();
}

class _SubtitleNodesState extends State<SubtitleNodes> {
  late final expandKey = '${widget.video.mainFile.path}Subtitles';
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _selectSubtitles(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: AppData.subtitleFormats),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addSubtitles(paths);
    for (final subtitle in video.addedSubtitles) {
      await subtitle.loadInfo();
    }
    notifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final expand = notifier.expandedNodes.any((value) => value == expandKey);
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.cc),
                  text: Text(AppLocalizations.of(context).addSubtitles),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _selectSubtitles(notifier, widget.video);
                  },
                ),
                if (widget.video.addedSubtitles.isNotEmpty) ...[
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.delete),
                    text: Text(AppLocalizations.of(context).removeAll),
                    onPressed: () {
                      Flyout.of(context).close();
                      widget.video.addedSubtitles.clear();
                      notifier.refresh();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
      child: CustomExpander(
        initiallyExpanded: expand,
        animationDuration: Duration.zero,
        headerHeight: 30,
        levelPadding: widget.trackPadding,
        onStateChanged: (value) {
          if (value) {
            notifier.expandedNodes.add(expandKey);
          } else {
            notifier.expandedNodes.remove(expandKey);
          }
        },
        header: FlyoutTarget(
          controller: menuController,
          key: menuAttachKey,
          child: Row(
            children: [
              Icon(
                FluentIcons.cc,
                color: theme.accentColor.defaultBrushFor(theme.brightness),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                    text: AppLocalizations.of(context).subtitles,
                    style: FluentTheme.of(context).typography.body),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final subtitle in widget.video.subtitles)
              TrackNode(
                trackPadding: widget.trackPadding,
                video: widget.video,
                type: AppLocalizations.of(context).subtitle,
                track: subtitle,
              ),
          ],
        ),
      ),
    );
  }
}

class ChapterNodes extends StatefulWidget {
  const ChapterNodes({
    super.key,
    required this.trackPadding,
    required this.video,
  });
  final double trackPadding;
  final Video video;

  @override
  State<ChapterNodes> createState() => _ChapterNodesState();
}

class _ChapterNodesState extends State<ChapterNodes> {
  late final expandKey = '${widget.video.mainFile.path}Chapters';
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _selectChapters(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: AppData.chapterFormats),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addChapters(paths);
    notifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final expand = notifier.expandedNodes.any((value) => value == expandKey);
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.double_bookmark),
                  text: Text(AppLocalizations.of(context).addChapters),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _selectChapters(notifier, widget.video);
                  },
                ),
                if (widget.video.addedChapters.isNotEmpty) ...[
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.delete),
                    text: Text(AppLocalizations.of(context).removeAll),
                    onPressed: () {
                      Flyout.of(context).close();
                      widget.video.addedChapters.clear();
                      notifier.refresh();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
      child: CustomExpander(
        initiallyExpanded: expand,
        animationDuration: Duration.zero,
        headerHeight: 30,
        levelPadding: widget.trackPadding,
        onStateChanged: (value) {
          if (value) {
            notifier.expandedNodes.add(expandKey);
          } else {
            notifier.expandedNodes.remove(expandKey);
          }
        },
        header: FlyoutTarget(
          controller: menuController,
          key: menuAttachKey,
          child: Row(
            children: [
              Icon(
                FluentIcons.double_bookmark,
                color: theme.accentColor.defaultBrushFor(theme.brightness),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                    text: AppLocalizations.of(context).chapters,
                    style: FluentTheme.of(context).typography.body),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final chapter in widget.video.chapters)
              ExtraNode(
                trackPadding: widget.trackPadding,
                video: widget.video,
                type: AppLocalizations.of(context).chapter,
                extra: chapter,
              ),
          ],
        ),
      ),
    );
  }
}

class AttachmentNodes extends StatefulWidget {
  const AttachmentNodes({
    super.key,
    required this.trackPadding,
    required this.video,
  });
  final double trackPadding;
  final Video video;

  @override
  State<AttachmentNodes> createState() => _AttachmentNodesState();
}

class _AttachmentNodesState extends State<AttachmentNodes> {
  late final expandKey = '${widget.video.mainFile.path}Attachments';
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _selectAttachments(ShowNotifier notifier, Video video) async {
    final xFiles = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(
            extensions: [...AppData.fontFormats, ...AppData.imageFormats]),
      ],
    );

    if (xFiles.isEmpty) return;

    final paths = xFiles.map((e) => e.path).toList();

    await video.addAttachments(paths);
    notifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final expand = notifier.expandedNodes.any((value) => value == expandKey);
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.double_bookmark),
                  text: Text(AppLocalizations.of(context).addAttachments),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _selectAttachments(notifier, widget.video);
                  },
                ),
                if (widget.video.addedAttachments.isNotEmpty) ...[
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.attach),
                    text: Text(AppLocalizations.of(context).removeAll),
                    onPressed: () {
                      Flyout.of(context).close();
                      widget.video.addedAttachments.clear();
                      notifier.refresh();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
      child: CustomExpander(
        initiallyExpanded: expand,
        animationDuration: Duration.zero,
        headerHeight: 30,
        levelPadding: widget.trackPadding,
        onStateChanged: (value) {
          if (value) {
            notifier.expandedNodes.add(expandKey);
          } else {
            notifier.expandedNodes.remove(expandKey);
          }
        },
        header: FlyoutTarget(
          controller: menuController,
          key: menuAttachKey,
          child: Row(
            children: [
              Icon(
                FluentIcons.attach,
                color: theme.accentColor.defaultBrushFor(theme.brightness),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                    text: AppLocalizations.of(context).attachments,
                    style: FluentTheme.of(context).typography.body),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final attachment in widget.video.attachments)
              ExtraNode(
                trackPadding: widget.trackPadding,
                video: widget.video,
                type: AppLocalizations.of(context).attachment,
                extra: attachment,
              ),
          ],
        ),
      ),
    );
  }
}

// For Audios and Subtitles
class TrackNode extends StatefulWidget {
  const TrackNode({
    super.key,
    required this.trackPadding,
    required this.video,
    required this.type,
    required this.track,
  });

  final double trackPadding;
  final Video video;
  final String type;
  final TrackProperties track;

  @override
  State<TrackNode> createState() => _TrackNodeState();
}

class _TrackNodeState extends State<TrackNode> {
  late final itemPadding = widget.trackPadding + 32;
  late final embedded = widget.track is EmbeddedTrack;
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _trackDialog(
    BuildContext context,
    ShowNotifier notifier,
    String type,
    TrackProperties track,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => TrackDialog(trackType: type, track: track),
    ).then((updated) {
      updated ??= false;
      if (updated) {
        notifier.sortTracks();
        notifier.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: Icon(
                    embedded ? FluentIcons.link : FluentIcons.add_link,
                    color: widget.track.include
                        ? theme.accentColor.defaultBrushFor(theme.brightness)
                        : FluentTheme.of(context).inactiveColor,
                  ),
                  text: Text(AppLocalizations.of(context).include),
                  onPressed: () {
                    Flyout.of(context).close();
                    widget.track.update(include: !widget.track.include);
                    notifier.refresh();
                  },
                ),
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.edit),
                  text: Text(AppLocalizations.of(context).edit),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _trackDialog(
                        context, notifier, widget.type, widget.track);
                  },
                ),
                MenuFlyoutSubItem(
                  leading: const Icon(FluentIcons.toggle_right),
                  text: const Text('Flags'),
                  items: (context) {
                    return [
                      for (final flagEntry in widget.track.flags.entries)
                        MenuFlyoutItem(
                          leading: Icon(
                            IconData(
                              flagEntry.value.iconData['id'],
                              fontFamily:
                                  flagEntry.value.iconData['fontFamily'],
                              fontPackage:
                                  flagEntry.value.iconData['fontPackage'],
                            ),
                            color: flagEntry.value.value
                                ? theme.accentColor
                                    .defaultBrushFor(theme.brightness)
                                : FluentTheme.of(context).inactiveColor,
                          ),
                          text: Text(flagEntry.value.name),
                          onPressed: () {
                            Flyout.maybeOf(Flyout.of(context)
                                    .rootFlyout
                                    .currentContext!)
                                ?.close();
                            flagEntry.value.value = !flagEntry.value.value;
                            notifier.refresh();
                          },
                        ),
                    ];
                  },
                ),
                if (!embedded) ...[
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.delete),
                    text: Text(AppLocalizations.of(context).remove),
                    onPressed: () {
                      Flyout.of(context).close();
                      if (widget.type == AppLocalizations.of(context).audio) {
                        widget.video.removeAudio(
                            (widget.track as AddedTrack).file.path);
                      }
                      if (widget.type ==
                          AppLocalizations.of(context).subtitle) {
                        widget.video.removeSubtitle(
                            (widget.track as AddedTrack).file.path);
                      }
                      notifier.refresh();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
      child: FlyoutTarget(
        controller: menuController,
        key: menuAttachKey,
        child: SizedBox(
          height: 30,
          child: CustomHyperlinkButton(
            onPressed: () async => await _trackDialog(
                context, notifier, widget.type, widget.track),
            style: theme.buttonTheme.hyperlinkButtonStyle?.copyWith(
              backgroundColor: !embedded
                  ? ButtonState.resolveWith(
                      (states) {
                        return ButtonThemeData.uncheckedInputColor(
                          theme,
                          (states.isPressing || states.isNone)
                              ? {ButtonStates.hovering}
                              : states.isHovering
                                  ? {ButtonStates.pressing}
                                  : states,
                          transparentWhenNone: true,
                        );
                      },
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: itemPadding),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    embedded ? FluentIcons.link : FluentIcons.add_link,
                    color: widget.track.include
                        ? theme.accentColor.defaultBrushFor(theme.brightness)
                        : FluentTheme.of(context).inactiveColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(1, 0, 1, 2),
                    alignment: Alignment.center,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: theme.accentColor
                              .defaultBrushFor(theme.brightness)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.track.language.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                          text: embedded
                              ? (widget.track as EmbeddedTrack).uid
                              : (widget.track as AddedTrack).file.name,
                          style: FluentTheme.of(context).typography.caption),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// For Chapters and Attachments
class ExtraNode extends StatefulWidget {
  const ExtraNode({
    super.key,
    required this.trackPadding,
    required this.video,
    required this.type,
    required this.extra,
  });
  final double trackPadding;
  final Video video;
  final String type;
  final TrackProperties extra;
  @override
  State<ExtraNode> createState() => _ExtraNodeState();
}

class _ExtraNodeState extends State<ExtraNode> {
  late final itemPadding = widget.trackPadding + 32;
  late final bool embedded = widget.extra is EmbeddedTrack;
  final menuController = FlyoutController();
  final menuAttachKey = GlobalKey();

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Future<void> _extraDialog(
    BuildContext context,
    ShowNotifier notifier,
    String type,
    TrackProperties extra,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => ExtraDialog(trackType: type, track: extra),
    ).then((updated) {
      updated ??= false;
      if (updated) {
        notifier.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ShowNotifier>();
    final bool isChapter = widget.type == AppLocalizations.of(context).chapter;
    final theme = FluentTheme.of(context);

    String displayName = '';
    if (isChapter && embedded) {
      final embedChap = widget.extra as EmbeddedTrack;
      displayName =
          '${embedChap.uid} (${AppLocalizations.of(context).entries}: ${(embedChap.info as MenuInfo).chapters.length})';
    } else if (!isChapter && embedded) {
      final embedAttach = widget.extra as EmbeddedTrack;
      displayName =
          '${embedAttach.uid} (${(embedAttach.info as AttachmentInfo).name})';
    } else {
      final addExtra = widget.extra as AddedTrack;
      displayName = addExtra.file.name;
    }

    return GestureDetector(
      onSecondaryTapUp: (details) async {
        final targetContext = menuAttachKey.currentContext;
        if (targetContext == null) return;

        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          details.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        await menuController.showFlyout(
          position: position,
          barrierDismissible: true,
          barrierColor: theme.resources.subtleFillColorTransparent,
          dismissWithEsc: true,
          transitionDuration: Duration.zero,
          builder: (context) {
            return MenuFlyout(
              items: [
                MenuFlyoutItem(
                  leading: Icon(
                    embedded ? FluentIcons.link : FluentIcons.add_link,
                    color: widget.extra.include
                        ? theme.accentColor.defaultBrushFor(theme.brightness)
                        : FluentTheme.of(context).inactiveColor,
                  ),
                  text: Text(AppLocalizations.of(context).include),
                  onPressed: () {
                    Flyout.of(context).close();
                    widget.extra.update(include: !widget.extra.include);
                    notifier.refresh();
                  },
                ),
                MenuFlyoutItem(
                  leading: const Icon(FluentIcons.edit),
                  text: Text(AppLocalizations.of(context).edit),
                  onPressed: () async {
                    Flyout.of(context).close();
                    await _extraDialog(
                        context, notifier, widget.type, widget.extra);
                  },
                ),
                if (!embedded) ...[
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    leading: const Icon(FluentIcons.delete),
                    text: Text(AppLocalizations.of(context).remove),
                    onPressed: () {
                      Flyout.of(context).close();
                      if (widget.type == AppLocalizations.of(context).chapter) {
                        widget.video.removeChapter(
                            (widget.extra as AddedTrack).file.path);
                      }
                      if (widget.type ==
                          AppLocalizations.of(context).attachment) {
                        widget.video.removeAttachment(
                            (widget.extra as AddedTrack).file.path);
                      }
                      notifier.refresh();
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
      child: FlyoutTarget(
        controller: menuController,
        key: menuAttachKey,
        child: SizedBox(
          height: 30,
          child: CustomHyperlinkButton(
            onPressed: () async => await _extraDialog(
                context, notifier, widget.type, widget.extra),
            style: theme.buttonTheme.hyperlinkButtonStyle?.copyWith(
              backgroundColor: !embedded
                  ? ButtonState.resolveWith(
                      (states) {
                        return ButtonThemeData.uncheckedInputColor(
                          theme,
                          (states.isPressing || states.isNone)
                              ? {ButtonStates.hovering}
                              : states.isHovering
                                  ? {ButtonStates.pressing}
                                  : states,
                          transparentWhenNone: true,
                        );
                      },
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: itemPadding),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    embedded ? FluentIcons.link : FluentIcons.add_link,
                    color: widget.extra.include
                        ? theme.accentColor.defaultBrushFor(theme.brightness)
                        : FluentTheme.of(context).inactiveColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                          text: displayName,
                          style: FluentTheme.of(context).typography.caption),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
