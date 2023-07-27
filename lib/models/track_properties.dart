import '../data/app_data.dart';
import '../models/models.dart';

abstract class TrackProperties {
  TrackProperties({
    this.title,
    this.include = true,
  })  : language = AppData.languageCodes.defaultCode,
        sourceTitle = title;

  String? title;
  String? sourceTitle;
  late LanguageCode language;
  bool include;
  String? extraOptions;
  Map<String, Flag> flags = {
    'enabled': Flag(
      name: 'Enabled',
      iconData: {
        'id': 0xe73e,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--track-enabled-flag',
    ),
    'default': Flag(
      name: 'Default',
      iconData: {
        'id': 0xea38,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--default-track-flag',
    ),
    'original_language': Flag(
      name: 'Original Language',
      shortenedName: 'Original',
      iconData: {
        'id': 0xf2b7,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--original-flag',
    ),
    'forced': Flag(
      name: 'Forced',
      iconData: {
        'id': 0xe945,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--forced-display-flag',
    ),
    'commentary': Flag(
      name: 'Commentary',
      iconData: {
        'id': 0xe90a,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--commentary-flag',
    ),
    'hearing_impaired': Flag(
      name: 'Hearing Impaired',
      shortenedName: 'SDH',
      iconData: {
        'id': 0xe307,
        'fontFamily': 'MaterialIcons',
      },
      argument: '--hearing-impaired-flag',
    ),
    'visual_impaired': Flag(
      name: 'Visual Impaired',
      shortenedName: 'AD',
      iconData: {
        'id': 0xf05e9,
        'fontFamily': 'MaterialIcons',
      },
      argument: '--visual-impaired-flag',
    ),
    'text_description': Flag(
      name: 'Text Description',
      shortenedName: 'TD',
      iconData: {
        'id': 0xf3c0,
        'fontFamily': 'MaterialIcons',
      },
      argument: '--text-descriptions-flag',
    ),
  };

  Future<void> loadInfo() async {}

  /// Specified flag names according to the list [flags] declarations.
  static List<String> flagNames = [
    //'enabled', // Exclude Enabled since it can override default on playback.
    'default',
    'original_language',
    'forced',
    'commentary',
    'hearing_impaired',
    'visual_impaired',
    'text_description',
  ];

  Flag flagByIndex(int index) => flags.values.toList()[index];

  void update({
    String? title,
    LanguageCode? language,
    bool? include,
    Map<String, Flag>? flags,
    String? extraOptions,
    bool? isEnabled,
    bool? isDefault,
    bool? isOriginal,
    bool? isForced,
    bool? isCommentary,
    bool? isHearingImpaired,
    bool? isVisualImpaired,
    bool? isTextDescription,
  }) {
    this.title = title ?? this.title;
    this.language = language ?? this.language;
    this.include = include ?? this.include;
    this.flags = flags ?? this.flags;
    this.extraOptions = extraOptions ?? this.extraOptions;
    this.flags['enabled']!.value = isEnabled ?? this.flags['enabled']!.value;
    this.flags['default']!.value = isDefault ?? this.flags['default']!.value;
    this.flags['original_language']!.value =
        isOriginal ?? this.flags['original_language']!.value;
    this.flags['forced']!.value = isForced ?? this.flags['forced']!.value;
    this.flags['commentary']!.value =
        isCommentary ?? this.flags['commentary']!.value;
    this.flags['hearing_impaired']!.value =
        isHearingImpaired ?? this.flags['hearing_impaired']!.value;
    this.flags['visual_impaired']!.value =
        isVisualImpaired ?? this.flags['visual_impaired']!.value;
    this.flags['text_description']!.value =
        isTextDescription ?? this.flags['text_description']!.value;
  }
}

class Flag {
  Flag({
    required this.name,
    String? definedKey,
    String? shortenedName,
    required this.iconData,
    required this.argument,
    this.value = false,
  })  : shortenedName = shortenedName ?? name,
        definedKey = definedKey ?? name.toLowerCase().replaceAll(' ', '_');

  final String name;
  final String definedKey;
  late final String shortenedName;
  final Map<String, dynamic> iconData;
  final String argument;
  bool value;

  String get titleVar => value == true ? shortenedName : '';

  /// Generates an mkvmerge command for flag property
  List<String> command(int id) {
    if (value) {
      return [argument, '$id:yes'];
    } else {
      return [argument, '$id:no'];
    }
  }
}
