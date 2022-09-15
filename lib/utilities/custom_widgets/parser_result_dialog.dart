import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

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
