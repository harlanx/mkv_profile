import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';

class UserProfile extends ChangeNotifier with EquatableMixin {
  UserProfile({
    required this.id,
    required this.name,
    this.showTitleFormat = '',
    this.videoTitleFormat = '',
    this.audioTitleFormat = '',
    this.subtitleTitleFormat = '',
    this.videoExtraOptions = '',
    this.audioExtraOptions = '',
    this.subtitleExtraOptions = '',
    this.attachmentExtraOptions = '',
    this.defaultAudioLanguage = '',
    this.audioLanguages = const [],
    this.defaultSubtitleLanguage = '',
    this.subtitleLanguages = const [],
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
    '%show_title%',
    '%width%',
    '%year%',
  ];

  static const List<String> videoTitleVars = [
    '%language%',
    '%duration%',
    '%encoding%',
    '%episode_number%',
    '%format%',
    '%frame_rate%',
    '%height%',
    '%season_number%',
    '%size%',
    '%show_title%',
    '%episode_title%',
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
    // Recommended to put the longest text at the start
    // and put regex at the end for better result
    TextModifier(
      id: 0,
      replaceables: [
        r'\bClean.Cam\b',
        r'\bTELESYNC\b',
        r'\bComplete\b',
        r'\bSubbed\b',
        r'\bDubbed\b',
        r'\bWEBRip\b',
        r'\bCAMRip\b',
        r'\bBluRay\b',
        r'\bWeb-Dl\b',
        r'\bBDRip\b',
        r'\bHDCam\b',
        r'\bDolby\b',
        r'\bAtmos\b',
        r'\bHEVC\b',
        r'\bDTS\b',
        r'\bAAC\b',
        r'\bSDR\b',
        r'\bHDR\b',
        r'\bWEB\b',
        r'\bUHD\b',
        r'\bRip\b',
        r'\bCAM\b',
        r'\bSDb',
        r'\bHDb',
        r'\bTS\b',
      ],
      replacement: '',
    ),
    TextModifier(
      id: 1,
      replaceables: [
        r'\b\d{4}\b', // Year
        r'Season.\d+|S.\d+|Season \d+|S \d+', // Season
        r'Episode.\d+|E.\d+|Episode \d+|E \d+|\b\d{2}\b', // Episode
        r'\d{3,4}p', //'1080p', '720p', '480p',
        r'x.\d{3}|x\d{3}', //'x.264', 'x.265', 'x264', 'x265',
        r'h.\d{3}|h\d{3}', //'h.264', //'h.265', 'h264', 'h265',
        r'[\d]+bit', //'10bit', '8bit',
        r'Part\.\d|Part\s\d', //'Part.1', 'Part.2', 'Part 1','Part 2',
        r'DD\d+.\d+|DDP\d+.\d+', // 'DDP2.0', 'DDP5.1', Dolby Digital (Plus)
        r'TrueHD.\d+.\d+', // 'TrueHD.7.1', 'TrueHD.5.1', Atmos
        r'\[(.*?)\]|\((.*?)\)', // [Anything with square brackets] (and Parentheses)
        r'\d+(?:\.\d+)?MB|\d+(?:\.\d+)?GB', // 200MB, 150.20MB, 2GB, 2.5GB
        r'\bM{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\b', // Roman numerals
      ],
      replacement: '',
    ),
    TextModifier(
      id: 2,
      replaceables: [
        r'\bTORRENTGALAXY\b',
        r'\bGalaxyRG265\b',
        r'\bSUNSCREEN\b',
        r'\bKONTRAST\b',
        r'\bGalaxyRG\b',
        r'\bGalaxyTV\b',
        r'\bPROTON\b',
        r'\bMeGusta\b',
        r'\bInfinity\b',
        r'\b\bELiTEb',
        r'\bION265\b',
        r'\bION10\b',
        r'\bXEBEC\b',
        r'\bPCOK\b',
        r'\bFLUX\b',
        r'\bRARBG\b',
        r'\bMiNX\b',
        r'\bZMNT\b',
        r'\bYIFY\b',
        r'\bAMZN\b',
        r'\bTGx\b',
        r'\bNF\b',
      ],
      replacement: '',
    ),
    TextModifier(
      id: 3,
      replaceables: [
        '.',
        '_',
        '-',
      ],
      replacement: ' ',
    ),
  ];

  static const List<String> defaultLanguages = [
    'und',
    'eng',
    'chi',
    'hin',
    'spa',
    'fre',
    'ara',
    'ben',
    'por',
    'rus',
    'ind',
    'jpn',
  ];

  int id;
  String name;
  String showTitleFormat;
  String videoTitleFormat;
  String audioTitleFormat;
  String subtitleTitleFormat;
  String videoExtraOptions;
  String audioExtraOptions;
  String subtitleExtraOptions;
  String attachmentExtraOptions;
  String defaultAudioLanguage;
  List<String> audioLanguages;
  String defaultSubtitleLanguage;
  List<String> subtitleLanguages;
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
      videoExtraOptions: json['videoExtraOptions'],
      audioExtraOptions: json['audioExtraOptions'],
      subtitleExtraOptions: json['subtitleExtraOptions'],
      attachmentExtraOptions: json['attachmentExtraOptions'],
      defaultAudioLanguage: json['defaultAudioLanguage'],
      audioLanguages: List<String>.from(json['audioLanguages']),
      defaultSubtitleLanguage: json['defaultSubtitleLanguage'],
      subtitleLanguages: List<String>.from(json['subtitleLanguages']),
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
        'videoExtraOptions': videoExtraOptions,
        'audioExtraOptions': audioExtraOptions,
        'subtitleExtraOptions': subtitleExtraOptions,
        'attachmentExtraOptions': attachmentExtraOptions,
        'defaultAudioLanguage': defaultAudioLanguage,
        'audioLanguages': audioLanguages,
        'defaultSubtitleLanguage': defaultSubtitleLanguage,
        'subtitleLanguages': subtitleLanguages,
        'defaultFlagOrder': defaultFlagOrder,
        'modifiers': modifiers,
        'useFolderName': useFolderName,
      };

  UserProfile copyWith({
    int? id,
    String? name,
    String? showTitleFormat,
    String? videoTitleFormat,
    String? audioTitleFormat,
    String? subtitleTitleFormat,
    String? videoExtraOptions,
    String? audioExtraOptions,
    String? subtitleExtraOptions,
    String? attachmentExtraOptions,
    String? defaultAudioLanguage,
    List<String>? audioLanguages,
    String? defaultSubtitleLanguage,
    List<String>? subtitleLanguages,
    List<String>? defaultFlagOrder,
    List<TextModifier>? modifiers,
    bool? useFolderName,
  }) =>
      UserProfile(
        name: name ?? this.name,
        id: id ?? this.id,
        showTitleFormat: showTitleFormat ?? this.showTitleFormat,
        videoTitleFormat: videoTitleFormat ?? this.videoTitleFormat,
        audioTitleFormat: audioTitleFormat ?? this.audioTitleFormat,
        subtitleTitleFormat: subtitleTitleFormat ?? this.subtitleTitleFormat,
        videoExtraOptions: videoExtraOptions ?? this.videoExtraOptions,
        audioExtraOptions: audioExtraOptions ?? this.audioExtraOptions,
        subtitleExtraOptions: subtitleExtraOptions ?? this.subtitleExtraOptions,
        attachmentExtraOptions:
            attachmentExtraOptions ?? this.attachmentExtraOptions,
        defaultAudioLanguage: defaultAudioLanguage ?? this.defaultAudioLanguage,
        audioLanguages: audioLanguages ?? this.audioLanguages,
        defaultSubtitleLanguage:
            defaultSubtitleLanguage ?? this.defaultSubtitleLanguage,
        subtitleLanguages:
            subtitleLanguages ?? List.from(this.subtitleLanguages),
        defaultFlagOrder: defaultFlagOrder ?? List.from(this.defaultFlagOrder),
        modifiers: modifiers ?? List.from(this.modifiers),
        useFolderName: useFolderName ?? this.useFolderName,
      );

  void update({
    String? name,
    int? id,
    String? showTitleFormat,
    String? videoTitleFormat,
    String? audioTitleFormat,
    String? subtitleTitleFormat,
    String? videoExtraOptions,
    String? audioExtraOptions,
    String? subtitleExtraOptions,
    String? attachmentExtraOptions,
    String? defaultAudioLanguage,
    List<String>? audioLanguages,
    String? defaultSubtitleLanguage,
    List<String>? subtitleLanguages,
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
    this.videoExtraOptions = videoExtraOptions ?? this.videoExtraOptions;
    this.audioExtraOptions = audioExtraOptions ?? this.audioExtraOptions;
    this.subtitleExtraOptions =
        subtitleExtraOptions ?? this.subtitleExtraOptions;
    this.attachmentExtraOptions;
    attachmentExtraOptions ?? this.attachmentExtraOptions;
    this.defaultAudioLanguage =
        defaultAudioLanguage ?? this.defaultAudioLanguage;
    this.audioLanguages = audioLanguages ?? this.audioLanguages;
    this.defaultSubtitleLanguage =
        defaultSubtitleLanguage ?? this.defaultSubtitleLanguage;
    this.subtitleLanguages = subtitleLanguages ?? this.subtitleLanguages;
    this.defaultFlagOrder = defaultFlagOrder ?? this.defaultFlagOrder;
    this.modifiers = modifiers ?? this.modifiers;
    this.useFolderName = useFolderName ?? this.useFolderName;
    notifyListeners();
  }

  void updateDefaultAudioLanguage(String language) {
    if (defaultAudioLanguage == language) {
      defaultAudioLanguage = '';
    } else {
      defaultAudioLanguage = language;
    }
    notifyListeners();
  }

  void updateAudioLanguages(String iso6393, [bool add = true]) {
    if (add) {
      if (!audioLanguages.contains(iso6393)) {
        audioLanguages = List.from(audioLanguages)..add(iso6393);
      }
    } else {
      if (iso6393 == defaultAudioLanguage) {
        updateDefaultAudioLanguage(iso6393);
      }
      audioLanguages = List.from(audioLanguages)..remove(iso6393);
    }
    notifyListeners();
  }

  void reorderAudioLanguages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final languagesCopy = List<String>.from(audioLanguages);
    final item = languagesCopy.removeAt(oldIndex);
    audioLanguages = languagesCopy..insert(newIndex, item);
    notifyListeners();
  }

  void updateDefaultSubtitleLanguage(String language) {
    if (defaultSubtitleLanguage == language) {
      defaultSubtitleLanguage = '';
    } else {
      defaultSubtitleLanguage = language;
    }
    notifyListeners();
  }

  void updateSubtitleLanguages(String iso6393, [bool add = true]) {
    if (add) {
      if (!subtitleLanguages.contains(iso6393)) {
        subtitleLanguages = List.from(subtitleLanguages)..add(iso6393);
      }
    } else {
      if (iso6393 == defaultSubtitleLanguage) {
        updateDefaultSubtitleLanguage(iso6393);
      }
      subtitleLanguages = List.from(subtitleLanguages)..remove(iso6393);
    }
    notifyListeners();
  }

  void reorderSubtitleLanguages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final languagesCopy = List<String>.from(subtitleLanguages);
    final item = languagesCopy.removeAt(oldIndex);
    subtitleLanguages = languagesCopy..insert(newIndex, item);
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
        id,
        name,
        showTitleFormat,
        videoTitleFormat,
        audioTitleFormat,
        subtitleTitleFormat,
        videoExtraOptions,
        audioExtraOptions,
        subtitleExtraOptions,
        attachmentExtraOptions,
        defaultAudioLanguage,
        audioLanguages,
        defaultSubtitleLanguage,
        subtitleLanguages,
        defaultFlagOrder,
        modifiers,
        useFolderName,
      ];
}

class TextModifier {
  TextModifier({
    required this.id,
    required this.replacement,
    required this.replaceables,
    this.caseSensitive = false,
  });

  int id;
  String replacement;
  List<String> replaceables;
  bool caseSensitive;

  String get replaceablesPreview => replaceables.join('  •  ');

  String get replacementPreview {
    String preview = '';
    if (replacement.isEmpty) {
      preview = 'remove_string';
    } else if (replacement.trim().isEmpty) {
      preview = 'replace_with_whitespace';
    } else {
      preview = replacement;
    }
    return preview;
  }

  TextModifier copyWith({
    int? id,
    String? replacement,
    List<String>? replaceables,
    bool? caseSensitive,
  }) =>
      TextModifier(
        id: id ?? this.id,
        replacement: replacement ?? this.replacement,
        replaceables: replaceables ?? List.from(this.replaceables),
        caseSensitive: caseSensitive ?? this.caseSensitive,
      );

  void update({
    int? id,
    String? replacement,
    List<String>? replaceables,
    bool? caseSensitive,
  }) {
    this.id = id ?? this.id;
    this.replacement = replacement ?? this.replacement;
    this.replaceables = replaceables ?? this.replaceables;
    this.caseSensitive = caseSensitive ?? this.caseSensitive;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'replaceables': replaceables,
        'replacement': replacement,
      };

  factory TextModifier.fromJson(Map<String, dynamic> json) {
    return TextModifier(
      id: json['id'],
      replaceables: List<String>.from((json['replaceables'])),
      replacement: json['replacement'],
    );
  }
}
