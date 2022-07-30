import 'dart:convert';

import 'package:flutter/services.dart';

class LanguageCodes {
  late final Set<LanguageCode> _items;
  Set<LanguageCode> get items => _items;

  LanguageCodes(this._items);

  static Future<LanguageCodes> load() async {
    String rawJson = await rootBundle.loadString('assets/json/iso_639-2_codes.json');
    final objSet = Set<LanguageCode>.from((json.decode(rawJson) as Iterable).map((e) => LanguageCode.fromMap(e)));
    return LanguageCodes(objSet);
  }

  LanguageCode alpha2ToCode(String alpha2) => items.firstWhere((element) => element.alpha2 == alpha2);
  LanguageCode englishToCode(String english) => items.firstWhere((element) => element.english == english);
  LanguageCode findWhereOrDefault(String text, String defaultValue) =>
      items.firstWhere((element) => element.english.contains(text), orElse: () => alpha2ToCode(defaultValue));
}

class LanguageCode {
  final String english;
  final List<String> englishSplit;
  final String alpha2;
  final String alpha3B;

  LanguageCode({
    required this.english,
    required this.alpha2,
    required this.alpha3B,
  }) : englishSplit = english.split('; ');

  factory LanguageCode.fromJson(String str) => LanguageCode.fromMap(json.decode(str));

  factory LanguageCode.fromMap(Map<String, dynamic> json) {
    return LanguageCode(
      english: json["English"],
      alpha2: json["alpha2"],
      alpha3B: json["alpha3-b"],
    );
  }
}
