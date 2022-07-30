import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:merge2mkv/utilities/utilities.dart';

/// Use the [SpinButtonPlacementMode] property to enable buttons that can be
/// clicked to [increment] or [decrement] the [value] in the [NumberBox]
enum SpinButtonPlacementMode {
  /// A SpinButton with single button that can popup the up and down buttons.
  compact,

  /// A SpinButton with up and down buttons directly placed with the text field.
  inline,
}

/// My own implementation of [NumberBox].
/// An existing PR is still in draft, however it does not fit my needs.
/// See link below for future reference.
/// https://github.com/bdlukaa/fluent_ui/pull/212
class NumberBox extends StatefulWidget {
  const NumberBox({
    Key? key,
    this.focusNode,
    required this.initialValue,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.onChanged,
    this.placementMode = SpinButtonPlacementMode.inline,
  })  : assert(
          initialValue > max || initialValue < min || step > max || step < min,
          'Value and Step must be less than max and greater than min',
        ),
        super(key: key);

  final FocusNode? focusNode;
  final int initialValue;
  final int min;
  final int max;
  final int step;
  final ValueChanged<BigInt?>? onChanged;
  final SpinButtonPlacementMode placementMode;

  @override
  State<StatefulWidget> createState() => _NumberBoxState();
}

class _NumberBoxState extends State<NumberBox> {
  final layerLink = LayerLink();
  late final _controller =
      TextEditingController(text: widget.initialValue.toString());
  late final _focusNode = widget.focusNode ?? FocusNode();
  late final _buttonSize = FluentTheme.of(context).iconTheme.size!;
  bool _canIncrease = true;
  bool _canDecrease = true;
  OverlayEntry? _menuOverlay;

  @override
  void initState() {
    super.initState();
    _updateButtons(BigInt.from(widget.initialValue));

    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        if (BigInt.parse(_controller.text) >= BigInt.from(widget.min) ||
            BigInt.parse(_controller.text) <= BigInt.from(widget.max)) {
          _updateButtons(BigInt.parse(_controller.text));
          widget.onChanged?.call(BigInt.parse(_controller.text));
        }
      }
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_menuOverlay?.mounted ?? false) {
          _menuOverlay!.remove();
          _menuOverlay = null;
        }
        _controller.text =
            (BigInt.tryParse(_controller.text) ?? BigInt.from(widget.min))
                .toInt()
                .clamp(widget.min, widget.max)
                .toString();
        widget.onChanged?.call(BigInt.parse(_controller.text));
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
        child: TextBox(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: FluentTheme.of(context).typography.body,
          suffix: _spinButton(),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (BigInt.parse(value) <= BigInt.from(widget.max)) {
                _updateButtons(BigInt.parse(value));
                widget.onChanged?.call(BigInt.parse(value));
              }
            }
          },
        ),
      );

  Widget _spinButton() {
    switch (widget.placementMode) {
      case SpinButtonPlacementMode.compact:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DisableFocusTrap(
              child: Visibility(
                visible: _focusNode.hasFocus,
                child: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: () => _updateValue(null),
                ),
              ),
            ),
            DisableFocusTrap(
              child: CompositedTransformTarget(
                link: layerLink,
                child: IconButton(
                  icon: const Icon(
                    FluentIcons.chevron_unfold10,
                  ),
                  onPressed: () => _showCompactMenu(),
                ),
              ),
            ),
          ],
        );
      case SpinButtonPlacementMode.inline:
      default:
        return DisableFocusTrap(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: _focusNode.hasFocus,
                child: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: () => _updateValue(null),
                ),
              ),
              _NumberBoxMenuItem(
                key: const Key('increment'),
                function: _increaseValue,
                iconData: FluentIcons.chevron_up,
                buttonSize: _buttonSize * 2,
              ),
              _NumberBoxMenuItem(
                key: const Key('decrement'),
                function: _decreaseValue,
                iconData: FluentIcons.chevron_down,
                buttonSize: _buttonSize * 2,
              ),
            ],
          ),
        );
    }
  }

  void _showCompactMenu() {
    final overlay = Overlay.of(context, debugRequiredFor: widget)!;
    final buttonSize = _buttonSize * 2.0;
    _menuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        child: Center(
          child: _NumberBoxMenu(
            layerLink: layerLink,
            increment: _increaseValue,
            decrement: _decreaseValue,
            buttonSize: buttonSize,
          ),
        ),
      ),
    );
    _focusNode.requestFocus();
    overlay.insert(_menuOverlay!);
  }

  void _updateValue(BigInt? value) {
    if (value == null) {
      _controller.clear();
    } else {
      _controller
        ..text = value.toString()
        ..selection = TextSelection.collapsed(offset: value.toString().length);
      widget.onChanged?.call(value);
    }
  }

  bool _increaseValue() {
    if (_canIncrease) {
      _updateValue(
          (BigInt.tryParse(_controller.text) ?? BigInt.from(widget.min)) +
              BigInt.from(widget.step));
      return true;
    } else {
      return false;
    }
  }

  bool _decreaseValue() {
    if (_canDecrease) {
      _updateValue(
          (BigInt.tryParse(_controller.text) ?? BigInt.from(widget.min + 1)) -
              BigInt.from(widget.step));
      return true;
    } else {
      return false;
    }
  }

  void _updateButtons(BigInt value) {
    _canIncrease = value < BigInt.from(widget.max);
    _canDecrease = value > BigInt.from(widget.min);
  }
}

class _NumberBoxMenu extends StatelessWidget {
  const _NumberBoxMenu({
    Key? key,
    required this.layerLink,
    required this.increment,
    required this.decrement,
    required this.buttonSize,
  }) : super(key: key);

  final LayerLink layerLink;
  final double buttonSize;
  final bool Function() increment, decrement;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: layerLink,
      showWhenUnlinked: false,
      followerAnchor: Alignment.centerRight,
      targetAnchor: Alignment.centerRight,
      offset: Offset(buttonSize / 1.5, 0),
      child: IntrinsicWidth(
        child: Mica(
          elevation: 3,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberBoxMenuItem(
                  key: const Key('increment'),
                  function: increment,
                  iconData: FluentIcons.chevron_up,
                  buttonSize: buttonSize,
                ),
                _NumberBoxMenuItem(
                  key: const Key('decrement'),
                  function: decrement,
                  iconData: FluentIcons.chevron_down,
                  buttonSize: buttonSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBoxMenuItem extends StatefulWidget {
  const _NumberBoxMenuItem({
    Key? key,
    required this.function,
    required this.iconData,
    required this.buttonSize,
  }) : super(key: key);

  final bool Function() function;
  final IconData iconData;
  final double buttonSize;

  @override
  State<_NumberBoxMenuItem> createState() => _NumberBoxMenuItemState();
}

class _NumberBoxMenuItemState extends State<_NumberBoxMenuItem> {
  late final _theme = FluentTheme.of(context);
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      focusEnabled: false,
      onPressed: () => widget.function(),
      onLongPressStart: () {
        _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
          if (!widget.function()) {
            _timer?.cancel();
          }
        });
      },
      onLongPressEnd: () {
        _timer?.cancel();
      },
      builder: (context, states) {
        Color? bgColor, fgColor;
        if (states.isDisabled) {
          bgColor = ButtonThemeData.buttonColor(context, states);
        } else {
          bgColor = ButtonThemeData.uncheckedInputColor(
            _theme,
            states,
            transparentWhenNone: true,
          );
        }
        if (states.isDisabled) {
          fgColor = _theme.resources.textFillColorDisabled;
        }

        return Container(
          height: widget.buttonSize,
          width: widget.buttonSize,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Icon(
            widget.iconData,
            color: fgColor,
            size: 16,
          ),
        );
      },
    );
  }
}
