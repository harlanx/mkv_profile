import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors;
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'compact_menu.dart';

class CompactPage extends StatelessWidget {
  CompactPage({Key? key}) : super(key: key);

  final MultiSplitViewController _splitViewController = MultiSplitViewController(areas: [
    Area(size: AppData.appSettings.folderPanelWidth, minimalSize: 300),
    Area(size: AppData.appSettings.infoPanelWidth, minimalSize: 500)
  ]);

  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const CompactMenuBar(),
      content: Consumer<ShowListNotifier>(
        builder: (context, showList, child) {
          return _buildBody(showList);
        },
      ),
    );
  }

  Widget _buildBody(ShowListNotifier showList) {
    Widget child;

    if (showList.items.isEmpty) {
      child = const Center(
        child: Text(
          'Drop folders here.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      child = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(dividerThickness: 3),
        child: MultiSplitView(
          controller: _splitViewController,
          antiAliasingWorkaround: true,
          axis: Axis.horizontal,
          dividerBuilder: (p0, p1, p2, p3, p4, p5) {
            return const Divider(
              direction: Axis.vertical,
              style: DividerThemeData(
                thickness: 3,
                decoration: BoxDecoration(color: Colors.transparent),
              ),
            );
          },
          children: [
            FolderPanel(),
            InfoPanel(),
          ],
        ),
      );
    }

    return DropTarget(
      enable: showList.items.isEmpty,
      onDragEntered: (detail) => _isDragging.value = true,
      onDragExited: (detail) => _isDragging.value = false,
      onDragDone: (xfile) {
        showList.addShow(xfile.files.map((e) => e.path).toList());
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isDragging,
        builder: (context, value, _) {
          return Container(
            padding: const EdgeInsets.all(5.0),
            color: value && showList.items.isEmpty ? FluentTheme.of(context).disabledColor.withOpacity(0.5) : null,
            child: child,
          );
        },
      ),
    );
  }
}

class FolderPanel extends StatelessWidget {
  FolderPanel({Key? key}) : super(key: key);

  final ScrollController _controller = ScrollController();
  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Consumer<ShowListNotifier>(
      builder: (context, shows, child) {
        return DropTarget(
          onDragEntered: (detail) => _isDragging.value = true,
          onDragExited: (detail) => _isDragging.value = false,
          onDragDone: (xfile) async {
            shows.addShow(xfile.files.map((e) => e.path).toList());
          },
          child: ValueListenableBuilder<bool>(
              valueListenable: _isDragging,
              builder: (context, value, _) {
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  color: value && shows.items.isEmpty ? FluentTheme.of(context).disabledColor.withOpacity(0.5) : null,
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
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: ListView.builder(
                        controller: _controller,
                        itemCount: shows.items.length,
                        itemBuilder: (_, index) => _folderRow(context, shows, index),
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Widget _folderRow(BuildContext context, ShowListNotifier shows, int index) {
    var showNotifier = shows.items.elementAt(index);
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: ListTile.selectable(
        selected: shows.selectedIndex == index,
        selectionMode: ListTileSelectionMode.single,
        title: Text(
          showNotifier.item.title,
          softWrap: false,
          style: const TextStyle(overflow: TextOverflow.fade),
        ),
        subtitle: Text(
          showNotifier.item.directory.path,
          softWrap: false,
          style: const TextStyle(overflow: TextOverflow.fade),
        ),
        onPressed: () => shows.updateSelectedIndex(index),
        trailing: Tooltip(
          message: 'Remove',
          child: IconButton(
            icon: const Icon(FluentIcons.remove),
            onPressed: () => shows.removeShow(index),
          ),
        ),
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  InfoPanel({Key? key}) : super(key: key);

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    var shows = Provider.of<ShowListNotifier>(context);
    if (shows.selectedIndex == null) {
      return const Center(
        child: Text(
          'Select from list',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ChangeNotifierProvider<ShowNotifier>.value(
      value: shows.items.elementAt(shows.selectedIndex!),
      child: Consumer<ShowNotifier>(
        builder: (context, show, _) {
          var showTitle = TitleScanner.scan(show);
          return TreeView(
            scrollController: _controller,
            onItemInvoked: (tree) async {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (!tree.expanded) {
                  show.addToCollapsedTrees(tree.value as String);
                } else {
                  show.removeFromCollapsedTrees(tree.value as String);
                }
              });
            },
            items: [
              TreeViewItem(
                value: show.item.title,
                collapsable: false,
                expanded: !(show.collapsedTrees.any((element) => element == show.item.title)),
                leading: const Icon(FluentIcons.folder),
                content: Text.rich(
                  TextSpan(
                    style: TextStyle(color: FluentTheme.of(context).accentColor),
                    text: show.item is Movie ? '【Movie】 ' : '【Series】 ',
                    children: [TextSpan(text: showTitle, style: FluentTheme.of(context).typography.body)],
                  ),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                children: nodes(theme, show, showTitle),
              ),
            ],
          );
        },
      ),
    );
  }

  List<TreeViewItem> nodes(ThemeData theme, ShowNotifier showNotifier, String showTitle) {
    if (showNotifier.item is Movie) {
      var movie = showNotifier.item as Movie;
      return [
        TreeViewItem(
          value: movie.directory.path,
          backgroundColor: ButtonState.all(theme.disabledColor.withOpacity(0.08)),
          expanded: !(showNotifier.collapsedTrees.any((element) => element == movie.directory.path)),
          leading: const Icon(FluentIcons.my_movies_t_v, size: 15),
          content: Text(
            '$showTitle.${(movie.video.mainFile).extension}',
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          children: movie.video.subtitles.map<TreeViewItem>(
            (sbtl) {
              return TreeViewItem(
                value: sbtl.sub.path,
                backgroundColor: ButtonState.all(Colors.transparent),
                expanded: !(showNotifier.collapsedTrees.any((element) => element == sbtl.sub.path)),
                leading: Icon(
                  sbtl.isSDH ? FluentIcons.c_c_solid : FluentIcons.cc,
                  size: 12,
                ),
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        sbtl.language,
                        style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      sbtl.sub.name,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        ),
      ];
    }

    var series = showNotifier.item as Series;
    return series.seasons.map(
      (sn) {
        final String seasonName = '${series.directory.name} Season${sn.season.toString().padLeft(2, '0')}';
        return TreeViewItem(
          value: seasonName,
          backgroundColor: ButtonState.all(theme.disabledColor.withOpacity(0.15)),
          expanded: !(showNotifier.collapsedTrees.any((element) => element == seasonName)),
          leading: const Icon(FluentIcons.number_symbol, size: 15),
          content: Text('Season ${sn.season.toString().padLeft(2, '0')}'),
          children: sn.videos.map(
            (v) {
              var episodeTitle = TitleScanner.scanEpisode(showTitle, v.mainFile);
              return TreeViewItem(
                value: v.mainFile.path,
                backgroundColor: ButtonState.all(theme.disabledColor.withOpacity(0.08)),
                expanded: !(showNotifier.collapsedTrees.any((element) => element == v.mainFile.path)),
                leading: const Icon(FluentIcons.my_movies_t_v, size: 15),
                content: Text(
                  '$episodeTitle.${v.mainFile.extension}',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
                children: v.subtitles.map(
                  (sbtl) {
                    return TreeViewItem(
                      value: sbtl.sub.path,
                      backgroundColor: ButtonState.all(Colors.transparent),
                      expanded: !(showNotifier.collapsedTrees.any((element) => element == sbtl.sub.path)),
                      leading: Icon(
                        sbtl.isSDH ? FluentIcons.c_c_solid : FluentIcons.cc,
                        size: 12,
                      ),
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              sbtl.language,
                              style: theme.typography.caption?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            sbtl.sub.name,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ).toList(),
        );
      },
    ).toList();
  }
}
