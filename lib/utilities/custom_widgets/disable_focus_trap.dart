import 'package:fluent_ui/fluent_ui.dart';

/// Flutter introduced a FocusTrap which is intended to remove focus for elements
/// like TextFields. This is problematic because it causes focus to be lost in
/// for certain Focus widgets. We use this widget to disable this behavior.
///
/// Usage: wrap your entire application in this.
///
/// Some use cases:
///   - Clicking out doesn't always mean we focus what was clicked on.
///     We may want to give up focus or focus to the next element up.
///   - We may not always want to lose focus at all. For example, an autocomplete
///     widget or a formatting toolbar for a rich text editor.
///   - This behavior can vary depending on the situation.
///
/// Relevant issue:
/// https://github.com/flutter/flutter/issues/86972
class DisableFocusTrap extends StatefulWidget {
  const DisableFocusTrap({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _DisableFocusTrapState();
}

class _DisableFocusTrapState extends State<DisableFocusTrap> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode =
        FocusManager.instance.primaryFocus ?? FocusManager.instance.rootScope;
    FocusManager.instance.addListener(_onFocusNodeChanged);
  }

  @override
  void dispose() {
    super.dispose();
    FocusManager.instance.removeListener(_onFocusNodeChanged);
  }

  @override
  Widget build(BuildContext context) {
    return FocusTrapArea(focusNode: focusNode, child: widget.child);
  }

  void _onFocusNodeChanged() {
    final newFocusNode =
        FocusManager.instance.primaryFocus ?? FocusManager.instance.rootScope;
    if (newFocusNode != focusNode) {
      setState(() {
        focusNode = newFocusNode;
      });
    }
  }
}