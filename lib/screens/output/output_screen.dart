import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as mt;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:intl/intl.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../utilities/utilities.dart';

class OutputsScreen extends StatefulWidget {
  const OutputsScreen({super.key});

  @override
  State<OutputsScreen> createState() => OutputsScreenState();
}

class OutputsScreenState extends State<OutputsScreen>
    with WidgetsBindingObserver {
  late final outputs = context.watch<OutputNotifier>();
  PlutoGridStateManager? _manager;
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];
  final _verticalCtrl = ScrollController(),
      _horizontalCtrl = ScrollController();
  final _infoPreview = ValueNotifier<String?>(null);

  late final _splitViewCtrl = MultiSplitViewController(
    areas: [
      Area(
        size: 350,
        min: 200,
        builder: (context, area) => SizedBox.expand(
          child: mt.Material(
            color: Colors.transparent,
            child: PlutoGrid(
              mode: PlutoGridMode.selectWithOneTap,
              configuration:
                  _plutoConfig(context, AppData.appSettings.themeMode),
              onLoaded: (event) {
                _manager = event.stateManager;
                for (var col in _columns) {
                  _manager?.autoFitColumn(context, col);
                }
              },
              onSelected: (event) {
                _infoPreview.value = outputs.items[event.cell?.value]?.info.log;
              },
              onRowChecked: (event) {
                if (event.row != null && event.rowIdx != null) {
                  if (event.isChecked!) {
                    outputs.addSelected({event.row!.cells['info']!.value});
                  } else {
                    outputs.removeSelected({event.row!.cells['info']!.value});
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
      ),
      Area(
        size: 150,
        min: 100,
        builder: (context, area) => Container(
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
              notificationPredicate: (notification) => notification.depth == 1,
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
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      if (mounted) fetchData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _manager?.setConfiguration(
        _plutoConfig(context, AppData.appSettings.themeMode));
    _manager?.notifyListeners();
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
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
                    icon: const Icon(FluentIcons.delete),
                    label: Text(l10n.remove),
                    onPressed: outputs.selected.isEmpty
                        ? null
                        : () {
                            _infoPreview.value = null;
                            outputs.remove(_selectedIds);
                            _manager?.removeRows(_manager!.checkedRows);
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
                  color: theme.cardColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Set<int> get _selectedIds =>
      _manager!.checkedRows.map<int>((e) => e.cells.values.first.value).toSet();

  void fetchData() {
    final l10n = AppLocalizations.of(context);
    _manager?.removeAllRows();
    _manager?.removeColumns(_manager!.columns);
    _manager?.insertColumns(0, [
      PlutoColumn(
        title: l10n.info,
        field: 'info',
        type: PlutoColumnType.number(),
        enableRowChecked: outputs.items.isNotEmpty,
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
          final output = outputs.items[id]!;
          final theme = FluentTheme.of(context);

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
                  style: theme.typography.bodyStrong?.copyWith(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
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
          final output = outputs.items[id]!;
          return Text(
            output.profile,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          );
        },
      ),
      PlutoColumn(
        title: l10n.date,
        field: 'date',
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
          final output = outputs.items[id]!;
          return Text(
            DateFormat.yMd(Platform.localeName)
                .add_jm()
                .format(output.dateTime),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          );
        },
      ),
      PlutoColumn(
        title: l10n.duration,
        field: 'duration',
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
          final output = outputs.items[id]!;
          return Text(
            output.duration.format(includeMillisecond: false),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          );
        },
      ),
      PlutoColumn(
        title: l10n.status,
        field: 'status',
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
          final output = outputs.items[id]!;
          return Text(
            l10n.taskStatus(output.info.taskStatus.name),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
          );
        },
      ),
    ]);

    _manager?.appendRows(
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
