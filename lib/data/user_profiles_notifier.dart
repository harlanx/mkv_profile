import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class UserProfilesNotifier extends ChangeNotifier {
  late List<UserProfile> items;

  static UserProfilesNotifier load() {
    List<String>? userProfilesJson = SharedPrefs.getStringList('UserProfiles');
    var profilesNotifier = UserProfilesNotifier()
      ..items = [
        UserProfile(name: 'None'),
        UserProfile(
          name: 'Default',
          defaultLanguage: 'en',
          languages: UserProfile.defaultLanguages,
          stringToSpace: UserProfile.replaceWithSpace,
          stringToRemove: List.from(UserProfile.removeString)..addAll(['RARBG']),
        ),
      ];

    if (userProfilesJson != null) {
      profilesNotifier.items = userProfilesJson.map((e) => UserProfile.fromJson(e)).toList();
    }
    return profilesNotifier;
  }

  void save() {
    SharedPrefs.setStringList('UserProfiles', items.map((e) => e.toJson()).toList());
  }

  void updateProfile(int index, UserProfile profile) {
    items[index] = profile;
    notifyListeners();
  }

  void addProfile(UserProfile profile) {
    items.add(profile);
    notifyListeners();
  }

  void removeProfile(int index) {
    items.removeAt(index);
    notifyListeners();
  }
}
