import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/screens/home/normal_page/normal_page.dart';
import 'package:merge2mkv/screens/home/compact_page/compact_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsNotifier>(
      builder: (context, appSettings, child) {
        switch (appSettings.viewMode) {
          case ViewMode.normal:
            return const NormalPage();
          case ViewMode.compact:
            return CompactPage();
        }
      },
    );
  }
}
