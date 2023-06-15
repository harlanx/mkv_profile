import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as mt;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:intl/intl.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import '../../data/app_data.dart';
import '../../utilities/utilities.dart';

class OutputsScreen extends StatefulWidget {
  const OutputsScreen({super.key});

  @override
  State<OutputsScreen> createState() => OutputsScreenState();
}

class OutputsScreenState extends State<OutputsScreen>
    with WidgetsBindingObserver {
  late final appSettings = context.watch<AppSettingsNotifier>();
  late final outputs = context.watch<OutputNotifier>();
  late PlutoGridStateManager _manager;
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];
  final _verticalCtrl = ScrollController(),
      _horizontalCtrl = ScrollController();
  final _infoPreview = ValueNotifier<String?>(null);

  final _splitViewCtrl = MultiSplitViewController(areas: [
    Area(size: 350, minimalSize: 200),
    Area(size: 150, minimalSize: 100),
  ]);

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
                    onPressed: outputs.selected.isEmpty
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
      content: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(dividerThickness: 3),
        child: MultiSplitView(
          controller: _splitViewCtrl,
          antiAliasingWorkaround: true,
          axis: Axis.vertical,
          dividerBuilder: (p0, p1, p2, p3, p4, p5) {
            return Divider(
              direction: Axis.horizontal,
              style: DividerThemeData(
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).cardColor,
                ),
              ),
            );
          },
          children: [
            SizedBox.expand(
              child: mt.Material(
                color: Colors.transparent,
                child: PlutoGrid(
                  mode: PlutoGridMode.selectWithOneTap,
                  configuration: _plutoConfig(context, appSettings.themeMode),
                  onLoaded: (event) {
                    _manager = event.stateManager;
                    for (var col in _columns) {
                      _manager.autoFitColumn(context, col);
                    }
                  },
                  onSelected: (event) {
                    _infoPreview.value =
                        outputs.items[event.cell?.value]?.info.log;
                  },
                  onRowChecked: (event) {
                    if (event.row != null && event.rowIdx != null) {
                      if (event.isChecked!) {
                        outputs.addSelected({event.row!.cells['info']!.value});
                      } else {
                        outputs
                            .removeSelected({event.row!.cells['info']!.value});
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
                controller: _verticalCtrl,
                thumbVisibility: true,
                child: Scrollbar(
                  controller: _horizontalCtrl,
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.depth == 1,
                  child: SingleChildScrollView(
                    controller: _verticalCtrl,
                    child: SingleChildScrollView(
                      controller: _horizontalCtrl,
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
        enableSorting: false,
        enableColumnDrag: false,
        enableRowChecked: outputs.items.isNotEmpty,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          final output = outputs.items[id]!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  output.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              Flexible(
                child: SelectableText.rich(
                  TextSpan(
                    text: output.path.noBreakHyphen,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await Directory(output.path).revealInExplorer();
                      },
                  ),
                  maxLines: 1,
                  style:
                      FluentTheme.of(context).typography.bodyStrong?.copyWith(
                            color: Colors.blue,
                          ),
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
        enableSorting: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        renderer: (rendererContext) {
          final int id = rendererContext.cell.value;
          final output = outputs.items[id]!;
          return Text(output.profile);
        },
      ),
      PlutoColumn(
        title: 'Date',
        field: 'date',
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
          final output = outputs.items[id]!;
          return Text(
              DateFormat('mm-dd-yyyy hh:mm:ss a').format(output.dateTime));
        },
      ),
      PlutoColumn(
        title: 'Duration',
        field: 'duration',
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
          final output = outputs.items[id]!;
          return Text(output.duration.formatDuration());
        },
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
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
          final output = outputs.items[id]!;
          return Text(output.info.taskStatus.name.capitalized);
        },
      ),
    ]);

    _manager.appendRows(
      List.from(
        outputs.items.entries.map(
          (e) => PlutoRow(
            checked: outputs.selected.contains(e.key),
            cells: {
              'info': PlutoCell(value: e.key),
              'profile': PlutoCell(value: e.key),
              'date': PlutoCell(value: e.key),
              'duration': PlutoCell(value: e.key),
              'status': PlutoCell(value: e.key),
            },
          ),
        ),
      ),
    );
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
