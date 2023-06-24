import 'dart:math' as math;
import 'package:flutter/services.dart';

import 'package:diacritic/diacritic.dart';

import '../utilities/utilities.dart';

class LanguageCodes {
  late final Set<LanguageCode> _items;
  Set<LanguageCode> get items => _items;

  Future<void> load() async {
    // Data from mkvmerge using --list-languages then parsed and encoded into json.
    final rawJson =
        await rootBundle.loadString('assets/json/Language_Code_Min.json');
    final codes = Set<LanguageCode>.from(
        (jsonDecode(rawJson) as Iterable).map((e) => LanguageCode.fromMap(e)));
    _items = codes;
  }

  LanguageCode get defaultCode =>
      _items.singleWhere((code) => code.name == 'Undetermined');

  Future<LanguageCode> identify([String? isoCode, String? text]) async {
    if (isoCode == null && text == null) {
      return defaultCode;
    }
    LanguageCode result;
    result = identifyByCode(isoCode);
    if (result == defaultCode && text != null) {
      result = await identifyByText(text);
    }
    return result;
  }

  LanguageCode identifyByCode(String? isoCode, [String? isoCodeExtra]) {
    LanguageCode? result;
    if (isoCode == null) {
      return defaultCode;
    }
    result ??= _items.firstWhereOrNull((code) => code.iso6393 == isoCode);
    result ??= _items.firstWhereOrNull((code) => code.iso6392 == isoCode);
    result ??= _items.firstWhereOrNull((code) => code.iso6391 == isoCode);
    result ??= _items.firstWhereOrNull((code) => code.iso6393 == isoCodeExtra);
    result ??= _items.firstWhereOrNull((code) => code.iso6392 == isoCodeExtra);
    result ??= _items.firstWhereOrNull((code) => code.iso6391 == isoCodeExtra);
    result ??= defaultCode;
    return result;
  }

  // Still not sure whether allow user to change algorithm since they can manually change the wrong ones.
  /// Identify the LanguageCode by text using various similarty algoritms
  /// 1 = Jaro-Wrinkler Distance;
  /// 2 = Levenshtein Distance;
  /// 3 = nGram Cosine Similarity
  Future<LanguageCode> identifyByText(String text, {int algo = 1}) async {
    // Only retains letters
    text = text.replaceAll(RegExp(r'[^A-Za-z]+'), '');
    switch (algo) {
      case 1:
        return await _levenshteinMatch(text) ?? defaultCode;
      case 2:
        return await _jaroWinklerMatch(text) ?? defaultCode;
      default:
        return await _bigramCosineMatch(text) ?? defaultCode;
    }
  }

  Future<LanguageCode?> _jaroWinklerMatch(String input) async {
    LanguageCode? bestMatch;
    var highestScore = 0.0;
    for (var code in _items) {
      final nameScore = await Similarity.jaroWinkler(
          input, code.cleanName.replaceAll(RegExp(r'\s?\([^)]*\)'), '').trim());
      final iso6393Score = await Similarity.jaroWinkler(input, code.iso6393);
      final iso6392Score = code.iso6392 != null
          ? await Similarity.jaroWinkler(input, code.iso6392!)
          : 0.0;
      final iso6391Score = code.iso6391 != null
          ? await Similarity.jaroWinkler(input, code.iso6391!)
          : 0.0;

      final score =
          (nameScore + iso6393Score + iso6392Score + iso6391Score) / 4;

      if (score > highestScore) {
        bestMatch = code;
        highestScore = score;
      }
    }

    return bestMatch;
  }

  Future<LanguageCode?> _levenshteinMatch(String input) async {
    LanguageCode? closestMatch;
    var minDistance = double.infinity;
    for (var code in _items) {
      final nameDistance = await Similarity.levenshtein(
          input, code.cleanName.replaceAll(RegExp(r'\s?\([^)]*\)'), '').trim());
      final iso6393Distance = await Similarity.levenshtein(input, code.iso6393);
      final iso6392Distance = code.iso6392 != null
          ? await Similarity.levenshtein(input, code.iso6392!)
          : double.infinity;
      final iso6391Distance = code.iso6391 != null
          ? await Similarity.levenshtein(input, code.iso6391!)
          : double.infinity;
      final distance = [
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

  Future<LanguageCode?> _bigramCosineMatch(String input) async {
    LanguageCode? bestMatch;
    var highestScore = 0.0;

    for (var code in _items) {
      final nameScore = await Similarity.nGramCosine(
        input,
        code.cleanName.replaceAll(RegExp(r'\s?\([^)]*\)'), '').trim(),
      );
      final iso6393Score = await Similarity.nGramCosine(input, code.iso6393);
      final iso6392Score = code.iso6392 != null
          ? await Similarity.nGramCosine(input, code.iso6392!)
          : 0.0;
      final iso6391Score = code.iso6391 != null
          ? await Similarity.nGramCosine(input, code.iso6391!)
          : 0.0;

      final score =
          (nameScore + iso6393Score + iso6392Score + iso6391Score) / 4;

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
  final String cleanName;
  String iso6393;
  String? iso6392;
  String? iso6391;

  LanguageCode({
    required this.name,
    required this.iso6393,
    this.iso6392,
    this.iso6391,
  }) : cleanName = removeDiacritics(name);

  bool get warn => iso6392 == null;

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

  String get fullCleanName {
    var title = '$cleanName ($iso6393';
    if (iso6392 != null) {
      title += ', $iso6392';
    }
    if (iso6391 != null) {
      title += ', $iso6391';
    }
    title += ')';
    return title;
  }

  factory LanguageCode.fromJson(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return LanguageCode(
      name: json['name'],
      iso6393: json['iso639-3'],
      iso6392: json['iso639-2'],
      iso6391: json['iso639-1'],
    );
  }

  factory LanguageCode.fromMap(Map<String, dynamic> json) {
    return LanguageCode(
      name: json['name'],
      iso6393: json['iso639-3'],
      iso6392: json['iso639-2'],
      iso6391: json['iso639-1'],
    );
  }
}
