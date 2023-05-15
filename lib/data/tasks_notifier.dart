import 'package:flutter/foundation.dart';

import '../data/app_data.dart';
import '../models/models.dart';
import '../services/app_services.dart';

class TaskNotifier extends InputBasic with ChangeNotifier {
  TaskNotifier(final Show item, UserProfile profile)
      : super(show: item, profile: profile) {
    total = item is Movie ? 1 : (item as Series).allVideos.length;
  }

  double progress = 0;
  late final int total;
  int completed = 0;

  void updateProgress(double value) async {
    value.clamp(0, 100);

    progress = ((completed + (value / 100)) / total) * 100;

    notifyListeners();
  }

  void increaseCompleted({int count = 1, bool notify = false}) {
    completed += count;
    if (notify) {
      notifyListeners();
    }
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
    ShowMerger.active = active;
    notifyListeners();
  }

  void add(ShowNotifier show) {
    _items.addAll({
      DateTime.now().millisecondsSinceEpoch + show.hashCode:
          TaskNotifier(show.show, show.profile)
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
