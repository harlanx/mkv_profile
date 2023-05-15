import 'package:fluent_ui/fluent_ui.dart';

import '../../models/models.dart';

class CreateProfileDialog extends StatelessWidget {
  CreateProfileDialog({
    super.key,
    required this.templates,
  });
  final Map<int, UserProfile> templates;

  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Create New Profile'),
      content: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Template: '),
              ComboBox<int>(
                value: value,
                onChanged: (choice) {
                  if (choice != null) selected.value = choice;
                },
                items: List.from(
                  templates.entries.map(
                    (e) => ComboBoxItem(
                      value: e.key,
                      child: Text(e.value.name),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Continue'),
          onPressed: () {
            Navigator.pop(context, selected.value);
          },
        ),
      ],
    );
  }
}

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
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: const Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
