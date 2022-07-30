import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class UserProfile extends ChangeNotifier with EquatableMixin {
  static const List<String> replaceWithSpace = [
    '.',
    '_',
    '-',
  ];
  static const List<String> removeString = [
    r'\d{3,4}p', //'1080p', '720p', '480p',
    '1080',
    '720',
    '480',
    r'x.\d{3}|x\d{3}', //'x.264', 'x.265', 'x264', 'x265',
    r'h.\d{3}|h\d{3}', //'h.264', //'h.265', 'h264', 'h265',
    r'[\d]+bit', //'10bit', '8bit',
    r'Part\.\d|Part\s\d', //'Part.1', 'Part.2', 'Part 1','Part 2',
    'WEBRip',
    'BluRay',
  ];

  static const List<String> defaultLanguages = ['en'];

  String name;
  String defaultLanguage;
  List<String> languages;
  List<String> stringToSpace;
  List<String> stringToRemove;
  bool useFolderName;
  bool defaultSdh;
  bool includeYear;
  bool caseSensitive;
  bool whiteSpaceTrim;
  // Usually for mkv files. Not implemented yet.
  //final bool removeSubtitles;
  //final bool removeTrackNames;
  //final bool removeComment;

  UserProfile({
    this.name = '',
    this.defaultLanguage = '',
    this.languages = const [],
    this.stringToSpace = const [],
    this.stringToRemove = const [],
    this.useFolderName = true,
    this.defaultSdh = true,
    this.includeYear = true,
    this.caseSensitive = false,
    this.whiteSpaceTrim = true,
    // Usually for mkv files.
    //this.removeSubtitles = true,
    //this.removeTrackNames = true,
    //this.removeComment = true,
  });

  factory UserProfile.fromJson(String str) => UserProfile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  UserProfile.fromMap(Map<String, dynamic> json)
      : name = json['name'],
        defaultLanguage = json['defaultLanguage'],
        languages = List<String>.from(json['languages']),
        stringToSpace = List<String>.from(json['stringToSpace']),
        stringToRemove = List<String>.from(json['stringToRemove']),
        useFolderName = json['useFolderName'],
        defaultSdh = json['defaultSdh'],
        includeYear = json['includeYear'],
        caseSensitive = json['caseSensitive'],
        whiteSpaceTrim = json['whiteSpaceTrim'];
  // Usually for mkv files.
  //removeSubtitles = json['removeSubtitles'],
  //removeTrackNames = json['removeTrackNames'],
  //removeComment = json['removeComment'];

  Map<String, dynamic> toMap() => {
        'name': name,
        'defaultLanguage': defaultLanguage,
        'languages': List<String>.from(languages),
        'stringToSpace': List<String>.from(stringToSpace),
        'stringToRemove': List<String>.from(stringToRemove),
        'useFolderName': useFolderName,
        'defaultSdh': defaultSdh,
        'includeYear': includeYear,
        'caseSensitive': caseSensitive,
        'whiteSpaceTrim': whiteSpaceTrim,
        // Usually for mkv files.
        //'removeSubtitles': removeSubtitles,
        //'removeTrackNames': removeTrackNames,
        //'removeComment': removeComment,
      };

  UserProfile copyWith({
    String? name,
    String? defaultLanguage,
    List<String>? languages,
    List<String>? stringToSpace,
    List<String>? stringToRemove,
    bool? useFolderName,
    bool? defaultSdh,
    bool? includeYear,
    bool? caseSensitive,
    bool? whiteSpaceTrim,
  }) =>
      UserProfile(
        name: name ?? this.name,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
        languages: languages ?? this.languages,
        stringToSpace: stringToSpace ?? this.stringToSpace,
        stringToRemove: stringToRemove ?? this.stringToRemove,
        useFolderName: useFolderName ?? this.useFolderName,
        defaultSdh: defaultSdh ?? this.defaultSdh,
        includeYear: includeYear ?? this.includeYear,
        caseSensitive: caseSensitive ?? this.caseSensitive,
        whiteSpaceTrim: whiteSpaceTrim ?? this.whiteSpaceTrim,
      );

  void updateAll({
    String? name,
    String? defaultLanguage,
    List<String>? languages,
    List<String>? stringToSpace,
    List<String>? stringToRemove,
    bool? useFolderName,
    bool? defaultSdh,
    bool? includeYear,
    bool? caseSensitive,
    bool? whiteSpaceTrim,
  }) {
    this.name = name ?? this.name;
    this.defaultLanguage = defaultLanguage ?? this.defaultLanguage;
    this.languages = languages ?? this.languages;
    this.stringToSpace = stringToSpace ?? this.stringToSpace;
    this.stringToRemove = stringToRemove ?? this.stringToRemove;
    this.useFolderName = useFolderName ?? this.useFolderName;
    this.defaultSdh = defaultSdh ?? this.defaultSdh;
    this.includeYear = includeYear ?? this.includeYear;
    this.caseSensitive = caseSensitive ?? this.caseSensitive;
    this.whiteSpaceTrim = whiteSpaceTrim ?? this.whiteSpaceTrim;
    notifyListeners();
  }

  void updateDefaultLanguage(String language) {
    if (defaultLanguage == language) {
      defaultLanguage = '';
    } else {
      defaultLanguage = language;
    }
    notifyListeners();
  }

  void updateLanguages(String language, [bool add = true]) {
    if (add) {
      if (!languages.contains(language)) languages = List.from(languages)..add(language);
    } else {
      languages = List.from(languages)..remove(language);
    }
    notifyListeners();
  }

  void reorderLanguages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    List<String> languagesCopy = List.from(languages);
    final item = languagesCopy.removeAt(oldIndex);
    languages = languagesCopy..insert(newIndex, item);
    notifyListeners();
  }

  @override
  List<Object> get props => [
        name,
        defaultLanguage,
        languages,
        stringToSpace,
        stringToRemove,
        useFolderName,
        defaultSdh,
        includeYear,
        caseSensitive,
        whiteSpaceTrim,
      ];
}
