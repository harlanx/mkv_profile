import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class UserProfilesNotifier extends ChangeNotifier {
  late final Map<int, UserProfile> _items = {};
  Map<int, UserProfile> get items => _items;

  static UserProfilesNotifier load() {
    var profilesNotifier = UserProfilesNotifier()
      .._items.addAll(
        {
          0: UserProfile(
            name: 'None',
            id: 0,
          ),
          1: UserProfile(
            name: 'Default (Movie)',
            id: 1,
            titleFormat: '%title%<M (%year%)>',
            defaultLanguage: 'eng',
            languages: UserProfile.defaultLanguages,
            removeString: List.from(UserProfile.defaultRemove)
              ..addAll(['RARBG', 'YIFY', 'ION265', 'ION10']),
            replaceString: UserProfile.defaultReplace,
          ),
          2: UserProfile(
            name: 'Default (Series)',
            id: 2,
            titleFormat: '%title%',
            episodeTitleFormat: '%title% - S%season%E%episode%',
            defaultLanguage: 'eng',
            languages: UserProfile.defaultLanguages,
            removeString: List.from(UserProfile.defaultRemove)
              ..addAll(['RARBG', 'YIFY', 'ION265', 'ION10']),
            replaceString: UserProfile.defaultReplace,
          ),
        },
      );

    List<String>? profilesJson = SharedPrefs.getStringList('UserProfiles');
    if (profilesJson != null) {
      profilesNotifier._items.addAll({
        for (var profile in profilesJson.map((e) => UserProfile.fromJson(e)))
          profile.id: profile
      });
    }
    return profilesNotifier;
  }

  void save() {
    SharedPrefs.setStringList(
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
