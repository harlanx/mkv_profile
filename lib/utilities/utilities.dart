import 'package:fluent_ui/fluent_ui.dart' show AutoSuggestBoxItem;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:version/version.dart';
import 'package:http/http.dart' as http;

import '../data/app_data.dart';
import '../models/models.dart';
import 'utilities.dart';
export 'dart:io';
export 'dart:convert';
export 'package:collection/collection.dart';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'extensions.dart';
export 'shared_prefs.dart';
export 'similarity_algorithms.dart';
export 'custom_widgets/custom_widgets.dart';
export 'custom_fluent_localizations/custom_fluent_localizations.dart';

class Utilities {
  static List<AutoSuggestBoxItem<LanguageCode>> searchSorter(
    String text,
    List<AutoSuggestBoxItem<LanguageCode>> items,
  ) {
    text = text.trim();
    if (text.isEmpty) return items;

    final filtered = items.where((element) {
      return element.label.toLowerCase().contains(text.toLowerCase());
    }).toList();

    filtered.sort((a, b) =>
        (Similarity.levenshteinSync(text, a.value!.cleanName))
            .compareTo(Similarity.levenshteinSync(text, b.value!.cleanName)));

    return filtered;
  }

  static Future<AppUpdate?> checkVersion() async {
    final url =
        Uri.https('api.github.com', 'repos/harlanx/mkv_profile/releases');
    final response = await http.get(url);

    final modifiersUpdate = await _checkTextModifiersUpdate();

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final Map<String, dynamic> latestData = json.first;
      final currentVersion = Version.parse(AppData.appInfo.version);
      final latestVersion =
          Version.parse(latestData['tag_name'].replaceAll('v', ''));

      return AppUpdate(
        isOutdated: latestVersion > currentVersion,
        info: latestData,
        isModifiersOutdated: modifiersUpdate.key,
        modifiersInfo: modifiersUpdate.value ?? '',
      );
    }
    return null;
  }

  static Future<MapEntry<bool, String?>> _checkTextModifiersUpdate() async {
    String latestModifiers = '';

    if (!kDebugMode) {
      final file = await rootBundle.loadString('default_modifiers.json');
      // Re-encoding to remove any formatting (compact)
      latestModifiers = jsonEncode(jsonDecode(file));
    } else {
      final url = Uri.https('api.github.com',
          'repos/harlanx/mkv_profile/contents/default_modifiers.json');
      final response = await http.get(url, headers: {
        HttpHeaders.acceptHeader: 'application/vnd.github.VERSION.raw'
      });
      if (response.statusCode == 200) {
        // Re-encoding to remove any formatting (compact)
        latestModifiers = jsonEncode(jsonDecode(response.body));
      }
    }
    final currentModifiers = jsonEncode(AppData.profiles.items[1]!.modifiers);
    print(latestModifiers == currentModifiers);
    if (latestModifiers.isNotEmpty && (latestModifiers != currentModifiers)) {
      return MapEntry(true, latestModifiers);
    }
    return const MapEntry(false, null);
  }
}
