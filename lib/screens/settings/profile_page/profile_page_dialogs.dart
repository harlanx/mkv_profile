import 'package:fluent_ui/fluent_ui.dart';

import '../../../models/models.dart';
import '../../../utilities/utilities.dart';

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
      title: Text(AppLocalizations.of(context).profileName),
      content: TextFormBox(
        key: nameForm,
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context).nameCannotBeEmpty;
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
          child: Text(AppLocalizations.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(AppLocalizations.of(context).save),
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
          Text(AppLocalizations.of(context).replacementHint),
          TextBox(
            controller: replacementCtrl,
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context).replaceablesHint),
          ValueListenableBuilder(
              valueListenable: caseSensitive,
              builder: (context, value, _) {
                return Checkbox(
                  content:
                      Text(AppLocalizations.of(context).caseSensitivityHint),
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
          child: Text(AppLocalizations.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(AppLocalizations.of(context).save),
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
