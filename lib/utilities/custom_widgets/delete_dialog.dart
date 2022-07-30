import 'package:fluent_ui/fluent_ui.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog(
    this.title,
    this.item, {
    Key? key,
  }) : super(key: key);

  final String title;
  final String item;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text('Delete $title'),
      content: Text('Are you sure you want to delete $item?'),
      actions: [
        FilledButton(
          child: const Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        ),
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
  }
}
