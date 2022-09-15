import 'package:fluent_ui/fluent_ui.dart';

class CommandBarCombobox<T> extends CommandBarItem {
  CommandBarCombobox({
    Key? key,
    this.icon,
    this.label,
    this.onChanged,
    required this.items,
    this.value,
    this.isExpanded = false,
    this.width,
  }) : super(key: key);

  /// The icon to show in the button (primary area) or menu (secondary area)
  final Widget? icon;

  /// The label to show in the button (primary area) or menu (secondary area)
  final Widget? label;

  /// The callback when an item is selected from the drop down list
  final ValueChanged<T?>? onChanged;

  /// The items to show in the drop down list
  final List<ComboBoxItem<T>>? items;

  /// The value of the currently selected [ComboboxItem].
  ///
  /// If [value] is null and the button is enabled, [placeholder] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [placeholder] will be displayed
  /// if it is non-null.
  final T? value;

  /// Set the combobox's inner contents to horizontally fill its parent.
  ///
  /// By default this button's inner width is the minimum size of its contents.
  /// If [isExpanded] is true, the inner width is expanded to fill its
  /// surrounding container.
  final bool isExpanded;

  /// Ovrrides [isExpanded] behavior and resize [CommandBarCombobox] to the width specified.
  final double? width;

  @override
  Widget build(BuildContext context, CommandBarItemDisplayMode displayMode) {
    final showIcon = (icon != null);
    final showLabel = (label != null && !showIcon);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          IconTheme.merge(
            data: const IconThemeData(size: 16),
            child: icon!,
          ),
        if (showIcon && showLabel) const SizedBox(width: 10),
        if (showLabel) label!,
        if (showIcon || showLabel) const SizedBox(width: 6),
        SizedBox(
          width: width,
          child: ComboBox<T>(
            onChanged: onChanged,
            value: value,
            items: items,
            isExpanded: isExpanded,
          ),
        ),
      ],
    );
  }
}
