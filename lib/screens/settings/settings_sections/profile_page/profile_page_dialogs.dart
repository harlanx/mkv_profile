import 'package:fluent_ui/fluent_ui.dart';

import '../../../../models/models.dart';
import '../../../../utilities/utilities.dart';

class NameDialog extends StatelessWidget {
  NameDialog({
    super.key,
    required this.profile,
  });

  final UserProfile profile;
  late final controller = TextEditingController(text: profile.name);
  final nameForm = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      title: Text(l10n.profileName),
      content: ListView(
        shrinkWrap: true,
        children: [
          TextFormBox(
            key: nameForm,
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.nameCannotBeEmpty;
              }
              return null;
            },
            onFieldSubmitted: (value) {
              if (nameForm.currentState!.validate()) {
                Navigator.pop(context, controller.text);
              }
            },
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(l10n.save),
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
      editModifier = sourceModifier.copyWith(
        replacement: '',
        replaceables: [],
        caseSensitive: false,
      );
    } else {
      editModifier = sourceModifier;
    }
  }

  final UserProfile profile;
  final TextModifier sourceModifier;
  late final TextModifier editModifier;
  final bool isNew;

  late final replacementCtrl =
      TextEditingController(text: editModifier.replacement);
  late final replaceablesCtrl =
      TextEditingController(text: editModifier.replaceables.join('\n'));
  late final caseSensitive = ValueNotifier(editModifier.caseSensitive);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      title: Text(l10n.textModifier),
      content: ListView(
        shrinkWrap: true,
        children: [
          Text(l10n.replacementHint),
          TextBox(
            controller: replacementCtrl,
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          Text(l10n.replaceablesHint),
          ValueListenableBuilder(
              valueListenable: caseSensitive,
              builder: (context, value, _) {
                return Checkbox(
                  content: Text(l10n.caseSensitivityHint),
                  checked: value,
                  onChanged: (val) {
                    if (val != null) {
                      caseSensitive.value = val;
                    }
                  },
                );
              }),
          TextBox(
            controller: replaceablesCtrl,
            maxLines: null,
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(l10n.save),
          onPressed: () {
            if (isNew) {
              profile.addModifier(
                TextModifier(
                  id: DateTime.now().millisecondsSinceEpoch +
                      editModifier.hashCode,
                  caseSensitive: caseSensitive.value,
                  replacement: replacementCtrl.text,
                  replaceables: replaceablesCtrl.text.split('\n'),
                ),
              );
            } else {
              editModifier.update(
                caseSensitive: caseSensitive.value,
                replacement: replacementCtrl.text,
                replaceables: replaceablesCtrl.text.split('\n'),
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
