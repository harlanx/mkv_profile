import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/utilities/custom_widgets/custom_widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'bottom_progress_bar.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({Key? key}) : super(key: key);

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> with WidgetsBindingObserver {
  late final appSettings = context.watch<AppSettingsNotifier>();
  late final queue = context.read<ShowQueueListNotifier>();
  late final PlutoGridStateManager manager;
  final List<PlutoRow> rows = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    manager.setConfiguration(_plutoConfig(context, context.read<AppSettingsNotifier>().themeMode));
    manager.notifyListeners();
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Visibility(
        visible: queue.items.isNotEmpty,
        child: CommandBarCard(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconLabelButton(
                onPressed: () => _debugPrcsKeep(queue),
                iconData: FluentIcons.merge,
                label: 'Merge Queue',
              ),
              const SizedBox(width: 6),
              IconLabelButton(
                onPressed: () => print('##'),
                iconData: FluentIcons.delete,
                label: 'Clear Queue',
              ),
            ],
          ),
        ),
      ),
      padding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox.expand(
          child: mt.Material(
            color: Colors.transparent,
            child: PlutoGrid(
              configuration: _plutoConfig(context, appSettings.themeMode),
              onLoaded: (event) {
                manager = event.stateManager;
                event.stateManager.appendRows(
                  List.generate(
                    queue.items.length,
                    (index) => PlutoRow(
                      cells: {
                        // value: index is just the placeholder.
                        // we use the rowIdx from Renderer Context
                        // to get updated row numbering since
                        // this Package has it's own state management.
                        'show': PlutoCell(value: index),
                        'profile': PlutoCell(value: index),
                        'progress': PlutoCell(value: index),
                      },
                    ),
                  ),
                );
              },
              columns: [
                PlutoColumn(
                  title: 'Show',
                  field: 'show',
                  type: PlutoColumnType.number(),
                  readOnly: true,
                  enableRowDrag: false,
                  enableSorting: false,
                  enableColumnDrag: false,
                  enableEditingMode: false,
                  enableFilterMenuItem: false,
                  enableSetColumnsMenuItem: false,
                  enableHideColumnMenuItem: false,
                  renderer: (rendererContext) {
                    int index = rendererContext.rowIdx;
                    return ChangeNotifierProvider<ShowQueueNotifier>.value(
                        value: queue.items[rendererContext.rowIdx],
                        builder: (context, child) {
                          final show = context.read<ShowQueueNotifier>();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  show.show.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(show.progress <= 0 ? FluentIcons.remove : FluentIcons.cancel),
                                onPressed: !isProcessing
                                    ? () {
                                        queue.removeQueue(index);
                                        manager.removeRows([rendererContext.row]);
                                      }
                                    : null,
                              )
                            ],
                          );
                        });
                  },
                ),
                PlutoColumn(
                  title: 'Profile',
                  field: 'profile',
                  type: PlutoColumnType.number(),
                  readOnly: true,
                  enableRowDrag: false,
                  enableSorting: false,
                  enableColumnDrag: false,
                  enableEditingMode: false,
                  enableFilterMenuItem: false,
                  enableSetColumnsMenuItem: false,
                  enableHideColumnMenuItem: false,
                  renderer: (rendererContext) {
                    int index = rendererContext.rowIdx;
                    final show = queue.items[index];
                    return Text(AppData.profiles.items[show.profileIndex].name);
                  },
                ),
                PlutoColumn(
                  title: 'Progress',
                  field: 'progress',
                  width: 100,
                  type: PlutoColumnType.number(),
                  frozen: PlutoColumnFrozen.end,
                  readOnly: true,
                  enableRowDrag: false,
                  enableSorting: false,
                  enableColumnDrag: false,
                  enableEditingMode: false,
                  enableDropToResize: false,
                  enableFilterMenuItem: false,
                  enableSetColumnsMenuItem: false,
                  enableHideColumnMenuItem: false,
                  renderer: (rendererContext) {
                    int index = rendererContext.rowIdx;
                    return ChangeNotifierProvider.value(
                      value: queue.items[index],
                      builder: (context, child) {
                        final show = context.watch<ShowQueueNotifier>();
                        return Align(
                          alignment: AlignmentDirectional.center,
                          child: Text(show.progress <= 0 ? '— — —' : '${show.progress.toStringAsFixed(2)}%'),
                        );
                      },
                    );
                  },
                ),
              ],
              rows: rows,
            ),
          ),
        ),
      ),
      bottomBar: const SizedBox(height: 50, child: BottomProgressBar()),
    );
  }

  _debugPrcsKeep(ShowQueueListNotifier shows) async {
    isProcessing = true;
    manager.notifyListeners();

    for (int i = 0; i < shows.items.length; i++) {
      shows.updateActiveIndex(i);

      for (double p = 0; p <= 100; p += 2) {
        await Future.delayed(const Duration(milliseconds: 100), () {
          if (shows.items.isNotEmpty) {
            shows.items[i].updateProgress(p);
            shows.updateProgress();
          }
        });
      }
    }

    isProcessing = false;
    shows.updateActiveIndex(null);
    manager.forceUpdate();
  }

  // Not safe to use this kind of method in production.
  _debugPrcsRemove(ShowQueueListNotifier shows) async {
    for (int i = shows.items.length - 1; i >= 0; --i) {
      manager
        ..setRowColorCallback(
          (rowColorContext) {
            if (rowColorContext.rowIdx == 0) return FluentTheme.of(context).accentColor.normal;
            return Colors.transparent;
          },
        )
        ..notifyListeners();
      shows.updateActiveIndex(i);
      for (double i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(seconds: 1), () {
          if (shows.items.isNotEmpty) {
            shows.items[0].updateProgress(i);
            shows.updateProgress();
          }
        });
      }
      shows.removeQueue(0);
      manager.removeRows([manager.rows.elementAt(0)]);
      manager.notifyListeners();
    }
  }

  PlutoGridConfiguration _plutoConfig(BuildContext context, ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && SystemTheme.isDarkMode)) {
      return PlutoGridConfiguration.dark(
        style: PlutoGridStyleConfig.dark(
          rowColor: ThemeData.dark().cardColor.withOpacity(0.1),
          activatedColor: context.read<AppSettingsNotifier>().systemAccentColor,
          gridBackgroundColor: ThemeData.dark().micaBackgroundColor.withOpacity(0.15),
          gridBorderColor: ThemeData.dark().micaBackgroundColor.withOpacity(0.5),
        ),
      );
    }
    return PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        rowColor: ThemeData.light().cardColor.withOpacity(0.1),
        activatedColor: context.read<AppSettingsNotifier>().systemAccentColor,
        gridBackgroundColor: ThemeData.light().micaBackgroundColor.withOpacity(0.15),
        gridBorderColor: ThemeData.light().micaBackgroundColor.withOpacity(0.5),
      ),
    );
  }
}
