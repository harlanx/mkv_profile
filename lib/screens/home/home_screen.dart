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

  final _controller = ScrollController();
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
            final notifier = context.watch<ShowNotifier>();
            return ListView(
              controller: _controller,
              padding: const EdgeInsets.all(8),
              children: [
                // Folder
                HyperlinkButton(
                  onPressed: () async =>
                      await _folderTitleDialog(context, notifier),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.folder),
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
                // Nodes
                ..._nodes(context, notifier),
              ],
            );
          },
        );
      },
    );
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
        for (var chapter in video.embeddedChapters) {
          chapter.include = !video.removeChapters;
        }
        for (var attachment in video.embeddedAttachments) {
          attachment.include = !video.removeAttachments;
        }
        notifier.refresh();
      }
    });
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

  List<Widget> _nodes(BuildContext context, ShowNotifier notifier) {
    if (notifier.show is Movie) {
      final movie = notifier.show as Movie;
      return [_videoNode(context, notifier, 0, movie.video)];
    } else {
      final series = notifier.show as Series;
      return List.from(
        series.seasons.map(
          (season) {
            final nodeValue =
                '${series.directory.name}${'Season ${season.number.toString().padLeft(2, '0')}'}';
            final expandSeason =
                notifier.expandedNodes.any((value) => value == nodeValue);
            return CustomExpander(
              initiallyExpanded: expandSeason,
              onStateChanged: (value) {
                if (value) {
                  notifier.expandedNodes.add(nodeValue);
                } else {
                  notifier.expandedNodes.remove(nodeValue);
                }
              },
              headerHeight: 30,
              header: HyperlinkButton(
                onPressed: () async =>
                    await _folderTitleDialog(context, notifier, season),
                child: Row(
                  children: [
                    const Icon(FluentIcons.folder),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                          text: season.folderTitle,
                          style: FluentTheme.of(context).typography.body),
                      softWrap: false,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.from(
                  season.videos
                      .map((v) => _videoNode(context, notifier, 16, v)),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  // For Video Track
  Widget _videoNode(
    BuildContext context,
    ShowNotifier notifier,
    double leftPadding,
    Video video,
  ) {
    final videoPadding = leftPadding;
    final trackPadding = videoPadding + 32;
    final itemPadding = trackPadding + 24;
    final expandVid =
        notifier.expandedNodes.any((value) => value == video.mainFile.path);
    final expandAud = notifier.expandedNodes
        .any((value) => value == '${video.mainFile.path}Audios');
    final expandSub = notifier.expandedNodes
        .any((value) => value == '${video.mainFile.path}Subtitles');
    final expandChap = notifier.expandedNodes
        .any((value) => value == '${video.mainFile.path}Chapters');
    final expandAttach = notifier.expandedNodes
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
    // Video Node
    return CustomExpander(
      initiallyExpanded: expandVid,
      onStateChanged: (value) {
        if (value) {
          notifier.expandedNodes.add(video.mainFile.path);
        } else {
          notifier.expandedNodes.remove(video.mainFile.path);
        }
      },
      headerHeight: 30,
      header: HyperlinkButton(
        onPressed: () async =>
            await _videoTitleDialog(context, notifier, video),
        child: Padding(
          padding: EdgeInsets.only(left: videoPadding),
          child: Row(
            children: [
              const Icon(FluentIcons.my_movies_t_v),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                      text: '${video.fileTitle}.${video.mainFile.extension}',
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
          CustomExpander(
            initiallyExpanded: expandAud,
            onStateChanged: (value) {
              if (value) {
                notifier.expandedNodes.add('${video.mainFile.path}Audios');
              } else {
                notifier.expandedNodes.remove('${video.mainFile.path}Audios');
              }
            },
            headerHeight: 30,
            header: Padding(
              padding: EdgeInsets.only(left: trackPadding),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.volume3,
                    color: FluentTheme.of(context).accentColor.lighter,
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
                for (var audio in audios)
                  _trackNode(
                    context,
                    notifier,
                    itemPadding,
                    AppLocalizations.of(context).audio,
                    audio,
                  ),
              ],
            ),
          ),
          // Subtitle Nodes
          CustomExpander(
            initiallyExpanded: expandSub,
            onStateChanged: (value) {
              if (value) {
                notifier.expandedNodes.add('${video.mainFile.path}Subtitles');
              } else {
                notifier.expandedNodes
                    .remove('${video.mainFile.path}Subtitles');
              }
            },
            headerHeight: 30,
            header: Padding(
              padding: EdgeInsets.only(left: trackPadding),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.cc,
                    color: FluentTheme.of(context).accentColor.lighter,
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
                for (var subtitle in subtitles)
                  _trackNode(
                    context,
                    notifier,
                    itemPadding,
                    AppLocalizations.of(context).subtitle,
                    subtitle,
                  ),
              ],
            ),
          ),
          // Chapter Nodes
          CustomExpander(
            initiallyExpanded: expandChap,
            onStateChanged: (value) {
              if (value) {
                notifier.expandedNodes.add('${video.mainFile.path}Chapters');
              } else {
                notifier.expandedNodes.remove('${video.mainFile.path}Chapters');
              }
            },
            headerHeight: 30,
            header: Padding(
              padding: EdgeInsets.only(left: trackPadding),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.double_bookmark,
                    color: FluentTheme.of(context).accentColor.lighter,
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
                for (var chapter in chapters)
                  _extraNode(
                    context,
                    notifier,
                    itemPadding,
                    AppLocalizations.of(context).chapter,
                    chapter,
                  ),
              ],
            ),
          ),
          // Attachment Nodes
          CustomExpander(
            initiallyExpanded: expandAttach,
            onStateChanged: (value) {
              if (value) {
                notifier.expandedNodes.add('${video.mainFile.path}Attachments');
              } else {
                notifier.expandedNodes
                    .remove('${video.mainFile.path}Attachments');
              }
            },
            headerHeight: 30,
            header: Padding(
              padding: EdgeInsets.only(left: trackPadding),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.attach,
                    color: FluentTheme.of(context).accentColor.lighter,
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
                for (var attachment in attachments)
                  _extraNode(
                    context,
                    notifier,
                    itemPadding,
                    AppLocalizations.of(context).attachment,
                    attachment,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // For Audios and Subtitles
  Widget _trackNode(
    BuildContext context,
    ShowNotifier notifier,
    double leftPadding,
    String type,
    TrackProperties track,
  ) {
    final bool embedded = track is EmbeddedTrack;
    final theme = FluentTheme.of(context);
    return SizedBox(
      height: 30,
      child: HyperlinkButton(
        onPressed: () async =>
            await _trackDialog(context, notifier, type, track),
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
          padding: EdgeInsets.only(left: leftPadding),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                embedded ? FluentIcons.link : FluentIcons.add_link,
                color: track.include
                    ? FluentTheme.of(context).accentColor.lighter
                    : FluentTheme.of(context).inactiveColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(1, 0, 1, 2),
                alignment: Alignment.center,
                height: double.infinity,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: FluentTheme.of(context).activeColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  track.language.name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                      text: embedded
                          ? track.uid
                          : (track as AddedTrack).file.name,
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
    );
  }

  // For Chapters and Attachments
  Widget _extraNode(
    BuildContext context,
    ShowNotifier notifier,
    double leftPadding,
    String type,
    TrackProperties extra,
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

    return SizedBox(
      height: 30,
      child: HyperlinkButton(
        onPressed: () async =>
            await _extraDialog(context, notifier, type, extra),
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
          padding: EdgeInsets.only(left: leftPadding),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                embedded ? FluentIcons.link : FluentIcons.add_link,
                color: extra.include
                    ? FluentTheme.of(context).accentColor.lighter
                    : null,
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
    );
  }
}
