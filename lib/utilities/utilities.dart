import 'package:fluent_ui/fluent_ui.dart' show AutoSuggestBoxItem;

import '../models/models.dart';
import 'similarity_algorithms.dart';

export 'dart:io';
export 'dart:convert';
export 'package:collection/collection.dart';
export 'extensions.dart';
export 'shared_prefs.dart';
export 'similarity_algorithms.dart';
export 'custom_widgets/custom_widgets.dart';

class Utilities {
  static List<AutoSuggestBoxItem<LanguageCode>> searchSorter(
    String text,
    List<AutoSuggestBoxItem<LanguageCode>> items,
  ) {
    text = text.trim();
    if (text.isEmpty) return items;

    var filtered = items.where((element) {
      return element.label.toLowerCase().contains(text.toLowerCase());
    }).toList();

    filtered.sort((a, b) =>
        (Similarity.levenshteinSync(text, a.value!.cleanName))
            .compareTo(Similarity.levenshteinSync(text, b.value!.cleanName)));

    return filtered;
  }
}
