import 'package:fluent_ui/fluent_ui.dart';

class CustomExpander extends StatefulWidget {
  /// Creates a fluent-styled expander.
  const CustomExpander({
    super.key,
    this.leading,
    required this.header,
    required this.content,
    this.levelPadding = 8.0,
    this.contentPadding = const EdgeInsets.all(16),
    this.icon,
    this.trailing,
    this.animationCurve,
    this.animationDuration,
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = false,
    this.onStateChanged,
    this.headerHeight = 48.0,
    this.headerBackgroundColor,
    this.contentBackgroundColor,
    this.headerShape,
  });

  /// The leading widget.
  ///
  /// See also:
  ///
  ///  * [Icon], used to display graphic content
  ///  * [RadioButton], used to select an exclusive option from a set of options
  ///  * [Checkbox], used to select or deselect items within a list
  final Widget? leading;

  /// The expander header
  ///
  /// Usually a [Text] widget
  final Widget header;

  /// The expander content
  ///
  /// You can use complex, interactive UI as the content of the
  /// Expander, including nested Expander controls in the content
  /// of a parent Expander as shown here.
  ///
  /// ![Expander Nested Content](https://docs.microsoft.com/en-us/windows/apps/design/controls/images/expander-nested.png)
  final Widget content;

  final double levelPadding;

  final EdgeInsets contentPadding;

  /// The icon of the toggle button.
  final Widget? icon;

  /// The trailing widget. It's positioned at the right of [header]
  /// and at the left of [icon].
  ///
  /// See also:
  ///
  ///  * [ToggleSwitch]
  final Widget? trailing;

  /// The expand-collapse animation duration.
  ///
  /// If null, defaults to [FluentThemeData.fastAnimationDuration]
  final Duration? animationDuration;

  /// The expand-collapse animation curve.
  ///
  /// If null, defaults to [FluentThemeData.animationCurve]
  final Curve? animationCurve;

  /// The expand direction. Defaults to [ExpanderDirection.down]
  final ExpanderDirection direction;

  /// Whether the [CustomExpander] is initially expanded. Defaults to `false`
  final bool initiallyExpanded;

  /// A callback called when the current state is changed. `true` when
  /// open and `false` when closed.
  final ValueChanged<bool>? onStateChanged;

  /// The height of the header.
  ///
  /// Defaults to 48.0
  final double headerHeight;

  /// The background color of the header.
  final ButtonState<Color>? headerBackgroundColor;

  /// The content color of the header
  final Color? contentBackgroundColor;

  /// The shape of the header
  final ShapeBuilder? headerShape;

  @override
  State<CustomExpander> createState() => CustomExpanderState();
}

class CustomExpanderState extends State<CustomExpander>
    with SingleTickerProviderStateMixin {
  late FluentThemeData _theme;

  late bool _isExpanded;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    if (_isExpanded != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _isExpanded = PageStorage.of(context).readState(context) as bool? ??
        widget.initiallyExpanded;
    if (_isExpanded == true) {
      _controller.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = FluentTheme.of(context);
  }

  void _handlePressed() {
    if (_isExpanded) {
      _controller.animateTo(
        0.0,
        duration: widget.animationDuration ?? _theme.mediumAnimationDuration,
        curve: widget.animationCurve ?? _theme.animationCurve,
      );
      _isExpanded = false;
    } else {
      _controller.animateTo(
        1.0,
        duration: widget.animationDuration ?? _theme.mediumAnimationDuration,
      );
      _isExpanded = true;
    }
    PageStorage.of(context).writeState(context, _isExpanded);
    widget.onStateChanged?.call(_isExpanded);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Duration expanderAnimationDuration = Duration(milliseconds: 70);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);
    final children = [
      // HEADER
      HoverButton(
        onPressed: _handlePressed,
        hitTestBehavior: HitTestBehavior.deferToChild,
        builder: (context, states) {
          return Container(
            height: widget.headerHeight,
            decoration: ShapeDecoration(
              color: () {
                if (widget.headerBackgroundColor != null) {
                  return widget.headerBackgroundColor!.resolve(states);
                } else {
                  if (states.isDisabled) {
                    return theme.resources.subtleFillColorDisabled;
                  } else if (states.isPressing) {
                    return theme.resources.subtleFillColorTertiary;
                  } else if (states.isHovering) {
                    return theme.resources.subtleFillColorSecondary;
                  } else {
                    return theme.resources.subtleFillColorTransparent;
                  }
                }
              }(),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: EdgeInsetsDirectional.only(start: widget.levelPadding),
                child: FocusBorder(
                  focused: states.isFocused,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    alignment: AlignmentDirectional.center,
                    child: widget.icon ??
                        RotationTransition(
                          turns: Tween<double>(
                            begin: 0,
                            end: 0.5,
                          ).animate(CurvedAnimation(
                            parent: _controller,
                            curve: Interval(
                              0.5,
                              1.0,
                              curve: widget.animationCurve ??
                                  _theme.animationCurve,
                            ),
                          )),
                          child: AnimatedSlide(
                            duration: theme.fastAnimationDuration,
                            curve: Curves.easeInCirc,
                            offset: states.isPressing
                                ? const Offset(0, 0.1)
                                : Offset.zero,
                            child: Icon(
                              () {
                                if (_isDown) {
                                  return _isExpanded
                                      ? FluentIcons.chevron_up
                                      : FluentIcons.chevron_right;
                                } else {
                                  return _isExpanded
                                      ? FluentIcons.chevron_down
                                      : FluentIcons.chevron_right;
                                }
                              }(),
                              size: 8.0,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: widget.leading!,
                ),
              Expanded(child: widget.header),
              if (widget.trailing != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 20.0),
                  child: widget.trailing!,
                ),
            ]),
          );
        },
      ),
      SizeTransition(
        sizeFactor: CurvedAnimation(
          curve: Interval(
            0.0,
            0.5,
            curve: widget.animationCurve ?? _theme.animationCurve,
          ),
          parent: _controller,
        ),
        child: Container(
          width: double.infinity,
          padding: widget.contentPadding,
          decoration: BoxDecoration(
            color: widget.contentBackgroundColor ??
                theme.resources.cardBackgroundFillColorSecondary,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4.0), bottom: Radius.circular(4.0)),
          ),
          child: widget.content,
        ),
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _isDown ? children : children.reversed.toList(),
    );
  }
}
