import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:intl/intl.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/utilities/extensions.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

class OutputScreen extends StatefulWidget {
  const OutputScreen({super.key});

  @override
  State<OutputScreen> createState() => OutputScreenState();
}

class OutputScreenState extends State<OutputScreen>
    with WidgetsBindingObserver {
  late final appSettings = context.watch<AppSettingsNotifier>();
  late final outputs = context.watch<OutputNotifier>();
  late PlutoGridStateManager _manager;
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];
  final _vController = ScrollController(), _hController = ScrollController();
  final ValueNotifier<String?> _infoPreview = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
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
                    icon: const Icon(FluentIcons.delete),
                    label: const Text('Remove'),
                    onPressed: outputs.items.isEmpty
                        ? null
                        : () {
                            _infoPreview.value = null;
                            outputs.remove(_selectedIds);
                            _manager.removeRows(_manager.checkedRows);
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
            mode: PlutoGridMode.selectWithOneTap,
            configuration: _plutoConfig(context, appSettings.themeMode),
            onLoaded: (event) => _manager = event.stateManager,
            onSelected: (event) {
              _infoPreview.value = outputs
                      .items[event.row!.cells.entries.first.value.value]
                      ?.info
                      .log ??
                  'No Info';
            },
            onRowChecked: (event) {
              if (event.row != null && event.rowIdx != null) {
                if (event.isChecked!) {
                  outputs.addSelected(
                      {event.row!.cells.entries.first.value.value});
                } else {
                  outputs.removeSelected(
                      {event.row!.cells.entries.first.value.value});
                }
              } else {
                if (event.isChecked!) {
                  outputs.addSelected(outputs.items.keys.toSet());
                } else {
                  outputs.removeSelected(outputs.items.keys.toSet());
                }
              }
            },
            columns: _columns,
            rows: _rows,
          ),
        ),
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(direction: Axis.horizontal),
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Scrollbar(
              controller: _vController,
              thumbVisibility: true,
              child: Scrollbar(
                controller: _hController,
                thumbVisibility: true,
                notificationPredicate: (notification) =>
                    notification.depth == 1,
                child: SingleChildScrollView(
                  controller: _vController,
                  child: SingleChildScrollView(
                    controller: _hController,
                    scrollDirection: Axis.horizontal,
                    child: ValueListenableBuilder<String?>(
                        valueListenable: _infoPreview,
                        builder: (context, text, child) {
                          if (text != null) {
                            return SelectableText(text);
                          }
                          // Empty Widget
                          return const SizedBox.shrink();
                        }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<int> get _selectedIds =>
      _manager.checkedRows.map<int>((e) => e.cells.values.first.value).toSet();

  void fetchData() {
    _manager.removeAllRows();
    _manager.removeColumns(_manager.columns);
    _manager.insertColumns(0, [
      PlutoColumn(
        title: 'Info',
        field: 'info',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableRowDrag: false,
        enableSorting: false,
        enableColumnDrag: false,
        enableRowChecked: outputs.items.isNotEmpty,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        renderer: (rendererContext) {
          int id = rendererContext.cell.value;
          var output = outputs.items[id]!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  output.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  output.path,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
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
          int id = rendererContext.cell.value;
          var output = outputs.items[id]!;
          return Text(output.profile);
        },
      ),
      PlutoColumn(
        title: 'Date',
        field: 'date',
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
          int id = rendererContext.cell.value;
          var output = outputs.items[id]!;
          return Text(
              DateFormat("mm-dd-yyyy hh:mm:ss a").format(output.dateTime));
        },
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
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
          int id = rendererContext.cell.value;
          var output = outputs.items[id]!;
          return Text(output.info.taskStatus.name.toCapitalized());
        },
      ),
    ]);

    _manager.appendRows(outputs.items.entries
        .map((e) => PlutoRow(cells: {
              'info': PlutoCell(value: e.key),
              'profile': PlutoCell(value: e.key),
              'date': PlutoCell(value: e.key),
              'status': PlutoCell(value: e.key),
            }))
        .toList());
  }

  // Theme styling
  PlutoGridConfiguration _plutoConfig(
      BuildContext context, ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && SystemTheme.isDarkMode)) {
      return PlutoGridConfiguration.dark(
        style: PlutoGridStyleConfig.dark(
          rowColor: FluentThemeData.dark().cardColor.withOpacity(0.1),
          activatedColor: context.read<AppSettingsNotifier>().systemAccentColor,
          activatedBorderColor: FluentThemeData.dark().borderInputColor,
          gridBackgroundColor:
              FluentThemeData.dark().micaBackgroundColor.withOpacity(0.15),
          gridBorderColor: Colors.transparent,
        ),
      );
    }
    return PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        rowColor: FluentThemeData.light().cardColor.withOpacity(0.1),
        activatedColor: context.read<AppSettingsNotifier>().systemAccentColor,
        activatedBorderColor: FluentThemeData.light().borderInputColor,
        gridBackgroundColor:
            FluentThemeData.light().micaBackgroundColor.withOpacity(0.15),
        gridBorderColor: Colors.transparent,
      ),
    );
  }
}
