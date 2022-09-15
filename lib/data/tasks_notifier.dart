import 'package:flutter/foundation.dart';
import 'package:merge2mkv/data/app_data.dart';
import 'package:merge2mkv/models/models.dart';

class TaskNotifier extends InputBasic with ChangeNotifier {
  TaskNotifier(final Show item, UserProfile profile)
      : super(item: item, profile: profile) {
    _totalVideos = item is Movie
        ? 1
        : (item as Series)
            .seasons
            .map((e) => e.videos.length)
            .fold(0, (p, c) => p + c);
  }

  double progress = 0;
  late final int _totalVideos;
  int _completed = 0;

  void updateProgress(double value) async {
    value.clamp(0, 100);

    if (item is Movie) {
      progress = value;
    } else {
      var overallPercentage =
          ((_completed + (value / 100)) / _totalVideos) * 100;
      progress = overallPercentage;
    }

    notifyListeners();
  }

  void updateCompleted() {
    _completed++;
  }

  void updateProfile(UserProfile profile) {
    profile = profile;
    notifyListeners();
  }
}

class TaskListNotifier extends ChangeNotifier {
  final Map<int, TaskNotifier> _items = {};
  final Set<int> _selected = {};
  Set<int> get selected => _selected;
  Map<int, TaskNotifier> get items => _items;
  bool active = false;

  void updateStatus(bool value) {
    active = value;
    notifyListeners();
  }

  void add(ShowNotifier show) {
    _items.addAll({
      DateTime.now().millisecondsSinceEpoch:
          TaskNotifier(show.item, show.profile)
    });
    notifyListeners();
  }

  void remove(Iterable<int> keys) {
    _selected.removeAll(keys);

    for (var key in keys) {
      _items.remove(key);
    }
    notifyListeners();
  }

  void modifiedProfile(UserProfile profile) {
    for (var taskN in _items.values) {
      if (taskN.profile != profile) return;
      taskN.updateProfile(AppData.profiles.items.entries.first.value);
    }
  }

  void addSelected(Set<int> keys) {
    _selected.addAll(keys);
    notifyListeners();
  }

  void removeSelected(Set<int> keys) {
    _selected.removeAll(keys);
    notifyListeners();
  }
}
