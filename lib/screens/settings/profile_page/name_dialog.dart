import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/models/models.dart';

class NameDialog extends StatelessWidget {
  NameDialog({
    Key? key,
    required this.profile,
    required this.controller,
  }) : super(key: key);

  final UserProfile profile;
  final TextEditingController controller;
  final nameForm = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Profile Name'),
      content: TextFormBox(
        key: nameForm,
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Name cannot be empty';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          if (nameForm.currentState!.validate()) {
            Navigator.pop(context, controller.text);
          }
        },
      ),
      actions: [
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            if (nameForm.currentState!.validate()) {
              Navigator.pop(context, controller.text);
            }
          },
        ),
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
