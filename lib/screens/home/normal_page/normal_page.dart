import 'package:fluent_ui/fluent_ui.dart';

class NormalPage extends StatefulWidget {
  const NormalPage({Key? key}) : super(key: key);

  @override
  State<NormalPage> createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> {
  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      header: PageHeader(
        title: Text('Normal'),
      ),
      content: Placeholder(),
    );
  }
}
