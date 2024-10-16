import 'package:flutter/material.dart' show Material;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../services/app_services.dart';
import '../../utilities/utilities.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> with WidgetsBindingObserver {
  late final tasks = context.watch<TaskListNotifier>();
  late final PlutoGridStateManager _manager;
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];

  @override
  void initState() {
    super.initState();
    // Refer to https://github.com/bosskmk/pluto_grid/issues/283#issuecomment-944137222 and https://stackoverflow.com/a/68607804/15589545
    // Pluto Grid has it's own state management so it's better
    // to make sure that it is fully built before accessing the manager
    // rather than accessing it after our widgets is built.
    Future.delayed(Duration.zero, () {
      if (mounted) fetchData();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _manager
        .setConfiguration(_plutoConfig(context, AppData.appSettings.themeMode));
    _manager.notifyListeners();
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScaffoldPage(
      header: CommandBarCard(
        child: Row(
          children: [
            Flexible(
              child: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.scrolling,
                overflowItemAlignment: MainAxisAlignment.end,
                primaryItems: [
                  CommandBarButton(
                      icon: const Icon(FluentIcons.combine),
                      label: Text(l10n.startTasks),
                      onPressed: _enableButtons
                          ? () {
                              ShowMerger.start(tasks);
                            }
                          : null),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.delete),
                    label: Text(l10n.remove),
                    onPressed: _enableButtons
                        ? () {
                            tasks.remove(_selectedIds);
                            _manager.removeRows(_manager.checkedRows);
                          }
                        : null,
                  ),
                  if (tasks.active)
                    CommandBarButton(
                      icon: const Icon(FluentIcons.cancel),
                      label: Text(l10n.cancel),
                      onPressed: () async {
                        await ShowMerger.process?.operation.cancel();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      padding: EdgeInsets.zero,
      content: SizedBox.expand(
        child: Material(
          color: Colors.transparent,
          child: PlutoGrid(
            configuration: _plutoConfig(context, AppData.appSettings.themeMode),
            columns: _columns,
            mode: PlutoGridMode.selectWithOneTap,
            rows: _rows,
            onLoaded: (event) {
              _manager = event.stateManager;
            },
            onRowChecked: (event) {
              if (event.row != null && event.rowIdx != null) {
                if (event.isChecked!) {
                  tasks.addSelected({event.row!.cells['show']!.value});
                } else {
                  tasks.removeSelected({event.row!.cells['show']!.value});
                }
              } else {
                if (event.isChecked!) {
                  tasks.addSelected(tasks.items.keys.toSet());
                } else {
                  tasks.removeSelected(tasks.items.keys.toSet());
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Set<int> get _selectedIds =>
      _manager.checkedRows.map<int>((e) => e.cells.values.first.value).toSet();

  void fetchData() {
    final l10n = AppLocalizations.of(context);

    _manager.removeAllRows();
    _manager.removeColumns(_manager.columns);
    // Column Headers
    _manager.insertColumns(0, [
      PlutoColumn(
        title: l10n.show,
        field: 'show',
        type: PlutoColumnType.number(),
        enableRowChecked: tasks.items.isNotEmpty,
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          final tn = tasks.items[id]!;
          return Text(
            tn.show.directory.name,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          );
        },
      ),
      PlutoColumn(
        title: l10n.profile,
        field: 'profile',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          final tn = tasks.items[id]!;
          return Text(
            tn.profile.name,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          );
        },
      ),
      PlutoColumn(
        title: l10n.progess,
        field: 'progress',
        width: 100,
        type: PlutoColumnType.number(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          return ChangeNotifierProvider.value(
            value: tasks.items[id],
            builder: (context, child) {
              final tn = context.watch<TaskNotifier>();
              return Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  '${tn.progress.toStringAsFixed(2)}%',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              );
            },
          );
        },
      ),
    ]);

    _manager.appendRows(
      List.from(
        tasks.items.entries.map(
          (e) => PlutoRow(
            // For when user come back from the page and restore selected states.
            checked: tasks.selected.contains(e.key),
            cells: {
              'show': PlutoCell(value: e.key),
              'profile': PlutoCell(value: e.key),
              'progress': PlutoCell(value: e.key)
            },
          ),
        ),
      ),
    );
  }

  bool get _enableButtons {
    if (tasks.selected.isEmpty || tasks.active) {
      return false;
    } else {
      return true;
    }
  }

  // Theme styling
  PlutoGridConfiguration _plutoConfig(
      BuildContext context, ThemeMode themeMode) {
    final theme = FluentTheme.of(context);

    if (themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding
                .instance.platformDispatcher.platformBrightness.isDark)) {
      return PlutoGridConfiguration.dark(
        enableMoveHorizontalInEditing: false,
        style: PlutoGridStyleConfig.dark(
          rowColor: Colors.transparent,
          activatedColor: theme.resources.subtleFillColorSecondary,
          activatedBorderColor:
              theme.accentColor.defaultBrushFor(theme.brightness),
          gridBackgroundColor: Colors.transparent,
          gridBorderColor: Colors.transparent,
        ),
      );
    }
    return PlutoGridConfiguration(
      enableMoveHorizontalInEditing: false,
      style: PlutoGridStyleConfig(
        rowColor: Colors.transparent,
        activatedColor: theme.resources.subtleFillColorSecondary,
        activatedBorderColor:
            theme.accentColor.defaultBrushFor(theme.brightness),
        gridBackgroundColor: Colors.transparent,
        gridBorderColor: Colors.transparent,
      ),
    );
  }
}
