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
    ),
    UserProfile(
      id: 1,
      name: 'Default (Movie)',
      showTitleFormat: '%show_title%% (year)%',
      videoTitleFormat: '%show_title%',
      subtitleTitleFormat: '%language%% (hearing_impaired)%% (forced)%',
      defaultFlagOrder: [
        'default',
        'hearing_impaired',
      ],
      defaultLanguage: 'eng',
      languages: UserProfile.defaultLanguages,
      modifiers: UserProfile.defaultModifiers,
    ),
    UserProfile(
      id: 2,
      name: 'Default (Series)',
      showTitleFormat: '%show_title%',
      videoTitleFormat:
          '%show_title%% - Sseason_number%%Eepisode_number%% - episode_title%',
      subtitleTitleFormat: '%language%% (hearing_impaired)%% (forced)%',
      defaultFlagOrder: [
        'default',
        'hearing_impaired',
      ],
      defaultLanguage: 'eng',
      languages: UserProfile.defaultLanguages,
      modifiers: UserProfile.defaultModifiers,
    ),
  ];

  void load() {
    _items.addEntries(defaultProfiles.map((e) => MapEntry(e.id, e)));

    final profilesJson = SharedPrefs.getStringList('UserProfiles');
    if (profilesJson != null) {
      _items.addAll({
        for (var profile
            in profilesJson.map((e) => UserProfile.fromJson(jsonDecode(e))))
          profile.id: profile
      });
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
      for (var item in _items.entries)
        if (item.key >= 3) ...[item.value]
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
}
