import 'package:fluent_ui/fluent_ui.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
                padding: const EdgeInsets.all(5.0),
                color: dragging
                    ? FluentTheme.of(context)
                        .resources
                        .textFillColorDisabled
                        .withOpacity(0.15)
                    : null,
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
  late final future = sn.loadInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: FutureBuilder<void>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Loading Animations
            return Shimmer.fromColors(
              baseColor:
                  FluentTheme.of(context).resources.textFillColorDisabled,
              highlightColor: FluentTheme.of(context).activeColor,
              child: ListTile(
                leading: SizedBox(
                  height: 40,
                  child: Center(
                    child: Container(
                      height: 16,
                      width: 35,
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context)
                            .resources
                            .textFillColorDisabled,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                title: Container(
                  margin: const EdgeInsetsDirectional.symmetric(vertical: 2),
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color:
                        FluentTheme.of(context).resources.textFillColorDisabled,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                subtitle: Container(
                  margin: const EdgeInsetsDirectional.symmetric(vertical: 2),
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color:
                        FluentTheme.of(context).resources.textFillColorDisabled,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                trailing: SizedBox(
                  height: 40,
                  child: Center(
                    child: Container(
                      height: 8,
                      width: 25,
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context)
                            .resources
                            .textFillColorDisabled,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            );
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
  InfoPanel({
    Key? key,
    required this.selectedID,
  }) : super(key: key);

  final ScrollController _controller = ScrollController();
  final ValueNotifier<int?> selectedID;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedID,
      builder: (context, id, _) {
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
        return ChangeNotifierProvider<ShowNotifier>.value(
          value: context.watch<ShowListNotifier>().items[id]!,
          child: Consumer<ShowNotifier>(
            builder: (context, sn, _) {
              return TreeView(
                shrinkWrap: true,
                addRepaintBoundaries: false,
                scrollController: _controller,
                narrowSpacing: true,
                onItemInvoked: (item, reason) async {
                  if (reason == TreeViewItemInvokeReason.expandToggle) {
                    if (!item.expanded) {
                      sn.addToExpanded(item.value);
                    } else {
                      sn.removeFromExpanded(item.value);
                    }
                  }
                },
                items: [
                  TreeViewItem(
                    value: sn.show.directory.path,
                    collapsable: false,
                    leading: const Icon(FluentIcons.folder),
                    onInvoked: (item, reason) async {
                      if (reason == TreeViewItemInvokeReason.pressed) {
                        return await _folderTitleDialog(context, sn);
                      }
                    },
                    content: Text.rich(
                      TextSpan(
                          text: sn.show.title,
                          style: FluentTheme.of(context).typography.body),
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    children: _treeViewNodes(context, sn),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _folderTitleDialog(
    BuildContext context,
    ShowNotifier sn, [
    Season? s,
  ]) async {
    bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => FolderTitleDialog(show: sn.show, season: s),
    );
    updated ??= false;
    if (updated) {
      sn.refresh();
    }
  }

  Future<void> _videoTitleDialog(
    BuildContext ctx,
    ShowNotifier sn,
    Video v,
  ) async {
    bool? updated = await showDialog(
      context: ctx,
      builder: (context) => VideoTitleDialog(v: v, show: sn.show),
    );
    updated ??= false;
    if (updated) {
      for (var chapter in v.embeddedChapters) {
        chapter.include = !v.removeChapters;
      }
      for (var attachment in v.embeddedAttachments) {
        attachment.include = !v.removeAttachments;
      }
      sn.refresh();
    }
  }

  Future<void> _trackDialog(
    BuildContext ctx,
    String type,
    ShowNotifier sn,
    TrackProperties track,
  ) async {
    bool? updated = await showDialog<bool>(
      context: ctx,
      builder: (context) => TrackDialog(trackType: type, track: track),
    );
    updated ??= false;
    if (updated) {
      sn.sortTracks();
      sn.refresh();
    }
  }

  Future<void> _extraDialog(
    BuildContext ctx,
    String type,
    ShowNotifier sn,
    TrackProperties extra,
  ) async {
    bool? updated = await showDialog<bool>(
      context: ctx,
      builder: (context) => ExtraDialog(trackType: type, track: extra),
    );
    updated ??= false;
    if (updated) {
      sn.refresh();
    }
  }

  List<TreeViewItem> _treeViewNodes(BuildContext context, ShowNotifier sn) {
    if (sn.show is Movie) {
      final movie = sn.show as Movie;
      return [_videoTree(context, movie.video, sn)];
    } else {
      final series = sn.show as Series;
      return List.from(
        series.seasons.map(
          (s) {
            final treeValue =
                '${series.directory.name}${'Season ${s.number.toString().padLeft(2, '0')}'}';
            final expanded =
                sn.expandedTrees.any((value) => value == treeValue);
            return TreeViewItem(
              value: treeValue,
              expanded: expanded,
              content: Text(s.folderTitle),
              leading: const Icon(FluentIcons.folder),
              onInvoked: (item, reason) async {
                if (reason == TreeViewItemInvokeReason.pressed) {
                  return await _folderTitleDialog(context, sn, s);
                }
              },
              children: List.from(
                s.videos.map((v) => _videoTree(context, v, sn)),
              ),
            );
          },
        ),
      );
    }
  }

  // For Video Track
  TreeViewItem _videoTree(BuildContext context, Video video, ShowNotifier sn) {
    final expandVid =
        sn.expandedTrees.any((value) => value == video.mainFile.path);
    final expandAud = sn.expandedTrees
        .any((value) => value == '${video.mainFile.path}Audios');
    final expandSub = sn.expandedTrees
        .any((value) => value == '${video.mainFile.path}Subtitles');
    final expandChap = sn.expandedTrees
        .any((value) => value == '${video.mainFile.path}Chapters');
    final expandAttach = sn.expandedTrees
        .any((value) => value == '${video.mainFile.path}Attachments');

    final audios = [
      ...video.embeddedAudios,
      ...video.addedAudios,
    ];
    final subtitles = [
      ...video.embeddedSubtitles,
      ...video.addedSubtitles,
    ];
    final chapters = [
      ...video.embeddedChapters,
      ...video.addedChapters,
    ];
    final attachments = [
      ...video.embeddedAttachments,
      ...video.addedAttachments
    ];
    return TreeViewItem(
      value: video.mainFile.path,
      expanded: expandVid,
      leading: const Icon(FluentIcons.my_movies_t_v),
      onInvoked: (item, reason) async {
        if (reason == TreeViewItemInvokeReason.pressed) {
          return await _videoTitleDialog(context, sn, video);
        }
      },
      content: Text.rich(
        TextSpan(
            text: '${video.title}.${video.mainFile.extension}',
            style: FluentTheme.of(context).typography.body),
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.fade,
      ),
      children: [
        if (audios.isNotEmpty) ...[
          TreeViewItem(
            value: '${video.mainFile.path}Audios',
            expanded: expandAud,
            leading: const Icon(FluentIcons.volume3),
            content: Text(AppLocalizations.of(context).audios),
            children: List<TreeViewItem>.from(
              audios.map(
                (e) => _trackTree(
                    context, AppLocalizations.of(context).audio, e, sn),
              ),
            ),
          ),
        ],
        if (subtitles.isNotEmpty) ...[
          TreeViewItem(
            value: '${video.mainFile.path}Subtitles',
            expanded: expandSub,
            leading: const Icon(FluentIcons.cc),
            content: Text(AppLocalizations.of(context).subtitles),
            children: List<TreeViewItem>.from(
              subtitles.map(
                (e) => _trackTree(
                    context, AppLocalizations.of(context).subtitle, e, sn),
              ),
            ),
          ),
        ],
        if (chapters.isNotEmpty) ...[
          TreeViewItem(
            value: '${video.mainFile.path}Chapters',
            expanded: expandChap,
            leading: const Icon(FluentIcons.double_bookmark),
            content: Text(AppLocalizations.of(context).chapters),
            children: List<TreeViewItem>.from(
              chapters.map(
                (e) => _extraTree(
                    context, AppLocalizations.of(context).chapter, e, sn),
              ),
            ),
          ),
        ],
        if (attachments.isNotEmpty) ...[
          TreeViewItem(
            value: '${video.mainFile.path}Attachments',
            expanded: expandAttach,
            leading: const Icon(FluentIcons.attach),
            content: Text(AppLocalizations.of(context).attachments),
            children: List<TreeViewItem>.from(
              attachments.map(
                (e) => _extraTree(
                    context, AppLocalizations.of(context).attachment, e, sn),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // For Audios and Subtitles
  TreeViewItem _trackTree(
    BuildContext context,
    String type,
    TrackProperties track,
    ShowNotifier sn,
  ) {
    final bool embedded = track is EmbeddedTrack;
    final theme = FluentTheme.of(context);
    return TreeViewItem(
      value: embedded ? track.uid : (track as AddedTrack).file.path,
      collapsable: false,
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
      leading: Icon(
        FluentIcons.link,
        color: track.include ? FluentTheme.of(context).accentColor : null,
      ),
      onInvoked: (item, reason) async {
        if (reason == TreeViewItemInvokeReason.pressed) {
          return await _trackDialog(context, type, sn, track);
        }
      },
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 4),
            decoration: BoxDecoration(
              border: Border.all(color: FluentTheme.of(context).activeColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              track.language.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              embedded ? track.uid : (track as AddedTrack).file.name,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  // For Chapters and Attachments
  TreeViewItem _extraTree(
    BuildContext context,
    String type,
    TrackProperties extra,
    ShowNotifier sn,
  ) {
    final bool embedded = extra is EmbeddedTrack;
    final theme = FluentTheme.of(context);

    String displayName = '';
    if (type == AppLocalizations.of(context).chapter) {
      if (embedded) {
        displayName =
            '${extra.uid} (${AppLocalizations.of(context).entries}: ${(extra.info as MenuInfo).chapters.length})';
      } else {
        displayName = (extra as AddedTrack).file.name;
      }
    } else if (type == AppLocalizations.of(context).attachment) {
      if (embedded) {
        displayName = '${extra.uid} (${(extra.info as AttachmentInfo).name})';
      } else {
        displayName = (extra as AddedTrack).file.name;
      }
    }
    return TreeViewItem(
      value: embedded ? extra.uid : (extra as AddedTrack).file.path,
      collapsable: false,
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
      leading: Icon(
        FluentIcons.link,
        color: extra.include ? FluentTheme.of(context).accentColor : null,
      ),
      onInvoked: (item, reason) async {
        if (reason == TreeViewItemInvokeReason.pressed) {
          return await _extraDialog(context, type, sn, extra);
        }
      },
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              displayName,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
