import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class UserProfile extends ChangeNotifier with EquatableMixin {
  static const List<String> showTitleVars = [
    '%dimension%',
    '%duration%',
    '%encoding%',
    '%frames%',
    '%height%',
    '%size%',
    '%title%',
    '%width%',
    '%year%',
  ];

  static const List<String> episodeTitleVars = [
    '%dimension%',
    '%encoding%',
    '%episode%',
    '%frames%',
    '%height%',
    '%season%',
    '%size%',
    '%title%',
    '%width%',
  ];

  static const List<String> defaultRemove = [
    r'\b\d{4}\b', // Year
    r'Season.\d+|S.\d+', // Season
    r'\d{3,4}p', //'1080p', '720p', '480p',
    '1080',
    '720',
    '480',
    r'x.\d{3}|x\d{3}', //'x.264', 'x.265', 'x264', 'x265',
    r'h.\d{3}|h\d{3}', //'h.264', //'h.265', 'h264', 'h265',
    r'[\d]+bit', //'10bit', '8bit',
    r'Part\.\d|Part\s\d', //'Part.1', 'Part.2', 'Part 1','Part 2',
    r'DDP\d+.\d+', // 'DDP2.0', 'DDP5.1', Dolby Digital Plus
    r'TrueHD.\d+.\d+', // 'TrueHD.7.1', 'TrueHD.5.1', Atmos
    'Web-Dl',
    'WEBRip',
    'BluRay',
    'AMZN',
    'BDRip',
    'Dolby',
    'Atmos',
    'DTS',
    'AAC',
    'SDR',
    'HDR',
    'HD',
    'UHD',
    'Subbed',
    'Dubbed',
  ];

  static const List<String> defaultReplace = [
    '.',
    '_',
    '-',
  ];

  static const List<String> defaultLanguages = ['und', 'eng'];

  String name;

  /// Users can use conditional variables based on the type of show the scanner detects.
  /// For Movie variables enclosed it with <M%yourVariable>
  /// For Series variables enclosed it with <S%yourVariable>
  String titleFormat;
  int id;
  String episodeTitleFormat;
  String defaultLanguage;
  List<String> languages;
  List<String> removeString;
  List<String> replaceString;
  bool useFolderName;
  bool removeLanguageTitle;
  bool defaultSdh;
  bool caseSensitive;
  // Usually for mkv files. Not implemented yet.
  //final bool removeSubtitles;
  //final bool removeTrackNames;
  //final bool removeComment;

  UserProfile({
    required this.name,
    required this.id,
    this.titleFormat = '%title%',
    this.episodeTitleFormat = '%title%',
    this.defaultLanguage = '',
    this.languages = const [],
    this.removeString = const [],
    this.replaceString = const [],
    this.useFolderName = true,
    this.removeLanguageTitle = false,
    this.defaultSdh = true,
    this.caseSensitive = false,
    // Usually for mkv files.
    //this.removeSubtitles = true,
    //this.removeTrackNames = true,
    //this.removeComment = true,
  });

  factory UserProfile.fromJson(String str) =>
      UserProfile.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  UserProfile.fromMap(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        titleFormat = json['titleFormat'],
        episodeTitleFormat = json['episodeTitleFormat'],
        defaultLanguage = json['defaultLanguage'],
        languages = List<String>.from(json['languages']),
        removeString = List<String>.from(json['removeString']),
        replaceString = List<String>.from(json['replaceString']),
        useFolderName = json['useFolderName'],
        removeLanguageTitle = json['removeLanguageTitle'],
        defaultSdh = json['defaultSdh'],
        caseSensitive = json['caseSensitive'];
  // Usually for mkv files.
  //removeSubtitles = json['removeSubtitles'],
  //removeTrackNames = json['removeTrackNames'],
  //removeComment = json['removeComment'];

  Map<String, dynamic> toMap() => {
        'name': name,
        'id': id,
        'titleFormat': titleFormat,
        'episodeTitleFormat': episodeTitleFormat,
        'defaultLanguage': defaultLanguage,
        'languages': List<String>.from(languages),
        'removeString': List<String>.from(removeString),
        'replaceString': List<String>.from(replaceString),
        'useFolderName': useFolderName,
        'removeLanguageTitle': removeLanguageTitle,
        'defaultSdh': defaultSdh,
        'caseSensitive': caseSensitive,
        // Usually for mkv files.
        //'removeSubtitles': removeSubtitles,
        //'removeTrackNames': removeTrackNames,
        //'removeComment': removeComment,
      };

  UserProfile copyWith({
    String? name,
    int? id,
    String? titleFormat,
    String? episodeTitleFormat,
    String? defaultLanguage,
    List<String>? languages,
    List<String>? removeString,
    List<String>? replaceString,
    bool? useFolderName,
    bool? removeLanguageTitle,
    bool? defaultSdh,
    bool? caseSensitive,
  }) =>
      UserProfile(
        name: name ?? this.name,
        id: id ?? this.id,
        titleFormat: titleFormat ?? this.titleFormat,
        episodeTitleFormat: episodeTitleFormat ?? this.episodeTitleFormat,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
        languages: languages ?? this.languages,
        removeString: removeString ?? this.removeString,
        replaceString: replaceString ?? this.replaceString,
        useFolderName: useFolderName ?? this.useFolderName,
        removeLanguageTitle: removeLanguageTitle ?? this.removeLanguageTitle,
        defaultSdh: defaultSdh ?? this.defaultSdh,
        caseSensitive: caseSensitive ?? this.caseSensitive,
      );

  void update({
    String? name,
    int? id,
    String? titleFormat,
    String? episodeTitleFormat,
    String? defaultLanguage,
    List<String>? languages,
    List<String>? removeString,
    List<String>? replaceString,
    bool? useFolderName,
    bool? removeLanguageTitle,
    bool? defaultSdh,
    bool? caseSensitive,
  }) {
    this.name = name ?? this.name;
    this.id = id ?? this.id;
    this.titleFormat = titleFormat ?? this.titleFormat;
    this.episodeTitleFormat = episodeTitleFormat ?? this.episodeTitleFormat;
    this.defaultLanguage = defaultLanguage ?? this.defaultLanguage;
    this.languages = languages ?? this.languages;
    this.removeString = removeString ?? this.removeString;
    this.replaceString = replaceString ?? this.replaceString;
    this.useFolderName = useFolderName ?? this.useFolderName;
    this.removeLanguageTitle = removeLanguageTitle ?? this.removeLanguageTitle;
    this.defaultSdh = defaultSdh ?? this.defaultSdh;
    this.caseSensitive = caseSensitive ?? this.caseSensitive;
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

  void updateLanguages(String iso6393, [bool add = true]) {
    if (add) {
      if (!languages.contains(iso6393)) {
        languages = List.from(languages)..add(iso6393);
      }
    } else {
      if (iso6393 == defaultLanguage) {
        updateDefaultLanguage(iso6393);
      }
      languages = List.from(languages)..remove(iso6393);
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
        id,
        titleFormat,
        episodeTitleFormat,
        defaultLanguage,
        languages,
        removeString,
        replaceString,
        useFolderName,
        removeLanguageTitle,
        defaultSdh,
        caseSensitive,
      ];
}
