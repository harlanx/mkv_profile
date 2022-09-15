import 'package:fluent_ui/fluent_ui.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final List<int> shades = [100, 200, 300, 400, 500, 600, 700, 800, 900];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Test Screen'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.center,
          primaryItems: [
            CommandBarButton(
              label: const Text('Start'),
              onPressed: () async {},
            ),
          ],
        ),
      ),
      bottomBar: CommandBar(
        primaryItems: [
          CommandBarButton(
            label: const Text('Stop'),
            onPressed: () {},
          ),
        ],
      ),
      content: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [],
          ),
        ),
      ),
    );
  }
}
