import '../models/models.dart';

abstract class InputBasic {
  InputBasic({
    required this.show,
    required this.profile,
  });

  Show show;
  UserProfile profile;

  @override
  String toString() => 'InputNotifier(item: $show, profile: $profile)';

  @override
  bool operator ==(covariant InputBasic other) {
    if (identical(this, other)) return true;

    return other.show == show && other.profile == profile;
  }

  @override
  int get hashCode => show.hashCode ^ profile.hashCode;
}
