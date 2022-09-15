import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors;
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'home_screen_menu.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final MultiSplitViewController _splitViewController =
      MultiSplitViewController(areas: [
    Area(size: AppData.appSettings.folderPanelWidth, minimalSize: 300),
    Area(size: AppData.appSettings.infoPanelWidth, minimalSize: 500)
  ]);

  final ValueNotifier<bool> _isDragging = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const HomeScreenMenuBar(),
      content: Consumer<ShowListNotifier>(
        builder: (context, showList, child) {
          return _buildBody(showList, context);
        },
      ),
    );
  }

  Widget _buildBody(ShowListNotifier showList, BuildContext context) {
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
            return Divider(
              direction: Axis.vertical,
              style: DividerThemeData(
                thickness: 3,
                decoration:
                    BoxDecoration(color: FluentTheme.of(context).cardColor),
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
      onDragDone: (xfile) async {
        await showList.add(xfile.files.map((e) => e.path).toList());
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isDragging,
        builder: (context, value, _) {
          return Container(
            padding: const EdgeInsets.all(5.0),
            color: value && showList.items.isEmpty
                ? FluentTheme.of(context).disabledColor.withOpacity(0.5)
                : null,
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
            await shows.add(xfile.files.map((e) => e.path).toList());
          },
          child: ValueListenableBuilder<bool>(
              valueListenable: _isDragging,
              builder: (context, value, _) {
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  color: value && shows.items.isEmpty
                      ? FluentTheme.of(context).disabledColor.withOpacity(0.5)
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
                        itemBuilder: (_, index) => _folderRow(context, shows,
                            shows.items.entries.elementAt(index).key),
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Widget _folderRow(BuildContext context, ShowListNotifier shows, int id) {
    var showNotifier = shows.items[id]!;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: ListTile.selectable(
        selected: shows.selectedID == id,
        selectionMode: ListTileSelectionMode.single,
        title: Text(
          showNotifier.item.title,
          softWrap: false,
          style: const TextStyle(overflow: TextOverflow.fade),
        ),
        leading: Container(
          height: 34,
          alignment: Alignment.center,
          child: Text(showNotifier.item is Movie ? '(Movie)' : '(Series)'),
        ),
        subtitle: Text(
          showNotifier.item.directory.path,
          softWrap: false,
          style: const TextStyle(overflow: TextOverflow.fade),
        ),
        onPressed: () => shows.selectID(id),
        trailing: Tooltip(
          message: 'Remove',
          child: IconButton(
            icon: const Icon(FluentIcons.remove),
            onPressed: () => shows.remove(id),
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
    var shows = context.watch<ShowListNotifier>();
    if (shows.selectedID == null) {
      return const Center(
        child: Text(
          'Select from list',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ChangeNotifierProvider<ShowNotifier>.value(
      value: shows.items[shows.selectedID]!,
      child: Consumer<ShowNotifier>(
        builder: (context, show, _) {
          var showTitle = TitleScanner.scanTitle(show);
          return TreeView(
            scrollController: _controller,
            onItemInvoked: (item, reason) async {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                if (!item.expanded) {
                  show.addToCollapsedTrees(item.value as String);
                } else {
                  show.removeFromCollapsedTrees(item.value as String);
                }
              });
            },
            items: [
              TreeViewItem(
                value: show.item.title,
                collapsable: false,
                expanded: !(show.collapsedTrees
                    .any((element) => element == show.item.title)),
                leading: const Icon(FluentIcons.folder),
                content: Text.rich(
                  TextSpan(
                      text: showTitle,
                      style: FluentTheme.of(context).typography.body),
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                children: _nodes(theme, show, showTitle, context),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateSubtitleDialog(
      ShowNotifier showNotifier, Subtitle sub, BuildContext context) async {
    var language = sub.language;
    var sdh = ValueNotifier(sub.isSDH);
    var initialTitle = language.fullName;
    var controller = TextEditingController(text: initialTitle);
    return await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 400),
        title: const Text('Subtitle'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sub.file.name,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
            Flexible(
              child: AutoSuggestBox<LanguageCode>(
                controller: controller,
                onSelected: (selected) {
                  if (selected.value != null) {
                    language = selected.value!;
                  }
                },
                items: AppData.languageCodes.items.map(
                  (code) {
                    return AutoSuggestBoxItem<LanguageCode>(
                      value: code,
                      label: code.fullName,
                      onFocusChange: (focused) {
                        if (!focused && controller.text.isEmpty) {
                          controller.text = initialTitle;
                        }
                      },
                      child: Text(
                        code.fullName,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: sdh,
              builder: (context, value, child) {
                return Checkbox(
                  semanticLabel: 'isSDH',
                  content: const Text('SDH'),
                  checked: value,
                  onChanged: (val) {
                    if (val != null) {
                      sdh.value = val;
                    }
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          FilledButton(
            child: const Text('Save'),
            onPressed: () {
              Navigator.pop(context);
              sub.update(language: language, isSDH: sdh.value);
              showNotifier.refresh();
            },
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<TreeViewItem> _nodes(FluentThemeData theme, ShowNotifier showNotifier,
      String showTitle, BuildContext context) {
    if (showNotifier.item is Movie) {
      var movie = showNotifier.item as Movie;
      return [
        TreeViewItem(
          value: movie.directory.path,
          backgroundColor:
              ButtonState.all(theme.disabledColor.withOpacity(0.08)),
          expanded: !(showNotifier.collapsedTrees
              .any((element) => element == movie.directory.path)),
          leading: const Icon(FluentIcons.my_movies_t_v, size: 15),
          content: Text(
            '$showTitle.${(movie.video.mainFile).extension}',
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          children: movie.video.subtitles.map<TreeViewItem>(
            (sbtl) {
              return TreeViewItem(
                value: sbtl.file.path,
                backgroundColor: ButtonState.all(Colors.transparent),
                collapsable: false,
                onInvoked: (item, reason) {
                  _updateSubtitleDialog(showNotifier, sbtl, context);
                  return Future.value();
                },
                leading: Icon(
                  sbtl.isSDH ? FluentIcons.c_c_solid : FluentIcons.cc,
                  size: 12,
                ),
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${sbtl.language.name} - ',
                      style: theme.typography.caption
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      sbtl.file.name,
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
      (sns) {
        final String seasonNumber = sns.season.toString().padLeft(2, '0');
        final String seasonName =
            '${series.directory.name} Season $seasonNumber';
        return TreeViewItem(
          value: seasonName,
          backgroundColor:
              ButtonState.all(theme.disabledColor.withOpacity(0.15)),
          expanded: !(showNotifier.collapsedTrees
              .any((element) => element == seasonName)),
          leading: const Icon(FluentIcons.number_symbol, size: 15),
          content: Text('Season $seasonNumber'),
          children: sns.videos.map(
            (v) {
              var episodeTitle = TitleScanner.scanEpisode(
                  showNotifier.profile, sns.season, showTitle, v);
              return TreeViewItem(
                value: v.mainFile.path,
                backgroundColor:
                    ButtonState.all(theme.disabledColor.withOpacity(0.08)),
                expanded: !(showNotifier.collapsedTrees
                    .any((element) => element == v.mainFile.path)),
                leading: const Icon(FluentIcons.my_movies_t_v, size: 15),
                content: Text(
                  '$episodeTitle.${v.mainFile.extension}',
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
                children: v.subtitles.map(
                  (sbtl) {
                    return TreeViewItem(
                      value: sbtl.file.path,
                      backgroundColor: ButtonState.all(Colors.transparent),
                      collapsable: false,
                      onInvoked: (item, reason) {
                        _updateSubtitleDialog(showNotifier, sbtl, context);
                        return Future.value();
                      },
                      leading: Icon(
                        sbtl.isSDH ? FluentIcons.c_c_solid : FluentIcons.cc,
                        size: 12,
                      ),
                      content: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${sbtl.language.name} - ',
                            style: theme.typography.caption
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            sbtl.file.name,
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
