import 'package:flutter/gestures.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../utilities.dart';

class ToolNotExistDialog extends StatelessWidget {
  const ToolNotExistDialog({
    super.key,
    required this.toolName,
    required this.info,
  });

  final String toolName;
  final String info;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      title: Text(l10n.requirements),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.missingTools}: $toolName',
            style: theme.typography.bodyLarge,
          ),
          const SizedBox(height: 6),
          Text(
            info,
            style: theme.typography.body,
          ),
        ],
      ),
      actions: [
        FilledButton(
          child: Text(l10n.okay),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ParserResultDialog extends StatelessWidget {
  const ParserResultDialog({
    super.key,
    required this.failedPaths,
  });

  final List<ScanError> failedPaths;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return ContentDialog(
      title: Text(l10n.scanResult),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var failedPath in failedPaths)
            Text.rich(
              TextSpan(
                text: '${l10n.folder}: ',
                children: [
                  TextSpan(
                    text: '${failedPath.path}\n',
                    style: theme.typography.body?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('${l10n.file}:${failedPath.path}'));
                      },
                  ),
                  TextSpan(
                    text: failedPath.reason,
                    style: theme.typography.body
                        ?.copyWith(color: Colors.errorSecondaryColor),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          child: Text(l10n.okay),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
