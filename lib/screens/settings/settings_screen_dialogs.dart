import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../models/models.dart';
import '../../utilities/utilities.dart';

class CreateProfileDialog extends StatelessWidget {
  CreateProfileDialog({
    super.key,
    required this.templates,
  });
  final List<UserProfile> templates;

  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      title: Text(l10n.createNewProfile),
      content: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.template}: '),
              ComboBox<int>(
                value: value,
                onChanged: (choice) {
                  if (choice != null) selected.value = choice;
                },
                items: List.from(
                  templates.map(
                    (e) => ComboBoxItem(
                      value: e.id,
                      child: Text(e.name),
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
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(l10n.continueStr),
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
    super.key,
  });

  final String title;
  final String item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      title: Text(l10n.deleteItem(title)),
      content: Text(l10n.deleteItemConfirmation(item)),
      actions: [
        Button(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(l10n.yes),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

class NewUpdateDialog extends StatelessWidget {
  const NewUpdateDialog(
    this.response, {
    super.key,
  });

  final Map<String, dynamic> response;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      constraints: kDefaultContentDialogConstraints.copyWith(maxWidth: 480),
      title: Text(l10n.checkUpdate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        //shrinkWrap: true,
        children: [
          Text(l10n.newVersionAvailable(response['tag_name'])),
          Flexible(
            child: Markdown(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              data: response['body'],
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubWeb.blockSyntaxes,
                [
                  ...md.ExtensionSet.gitHubWeb.inlineSyntaxes,
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(l10n.okay),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(l10n.download),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
