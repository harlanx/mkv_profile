import '../data/app_data.dart';
import '../models/models.dart';

abstract class TrackProperties {
  TrackProperties({
    this.title,
    this.include = true,
  }) : language = AppData.languageCodes.defaultCode;

  String? title;
  late LanguageCode language;
  bool include;
  String? extraOptions;
  Map<String, Flag> flags = {
    'default': Flag(
      name: 'Default',
      iconData: {
        'id': 0xe73e,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--default-track-flag',
      descripton:
          'Enable to set the default flag on this item.\nUsually a flag on tracks that is automatically chosen by the media player unless the user overrides it.',
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
      descripton:
          'Enable to set the original language flag on this item.\nUsually a flag on Audio and Subtitle tracks that are the same with the content origin\'s language.',
    ),
    'forced': Flag(
      name: 'Forced',
      iconData: {
        'id': 0xe945,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--forced-display-flag',
      descripton:
          'Enable to set the forced flag on this item.\nThis flag can be used on Subtitle tracks that only has translations for the non-native language spoken in content\'s scenes.\nUsually a flag for Subtitle tracks that forces itself to be played on any media player that supports it.',
    ),
    'commentary': Flag(
      name: 'Commentary',
      iconData: {
        'id': 0xe90a,
        'fontFamily': 'FluentIcons',
        'fontPackage': 'fluent_ui',
      },
      argument: '--commentary-flag',
      descripton:
          'Enable to set the commentary flag on this item.\nUsually a flag on Audio and Subtitle tracks that has the commentary of individuals/groups who worked on that content.',
    ),
    'hearing_impaired': Flag(
      name: 'Hearing Impaired',
      shortenedName: 'SDH',
      iconData: {
        'id': 0xe307,
        'fontFamily': 'MaterialIcons',
      },
      argument: '--hearing-impaired-flag',
      descripton:
          'Enable to set the hearing impaired (SDH) flag on this item.\nUsually a flag on Subtitle tracks that has descriptions to auditive information from the content.',
    ),
    'visual_impaired': Flag(
      name: 'Visual Impaired',
      shortenedName: 'AD',
      iconData: {
        'id': 0xf05e9,
        'fontFamily': 'MaterialIcons',
      },
      argument: '--visual-impaired-flag',
      descripton:
          'Enable to set the visual impaired (AD) flag on this item.\nUsually a flag on Audio tracks that narrates the content\'s scenes.',
    ),
    'text_description': Flag(
      name: 'Text Description',
      shortenedName: 'TD',
      iconData: {
        'id': 0xf3c0,
        'fontFamily': 'MaterialIcons',
      },
      argument: '--text-descriptions-flag',
      descripton:
          'Enable to set the text description (TD) flag on this item.\nUsually a flag on Subtitle tracks for the Audio tracks that narrates the content\'s scenes.',
    ),
  };

  /// Specified flag names according to the list [flags] declarations.
  static List<String> flagNames = [
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
    String? shortenedName,
    required this.iconData,
    required this.argument,
    required this.descripton,
    this.value = false,
  }) : shortenedName = shortenedName ?? name;

  final String name;
  late final String shortenedName;
  final Map<String, dynamic> iconData;
  final String argument;
  final String descripton;
  bool value;

  String get titleVar => value == true ? shortenedName : '';

  /// Generates an mkvmerge command for flag property
  List<String> command(int id) {
    if (name == 'Default') {
      if (value) {
        return [argument, '$id:yes'];
      } else {
        return [argument, '$id:no'];
      }
    } else if (value) {
      return [argument, '$id:yes'];
    }
    return [];
  }
}
