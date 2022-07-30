import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'app_data.dart';

class ShowNotifier extends ChangeNotifier {
  ShowNotifier(this.item, this.profileIndex);

  final Show item;
  int profileIndex;
  final Set<String> collapsedTrees = {};

  updateProfileIndex(int index) {
    profileIndex = index;
    notifyListeners();
  }

  addToCollapsedTrees(String path) {
    collapsedTrees.add(path);
    notifyListeners();
  }

  removeFromCollapsedTrees(String path) {
    collapsedTrees.remove(path);
    notifyListeners();
  }
}

class ShowListNotifier extends ChangeNotifier {
  final List<ShowNotifier> _items = [];
  int? selectedIndex;
  List<ShowNotifier> get items => _items;

  void addShow(List<String> paths) async {
    List<FailedPath> failedPaths = [];
    for (var path in paths) {
      if (await PathScanner.isDirectory(path)) {
        try {
          if (_items.isEmpty || !_items.any((element) => element.item.directory.path == path)) {
            var show = await PathScanner.scan(path).then((value) {
              if (value.failedGroups.isNotEmpty) {
                failedPaths.add(FailedPath('No subtitles found for Seasons: ${value.failedGroups.join(', ')}', path));
              }
              return value.show;
            });
            _items.add(ShowNotifier(show, 0));
            notifyListeners();
          }
        } catch (e) {
          failedPaths.add(FailedPath(e.toString(), path));
        }
      }
    }
    if (failedPaths.isNotEmpty) {
      showDialog<void>(
        context: AppData.mainNavigatorKey.currentContext!,
        builder: (context) => ParserResultDialog(failedPaths: failedPaths),
      );
    }
  }

  void removeShow(int index) {
    if (selectedIndex == index) {
      updateSelectedIndex(null);
    }
    _items.removeAt(index);
    notifyListeners();
  }

  void removeShows() {
    updateSelectedIndex(null);
    _items.clear();
    notifyListeners();
  }

  void deletedProfile(int index) {
    for (var showN in _items) {
      if (showN.profileIndex != index) return;
      showN.updateProfileIndex(0);
    }
  }

  void updateSelectedIndex(int? index) {
    if (selectedIndex == null || selectedIndex != index) {
      selectedIndex = index;
    } else {
      selectedIndex = null;
    }
    notifyListeners();
  }
}

class ShowQueueNotifier extends ChangeNotifier {
  ShowQueueNotifier(this.show, this.profileIndex);

  final Show show;
  int profileIndex;

  double progress = 0;

  void updateProgress(double value) async {
    if (value > 100 || value < 0) return;
    progress = value;
    notifyListeners();
  }

  updateProfileIndex(int index) {
    profileIndex = index;
    notifyListeners();
  }
}

class ShowQueueListNotifier extends ChangeNotifier {
  final List<ShowQueueNotifier> _items = [];
  List<ShowQueueNotifier> get items => _items;
  int? activeIndex;
  double progress = 0;

  void updateActiveIndex(int? index) {
    activeIndex = index;
    notifyListeners();
  }

  void updateProgress() async {
    double prog = _items.map((e) => e.progress).average;
    progress = prog;
    notifyListeners();
  }

  void addQueue(ShowNotifier show) {
    _items.add(ShowQueueNotifier(show.item, show.profileIndex));
    notifyListeners();
  }

  void removeQueue(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void deletedProfile(int index) {
    for (var showQN in _items) {
      if (showQN.profileIndex != index) return;
      showQN.updateProfileIndex(0);
    }
  }
}
