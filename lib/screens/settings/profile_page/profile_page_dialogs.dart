import 'package:fluent_ui/fluent_ui.dart';

import '../../../models/models.dart';

class NameDialog extends StatelessWidget {
  NameDialog({
    Key? key,
    required this.profile,
  }) : super(key: key);

  final UserProfile profile;
  late final controller = TextEditingController(text: profile.name);
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
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            if (nameForm.currentState!.validate()) {
              Navigator.pop(context, controller.text);
            }
          },
        ),
      ],
    );
  }
}

class TextModifierDialog extends StatelessWidget {
  TextModifierDialog({
    super.key,
    required this.profile,
    required this.sourceModifier,
    required this.isNew,
  }) {
    if (isNew) {
      modifier = sourceModifier.copyWith(
        replacement: '',
        replaceable: [],
        caseSensitive: false,
      );
    } else {
      modifier = sourceModifier;
    }
  }

  final UserProfile profile;
  final TextModifier sourceModifier;
  late final TextModifier modifier;
  final bool isNew;

  late final replacementCtrl =
      TextEditingController(text: modifier.replacement);
  late final replaceableCtrl =
      TextEditingController(text: modifier.replaceable.join('\n'));
  late final caseSensitive = ValueNotifier(modifier.caseSensitive);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Text Modifier'),
      content: ListView(
        shrinkWrap: true,
        children: [
          const Text('Replacement. Regex is allowed. (Single entry)'),
          TextBox(
            controller: replacementCtrl,
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          const Text('Replaceables. Regex is allowed. (Entry per line).'),
          ValueListenableBuilder(
              valueListenable: caseSensitive,
              builder: (context, value, _) {
                return Checkbox(
                  content: const Text(
                      'Enable case sensitivity for the specified strings.'),
                  checked: value,
                  onChanged: (val) {
                    if (val != null) {
                      caseSensitive.value = val;
                    }
                  },
                );
              }),
          TextBox(
            controller: replaceableCtrl,
            maxLines: null,
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Save'),
          onPressed: () {
            if (isNew) {
              profile.addModifier(
                TextModifier(
                  id: DateTime.now().millisecondsSinceEpoch + modifier.hashCode,
                  caseSensitive: caseSensitive.value,
                  replacement: replacementCtrl.text,
                  replaceable: replaceableCtrl.text.split('\n'),
                ),
              );
            } else {
              sourceModifier.update(
                caseSensitive: caseSensitive.value,
                replacement: replacementCtrl.text,
                replaceable: replaceableCtrl.text.split('\n'),
              );
              profile.update();
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
