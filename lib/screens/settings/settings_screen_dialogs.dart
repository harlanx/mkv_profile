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
    return ContentDialog(
      title: Text(AppLocalizations.of(context).createNewProfile),
      content: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${AppLocalizations.of(context).template}: '),
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
          child: Text(AppLocalizations.of(context).cancel),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text(AppLocalizations.of(context).continueStr),
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
      title: Text(AppLocalizations.of(context).deleteItem(title)),
      content: Text(AppLocalizations.of(context).deleteItemConfirmation(item)),
      actions: [
        Button(
          child: Text(AppLocalizations.of(context).cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(AppLocalizations.of(context).yes),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

class NewUpdateDialog extends StatelessWidget {
  const NewUpdateDialog(
    this.response, {
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic> response;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(AppLocalizations.of(context).checkUpdate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        //shrinkWrap: true,
        children: [
          Text(AppLocalizations.of(context)
              .newVersionAvailable(response['tag_name'])),
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
          child: Text(AppLocalizations.of(context).okay),
          onPressed: () => Navigator.pop(context, false),
        ),
        FilledButton(
          child: Text(AppLocalizations.of(context).download),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
