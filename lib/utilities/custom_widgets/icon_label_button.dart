import 'package:fluent_ui/fluent_ui.dart';

class IconLabelButton extends StatelessWidget {
  const IconLabelButton({
    super.key,
    required this.iconData,
    this.alignIconRight = false,
    required this.label,
    this.onPressed,
  });
  final IconData iconData;
  final String label;
  final VoidCallback? onPressed;
  final bool alignIconRight;

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!alignIconRight) Icon(iconData),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 6),
          if (alignIconRight) Icon(iconData),
        ],
      ),
    );
  }
}
