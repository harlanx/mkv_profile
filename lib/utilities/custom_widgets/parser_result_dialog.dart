import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

class ParserResultDialog extends StatelessWidget {
  const ParserResultDialog({
    Key? key,
    required this.failedPaths,
  }) : super(key: key);

  final List<FailedPath> failedPaths;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Parser Info'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var failedPath in failedPaths)
            Text.rich(
              TextSpan(
                text: '${failedPath.reason}\n',
                style: FluentTheme.of(context)
                    .typography
                    .body
                    ?.copyWith(color: Colors.errorPrimaryColor),
                children: [
                  TextSpan(
                    text: '${failedPath.path}\n\n',
                    style: FluentTheme.of(context).typography.body?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(failedPath.path));
                      },
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
