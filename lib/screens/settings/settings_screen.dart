import 'package:fluent_ui/fluent_ui.dart';

import '../../utilities/utilities.dart';
import 'settings_sections/preferences_section.dart';
import 'settings_sections/personalization_section.dart';
import 'settings_sections/misc_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScaffoldPage.scrollable(
      key: const PageStorageKey('Settings'),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      header: PageHeader(title: Text(l10n.settings)),
      children: const [
        PreferencesSection(),
        PersonalizationSection(),
        MiscSection(),
      ],
    );
  }
}
