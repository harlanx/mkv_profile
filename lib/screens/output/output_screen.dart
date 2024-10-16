import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Material;
import 'package:fluent_ui/fluent_ui.dart';

import 'package:multi_split_view/multi_split_view.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:provider/provider.dart';

import '../../data/app_data.dart';
import '../../models/models.dart';
import '../../utilities/utilities.dart';

class OutputsScreen extends StatefulWidget {
  const OutputsScreen({super.key});

  @override
  State<OutputsScreen> createState() => OutputsScreenState();
}

class OutputsScreenState extends State<OutputsScreen>
    with WidgetsBindingObserver {
  late final outputs = context.watch<OutputNotifier>();
  late final PlutoGridStateManager _manager;
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];
  final _verticalCtrl = ScrollController(),
      _horizontalCtrl = ScrollController();
  final _selectedOutput = ValueNotifier<OutputBasic?>(null);

  late final _splitViewCtrl = MultiSplitViewController(
    areas: [
      Area(
        flex: 3,
        builder: (context, area) {
          return SizedBox.expand(
            child: Material(
              color: Colors.transparent,
              child: PlutoGrid(
                mode: PlutoGridMode.selectWithOneTap,
                configuration:
                    _plutoConfig(context, AppData.appSettings.themeMode),
                onLoaded: (event) {
                  _manager = event.stateManager;
                },
                onSelected: (event) {
                  _selectedOutput.value =
                      outputs.items[event.cell?.row.cells.values.first.value];
                },
                onRowChecked: (event) {
                  if (event.row != null && event.rowIdx != null) {
                    if (event.isChecked!) {
                      outputs.addSelected({event.row!.cells['id']!.value});
                    } else {
                      outputs.removeSelected({event.row!.cells['id']!.value});
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
          );
        },
      ),
      _outputLogArea,
    ],
  );

  late final _outputLogArea = Area(
    flex: 2,
    builder: (context, area) {
      return ValueListenableBuilder(
        valueListenable: _selectedOutput,
        builder: (context, output, child) {
          if (output == null) return const SizedBox.shrink();
          return Container(
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
                    child: SelectableText(output.info.log),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      if (mounted) fetchData();
    });
    if (_selectedOutput.value == null) {
      _splitViewCtrl.removeAreaAt(1);
    }
    _selectedOutput.addListener(() {
      if (_selectedOutput.value == null) {
        _splitViewCtrl.removeAreaAt(1);
      } else {
        if (_splitViewCtrl.areasCount != 2) {
          _splitViewCtrl.addArea(_outputLogArea);
        }
      }
    });
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
                            _selectedOutput.value = null;
                            outputs.remove(_selectedIds);
                            outputs.removeSelected(_selectedIds);
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
      _manager.checkedRows.map<int>((e) => e.cells.values.first.value).toSet();

  void fetchData() {
    final l10n = AppLocalizations.of(context);
    _manager.removeAllRows();
    _manager.removeColumns(_manager.columns);
    _manager.insertColumns(0, [
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        hide: true,
      ),
      PlutoColumn(
        title: l10n.info,
        field: 'info',
        type: PlutoColumnType.text(),
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
          final output = rendererContext.cell.value as OutputBasic;
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
        type: PlutoColumnType.text(),
        readOnly: true,
        enableSorting: true,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: l10n.date,
        field: 'date',
        type: PlutoColumnType.date(
          format: 'MM/dd/yyyy HH:mm:ss',
        ),
        readOnly: true,
        enableSorting: true,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
      ),
      PlutoColumn(
        title: l10n.duration,
        field: 'duration',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableSorting: true,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
        formatter: (value) {
          final duration = Duration(seconds: value);
          return duration.format(includeMillisecond: false);
        },
      ),
      PlutoColumn(
        title: l10n.status,
        field: 'status',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableSorting: true,
        enableColumnDrag: false,
        enableEditingMode: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        enableHideColumnMenuItem: false,
        enableContextMenu: false,
        formatter: (value) => (value as String).capitalized,
      ),
    ]);
    // Initially sorted by added sequence.
    // final sorted = Map.fromEntries(outputs.items.entries.sorted((a, b) => b.key.compareTo(a.key)));
    // Just reverse the list for better speed.
    final sorted = Map.fromEntries(outputs.items.entries.toList().reversed);
    _manager.appendRows(
      List.from(
        sorted.entries.map(
          (e) {
            final int id = e.key;
            final output = outputs.items[id]!;
            return PlutoRow(
              checked: outputs.selected.contains(e.key),
              cells: {
                'id': PlutoCell(value: e.key),
                'info': PlutoCell(value: output),
                'profile': PlutoCell(value: output.profile),
                'date': PlutoCell(value: output.dateTime),
                'duration': PlutoCell(value: output.duration.inSeconds),
                'status': PlutoCell(value: output.info.taskStatus.name),
              },
            );
          },
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
          activatedColor: theme.resources.cardStrokeColorDefaultSolid,
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
        activatedColor: theme.resources.cardStrokeColorDefault,
        activatedBorderColor:
            theme.accentColor.defaultBrushFor(theme.brightness),
        gridBackgroundColor: Colors.transparent,
        gridBorderColor: Colors.transparent,
      ),
    );
  }
}
