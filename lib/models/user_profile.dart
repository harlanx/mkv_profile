import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';

class UserProfile extends ChangeNotifier with EquatableMixin {
  UserProfile({
    required this.id,
    required this.name,
    this.showTitleFormat = '%title%',
    this.videoTitleFormat = '%title%',
    this.audioTitleFormat = '',
    this.subtitleTitleFormat = '',
    this.defaultLanguage = '',
    this.languages = const [],
    this.defaultFlagOrder = const [],
    this.modifiers = const [],
    this.useFolderName = true,
  });

  static const List<String> showTitleVars = [
    '%duration%',
    '%encoding%',
    '%frame_rate%',
    '%height%',
    '%size%',
    '%title%',
    '%width%',
    '%year%',
  ];

  static const List<String> videoTitleVars = [
    '%language%',
    '%duration%',
    '%encoding%',
    '%episode%',
    '%frame_rate%',
    '%height%',
    '%season%',
    '%size%',
    '%title%',
    '%width%',
    '%year%',
  ];

  static const List<String> audioTitleVars = [
    '%language%',
    '%format%',
    '%bit_rate%',
    '%channels%',
    '%sampling_rate%',
    '%default%',
    '%original_language%',
    '%forced%',
    '%commentary%',
    '%hearing_impaired%',
    '%visual_impaired%',
    '%text_description%',
  ];

  static const List<String> subtitleTitleVars = [
    '%language%',
    '%format%',
    '%default%',
    '%original_language%',
    '%forced%',
    '%commentary%',
    '%hearing_impaired%',
    '%visual_impaired%',
    '%text_description%',
  ];

  static List<TextModifier> defaultModifiers = [
    TextModifier(
      id: 0,
      replaceable: [
        r'\b\d{4}\b', // Year
        r'Season.\d+|S.\d+|Season \d+|S \d+', // Season
        r'Episode.\d+|E.\d+|Episode \d+|E \d+', // Episode
        r'\d{3,4}p', //'1080p', '720p', '480p',
        '1080',
        '720',
        '480',
        r'x.\d{3}|x\d{3}', //'x.264', 'x.265', 'x264', 'x265',
        r'h.\d{3}|h\d{3}', //'h.264', //'h.265', 'h264', 'h265',
        r'[\d]+bit', //'10bit', '8bit',
        r'Part\.\d|Part\s\d', //'Part.1', 'Part.2', 'Part 1','Part 2',
        r'DD\d+.\d+|DDP\d+.\d+', // 'DDP2.0', 'DDP5.1', Dolby Digital (Plus)
        r'TrueHD.\d+.\d+', // 'TrueHD.7.1', 'TrueHD.5.1', Atmos
        r'\[(.*?)\]|\((.*?)\)', // [Anything with square brackets] (and Parentheses)
        r'\d+(?:\.\d+)?MB|\d+(?:\.\d+)?GB', // 200MB, 150.20MB, 2GB, 2.5GB
        r'\bM{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\b', // Roman numerals
        'HEVC',
        'WEB',
        'NF',
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
        'Complete',
        'RARBG',
        'YIFY',
        'ION265',
        'ION10',
        'GalaxyRG',
        'XEBEC'
      ],
      replacement: '',
    ),
    TextModifier(
      id: 1,
      replaceable: [
        '.',
        '_',
        '-',
      ],
      replacement: ' ',
    ),
  ];

  static const List<String> defaultLanguages = ['und', 'eng'];

  int id;
  String name;
  String showTitleFormat;
  String videoTitleFormat;
  String audioTitleFormat;
  String subtitleTitleFormat;
  String defaultLanguage;
  List<String> languages;
  List<String> defaultFlagOrder;
  List<TextModifier> modifiers;
  bool useFolderName;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      showTitleFormat: json['showTitleFormat'],
      videoTitleFormat: json['videoTitleFormat'],
      audioTitleFormat: json['audioTitleFormat'],
      subtitleTitleFormat: json['subtitleTitleFormat'],
      defaultLanguage: json['defaultLanguage'],
      languages: List<String>.from(json['languages']),
      defaultFlagOrder: List<String>.from(json['defaultFlagOrder']),
      modifiers: List<TextModifier>.from(
          json['modifiers'].map((e) => TextModifier.fromJson(e))),
      useFolderName: json['useFolderName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'showTitleFormat': showTitleFormat,
        'videoTitleFormat': videoTitleFormat,
        'audioTitleFormat': audioTitleFormat,
        'subtitleTitleFormat': subtitleTitleFormat,
        'defaultLanguage': defaultLanguage,
        'languages': languages,
        'defaultFlagOrder': defaultFlagOrder,
        'modifiers': modifiers,
        'useFolderName': useFolderName,
      };

  UserProfile copyWith({
    String? name,
    int? id,
    String? showTitleFormat,
    String? videoTitleFormat,
    String? defaultLanguage,
    List<String>? languages,
    List<String>? defaultFlagOrder,
    List<TextModifier>? modifiers,
    bool? useFolderName,
    bool? defaultSdh,
  }) =>
      UserProfile(
        name: name ?? this.name,
        id: id ?? this.id,
        showTitleFormat: showTitleFormat ?? this.showTitleFormat,
        videoTitleFormat: videoTitleFormat ?? this.videoTitleFormat,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
        languages: languages ?? this.languages,
        defaultFlagOrder: defaultFlagOrder ?? this.defaultFlagOrder,
        modifiers: modifiers ?? this.modifiers,
        useFolderName: useFolderName ?? this.useFolderName,
      );

  void update({
    String? name,
    int? id,
    String? showTitleFormat,
    String? videoTitleFormat,
    String? audioTitleFormat,
    String? subtitleTitleFormat,
    String? defaultLanguage,
    List<String>? languages,
    List<String>? defaultFlagOrder,
    List<TextModifier>? modifiers,
    bool? useFolderName,
  }) {
    this.name = name ?? this.name;
    this.id = id ?? this.id;
    this.showTitleFormat = showTitleFormat ?? this.showTitleFormat;
    this.videoTitleFormat = videoTitleFormat ?? this.videoTitleFormat;
    this.audioTitleFormat = audioTitleFormat ?? this.audioTitleFormat;
    this.subtitleTitleFormat = subtitleTitleFormat ?? this.subtitleTitleFormat;
    this.defaultLanguage = defaultLanguage ?? this.defaultLanguage;
    this.languages = languages ?? this.languages;
    this.defaultFlagOrder = defaultFlagOrder ?? this.defaultFlagOrder;
    this.modifiers = modifiers ?? this.modifiers;
    this.useFolderName = useFolderName ?? this.useFolderName;
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
    final languagesCopy = List<String>.from(languages);
    final item = languagesCopy.removeAt(oldIndex);
    languages = languagesCopy..insert(newIndex, item);
    notifyListeners();
  }

  void updateFlagOrder(String flagName, [bool add = true]) {
    if (add) {
      if (!defaultFlagOrder.contains(flagName)) {
        defaultFlagOrder = List.from(defaultFlagOrder)..add(flagName);
      }
    } else {
      defaultFlagOrder = List.from(defaultFlagOrder)..remove(flagName);
    }
    notifyListeners();
  }

  void reorderFlagOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final flagOrderCopy = List<String>.from(defaultFlagOrder);
    final item = flagOrderCopy.removeAt(oldIndex);
    defaultFlagOrder = flagOrderCopy..insert(newIndex, item);
    notifyListeners();
  }

  void addModifier(TextModifier modifier) {
    modifiers.add(modifier);
    notifyListeners();
  }

  void deleteModifier(int id) {
    modifiers.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  @override
  List<Object> get props => [
        name,
        id,
        showTitleFormat,
        videoTitleFormat,
        defaultLanguage,
        languages,
        defaultFlagOrder,
        modifiers,
        useFolderName,
      ];
}

class TextModifier {
  TextModifier({
    required this.id,
    required this.replacement,
    required this.replaceable,
    this.caseSensitive = false,
  });

  int id;
  String replacement;
  List<String> replaceable;
  bool caseSensitive;

  String get replaceablePreview => replaceable.join('  •  ');

  String get replacementPreview {
    String preview = '';
    if (replacement.isEmpty) {
      preview = 'Remove String';
    } else if (replacement.trim().isEmpty) {
      preview = 'Replace with White Space';
    } else {
      preview = replacement;
    }
    return preview;
  }

  TextModifier copyWith({
    int? id,
    String? replacement,
    List<String>? replaceable,
    bool? caseSensitive,
  }) =>
      TextModifier(
        id: id ?? this.id,
        replacement: replacement ?? this.replacement,
        replaceable: replaceable ?? this.replaceable,
        caseSensitive: caseSensitive ?? this.caseSensitive,
      );

  void update({
    int? id,
    String? replacement,
    List<String>? replaceable,
    bool? caseSensitive,
  }) {
    this.id = id ?? this.id;
    this.replacement = replacement ?? this.replacement;
    this.replaceable = replaceable ?? this.replaceable;
    this.caseSensitive = caseSensitive ?? this.caseSensitive;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'replaceable': replaceable,
        'replacement': replacement,
      };

  factory TextModifier.fromJson(Map<String, dynamic> json) {
    return TextModifier(
      id: json['id'],
      replaceable: List<String>.from((json['replaceable'])),
      replacement: json['replacement'],
    );
  }
}
