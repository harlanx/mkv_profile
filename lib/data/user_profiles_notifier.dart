import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../utilities/utilities.dart';

class UserProfilesNotifier extends ChangeNotifier {
  late final Map<int, UserProfile> _items = {};
  Map<int, UserProfile> get items => _items;

  static List<UserProfile> defaultProfiles = [
    UserProfile(
      id: 0,
      name: 'None',
      isDefault: true,
    ),
    UserProfile(
      id: 1,
      name: 'Movie (Default)',
      isDefault: true,
      showTitleFormat: '%show_title%% (year)%',
      videoTitleFormat: '%show_title%',
      audioTitleFormat: '%language%',
      subtitleTitleFormat: '%language%% (hearing_impaired)%% (forced)%',
      defaultFlagOrder: [
        'hearing_impaired',
        'default',
      ],
      defaultAudioLanguage: 'eng',
      audioLanguages: UserProfile.defaultLanguages,
      defaultSubtitleLanguage: 'eng',
      subtitleLanguages: UserProfile.defaultLanguages,
      modifiers: UserProfile.defaultModifiers,
    ),
    UserProfile(
      id: 2,
      name: 'Series (Default)',
      isDefault: true,
      showTitleFormat: '%show_title%',
      videoTitleFormat:
          '%show_title%% - Sseason_number%%Eepisode_number%% - episode_title%',
      audioTitleFormat: '%language%',
      subtitleTitleFormat: '%language%% (hearing_impaired)%% (forced)%',
      defaultFlagOrder: [
        'hearing_impaired',
        'default',
      ],
      defaultAudioLanguage: 'eng',
      audioLanguages: UserProfile.defaultLanguages,
      defaultSubtitleLanguage: 'eng',
      subtitleLanguages: UserProfile.defaultLanguages,
      modifiers: UserProfile.defaultModifiers,
    ),
  ];

  void load() {
    // Loads hard-coded default profiles
    // Used only on initial usage of the app.
    _items.addEntries(defaultProfiles.map((e) => MapEntry(e.id, e)));

    // Loading saved profiles
    // Hard-coded default profiles are replaced by the saved default profiles.
    final userProfilesJson = SharedPrefs.getStringList('UserProfiles');
    if (userProfilesJson != null) {
      final userProfiles =
          userProfilesJson.map((e) => UserProfile.fromJson(jsonDecode(e)));
      _items.addEntries(userProfiles.map((e) => MapEntry(e.id, e)));
    }
  }

  Future<void> save() async {
    final toBeSaved = _items.values.map((e) => jsonEncode(e)).toList();
    await SharedPrefs.setStringList('UserProfiles', toBeSaved);
  }

  Future<void> import(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final jsonEntries = jsonDecode(await file.readAsString());
      for (var json in jsonEntries) {
        final profile = UserProfile.fromJson(json);
        _items.addAll({profile.id: profile});
      }
    }
    notifyListeners();
  }

  Future<void> export(String path) async {
    // Exclude default profiles.
    final toBeSaved = <UserProfile>[
      for (var item in _items.entries) item.value
    ];
    final jsonString = jsonEncode(toBeSaved);
    await File(path).writeAsString(jsonString);
  }

  void refresh() => notifyListeners();

  void add(int key, UserProfile profile) {
    _items.addAll({key: profile});
    notifyListeners();
  }

  void remove(int id) {
    _items.remove(id);
    notifyListeners();
  }

  void updateDefaultModifiers(String json) {
    final List<dynamic> jsonList = jsonDecode(json);
    final newModifiers = jsonList
        .map((e) => TextModifier.fromJson(e as Map<String, dynamic>))
        .toList();
    // Movies (Default)
    // Series (Default)
    _items[1]!.modifiers = newModifiers;
    _items[2]!.modifiers = newModifiers;
    notifyListeners();
  }
}
