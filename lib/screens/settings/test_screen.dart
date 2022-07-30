import 'package:fluent_ui/fluent_ui.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final List<int> shades = [100, 200, 300, 400, 500, 600, 700, 800, 900];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Test Screen'),
        commandBar: CommandBar(
          overflowBehavior: CommandBarOverflowBehavior.noWrap,
          primaryItems: [
            CommandBarButton(
              label: const Text('Test'),
              onPressed: () {},
            ),
          ],
        ),
      ),
      bottomBar: CommandBar(
        primaryItems: [
          CommandBarButton(
            label: const Text('Test'),
            onPressed: () {},
          ),
        ],
      ),
      content: const Placeholder(),
    );
  }
}
