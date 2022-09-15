import 'package:diacritic/diacritic.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class LanguageCodes {
  late final Set<LanguageCode> _items;
  Set<LanguageCode> get items => _items;

  LanguageCodes(this._items);

  static Future<LanguageCodes> load() async {
    // Data from mkvmerge using --list-languages then parsed and encoded into json.
    String rawJson =
        await rootBundle.loadString('assets/json/Language_Code_Min.json');
    final codes = Set<LanguageCode>.from(
        (json.decode(rawJson) as Iterable).map((e) => LanguageCode.fromMap(e)));
    var modifiedCodes = (codes.toList()
          ..insert(
              0,
              LanguageCode(
                  name: "Undefined", normalName: "Undefined", iso6393: "und")))
        .toSet();
    return LanguageCodes(modifiedCodes);
  }

  // Still not sure whether allow user to change algorithm since they can manually change the wrong ones.
  /// Identify the LanguageCode using various similarty algoritms
  /// 1 = Jaro-Wrinkler Distance
  /// 2 = Levenshtein Distance
  /// 3 = nGram Cosine Similarity
  LanguageCode identifyTitle(String text, {int algo = 1}) {
    // Only retains letters
    var clean = RegExp(r'[^A-Za-z]+');
    text = text.replaceAll(clean, '');
    switch (algo) {
      case 1:
        // For string similarity between short strings and where order of characters matter
        // Longer process but has the most best result.
        return _jaroWinklerMatch(text) ??
            _items.firstWhere((c) => c.iso6393 == 'und');
      case 2:
        // For string similarity between short strings and where order of characters doesn't matter
        // Shorter process but has the least best result.
        return _levenshteinMatch(text) ??
            _items.firstWhere((c) => c.iso6393 == 'und');
      default:
        // For string similarty between long strings and where order of characters matter
        // Longer process but has the most best result for longer strings such as phrases and sentences.
        return _bigramCosineSimilarityMatch(text) ??
            _items.firstWhere((c) => c.iso6393 == 'und');
    }
  }

  LanguageCode? _jaroWinklerMatch(String input) {
    LanguageCode? bestMatch;
    var highestScore = 0.0;

    for (var code in _items) {
      var nameScore = Similarity.jaroWinklerDistance(input,
          code.normalName.replaceAll(RegExp(r'\s?\([^)]*\)'), '').trim());
      var iso6393Score = Similarity.jaroWinklerDistance(input, code.iso6393);
      var iso6392Score = code.iso6392 != null
          ? Similarity.jaroWinklerDistance(input, code.iso6392!)
          : 0.0;
      var iso6391Score = code.iso6391 != null
          ? Similarity.jaroWinklerDistance(input, code.iso6391!)
          : 0.0;

      var score = (nameScore + iso6393Score + iso6392Score + iso6391Score) / 4;

      if (score > highestScore) {
        bestMatch = code;
        highestScore = score;
      }
    }

    return bestMatch;
  }

  LanguageCode? _levenshteinMatch(String input) {
    LanguageCode? closestMatch;
    var minDistance = double.infinity;
    for (var code in _items) {
      var nameDistance = Similarity.levenshteinDistance(input,
          code.normalName.replaceAll(RegExp(r'\s?\([^)]*\)'), '').trim());
      var iso6393Distance = Similarity.levenshteinDistance(input, code.iso6393);
      var iso6392Distance = code.iso6392 != null
          ? Similarity.levenshteinDistance(input, code.iso6392!)
          : double.infinity;
      var iso6391Distance = code.iso6391 != null
          ? Similarity.levenshteinDistance(input, code.iso6391!)
          : double.infinity;
      var distance = [
        nameDistance,
        iso6393Distance,
        iso6392Distance,
        iso6391Distance
      ].reduce(math.min);
      if (distance < minDistance) {
        minDistance = distance.toDouble();
        closestMatch = code;
      }
    }
    return minDistance < double.infinity ? closestMatch : null;
  }

  LanguageCode? _bigramCosineSimilarityMatch(String input) {
    LanguageCode? bestMatch;
    var highestScore = 0.0;

    for (var code in _items) {
      var nameScore = Similarity.nGramCosineSimilarity(
        input,
        code.normalName.replaceAll(RegExp(r'\s?\([^)]*\)'), '').trim(),
      );
      var iso6393Score = Similarity.nGramCosineSimilarity(input, code.iso6393);
      var iso6392Score = code.iso6392 != null
          ? Similarity.nGramCosineSimilarity(input, code.iso6392!)
          : 0.0;
      var iso6391Score = code.iso6391 != null
          ? Similarity.nGramCosineSimilarity(input, code.iso6391!)
          : 0.0;

      var score = (nameScore + iso6393Score + iso6392Score + iso6391Score) / 4;

      if (score > highestScore) {
        bestMatch = code;
        highestScore = score;
      }
    }

    return bestMatch;
  }
}

class LanguageCode {
  final String name;
  final String normalName;
  String iso6393;
  String? iso6392;
  String? iso6391;

  LanguageCode({
    required this.name,
    required this.normalName,
    required this.iso6393,
    this.iso6392,
    this.iso6391,
  });

  String get fullName {
    var title = '$name ($iso6393';
    if (iso6392 != null) {
      title += ', $iso6392';
    }
    if (iso6391 != null) {
      title += ', $iso6391';
    }
    title += ')';
    return title;
  }

  factory LanguageCode.fromJson(String str) =>
      LanguageCode.fromMap(json.decode(str));

  factory LanguageCode.fromMap(Map<String, dynamic> json) {
    return LanguageCode(
      name: json['name'],
      normalName: removeDiacritics(json['name']),
      iso6393: json['iso639-3'],
      iso6392: json['iso639-2'],
      iso6391: json['iso639-1'],
    );
  }
}
