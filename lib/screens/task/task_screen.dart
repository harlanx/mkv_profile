import 'package:flutter/material.dart' as mt;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import '../../data/app_data.dart';
import '../../services/app_services.dart';
import '../../utilities/utilities.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> with WidgetsBindingObserver {
  late final appSettings = context.watch<AppSettingsNotifier>();
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
    _manager.setConfiguration(
        _plutoConfig(context, context.read<AppSettingsNotifier>().themeMode));
    _manager.notifyListeners();
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
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
                      label: Text(AppLocalizations.of(context).startTasks),
                      onPressed: _enableButtons
                          ? () {
                              ShowMerger.start(tasks);
                            }
                          : null),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.delete),
                    label: Text(AppLocalizations.of(context).remove),
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
                      label: Text(AppLocalizations.of(context).cancel),
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
        child: mt.Material(
          color: Colors.transparent,
          child: PlutoGrid(
            configuration: _plutoConfig(context, appSettings.themeMode),
            columns: _columns,
            rows: _rows,
            onLoaded: (event) {
              _manager = event.stateManager;
              for (var col in _columns) {
                _manager.autoFitColumn(context, col);
              }
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
    _manager.removeAllRows();
    _manager.removeColumns(_manager.columns);
    // Column Headers
    _manager.insertColumns(0, [
      PlutoColumn(
        title: AppLocalizations.of(context).show,
        field: 'show',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableRowChecked: tasks.items.isNotEmpty,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
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
        title: AppLocalizations.of(context).profile,
        field: 'profile',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          final tn = tasks.items[id]!;
          return Text(tn.profile.name);
        },
      ),
      PlutoColumn(
        title: AppLocalizations.of(context).progess,
        field: 'progress',
        width: 100,
        type: PlutoColumnType.number(),
        readOnly: true,
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableDropToResize: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          return ChangeNotifierProvider.value(
            value: tasks.items[id],
            builder: (context, child) {
              final tn = context.watch<TaskNotifier>();
              return Align(
                alignment: AlignmentDirectional.center,
                child: Text('${tn.progress.toStringAsFixed(2)}%'),
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
    final accent = context.read<AppSettingsNotifier>().accentColor;
    if (themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && SystemTheme.isDarkMode)) {
      return PlutoGridConfiguration.dark(
        style: PlutoGridStyleConfig.dark(
          rowColor: FluentTheme.of(context).cardColor.withOpacity(0.1),
          activatedColor: accent.dark.withOpacity(0.5),
          activatedBorderColor: accent.light,
          gridBackgroundColor:
              FluentTheme.of(context).micaBackgroundColor.withOpacity(0.15),
          gridBorderColor: Colors.transparent,
        ),
      );
    }
    return PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        rowColor: FluentTheme.of(context).cardColor.withOpacity(0.1),
        activatedColor: accent.light.withOpacity(0.5),
        activatedBorderColor: accent.dark,
        gridBackgroundColor:
            FluentTheme.of(context).micaBackgroundColor.withOpacity(0.15),
        gridBorderColor: Colors.transparent,
      ),
    );
  }
}
