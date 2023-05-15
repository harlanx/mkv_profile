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
      showTitleFormat: '%title% (%year%)',
      videoTitleFormat: '%title% (%year%)',
      subtitleTitleFormat: '%hearing_impaired% %forced%',
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
      showTitleFormat: '%title%',
      videoTitleFormat: '%title% - S%season%E%episode%',
      subtitleTitleFormat: '%hearing_impaired% %forced%',
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

    List<String>? profilesJson = SharedPrefs.getStringList('UserProfiles');
    if (profilesJson != null) {
      _items.addAll({
        for (var profile in profilesJson.map((e) => UserProfile.fromJson(e)))
          profile.id: profile
      });
    }
  }

  Future<void> save() async {
    await SharedPrefs.setStringList(
      'UserProfiles',
      _items.values.map((e) => e.toJson()).toList(),
    );
  }

  void refresh() => notifyListeners();

  void add(int key, UserProfile profile) {
    _items.addAll({key: profile});
    notifyListeners();
  }

  void delete(int id) {
    _items.remove(id);
    notifyListeners();
  }
}
