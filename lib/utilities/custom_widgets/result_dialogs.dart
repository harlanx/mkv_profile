import 'package:flutter/gestures.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';

class ToolNotExistDialog extends StatelessWidget {
  const ToolNotExistDialog({
    Key? key,
    required this.toolName,
    required this.info,
  }) : super(key: key);

  final String toolName;
  final String info;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Requirements'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missing Tool: $toolName',
            style: FluentTheme.of(context).typography.bodyLarge,
          ),
          const SizedBox(height: 6),
          Text(
            info,
            style: FluentTheme.of(context).typography.body,
          ),
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('OK'),
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
    Key? key,
    required this.failedPaths,
  }) : super(key: key);

  final List<ScanError> failedPaths;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Scan Result'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var failedPath in failedPaths)
            Text.rich(
              TextSpan(
                text: 'Folder: ',
                children: [
                  TextSpan(
                    text: '${failedPath.path}\n',
                    style: FluentTheme.of(context).typography.body?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('file:${failedPath.path}'));
                      },
                  ),
                  TextSpan(
                    text: failedPath.reason,
                    style: FluentTheme.of(context)
                        .typography
                        .body
                        ?.copyWith(color: Colors.errorSecondaryColor),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
