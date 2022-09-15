import 'package:merge2mkv/models/models.dart';

abstract class InputBasic {
  Show item;
  UserProfile profile;

  InputBasic({
    required this.item,
    required this.profile,
  });

  @override
  String toString() => 'InputNotifier(item: $item, profile: $profile)';

  @override
  bool operator ==(covariant InputBasic other) {
    if (identical(this, other)) return true;

    return other.item == item && other.profile == profile;
  }

  @override
  int get hashCode => item.hashCode ^ profile.hashCode;
}
