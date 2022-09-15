import 'package:fluent_ui/fluent_ui.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/services/app_services.dart';
import 'package:merge2mkv/utilities/utilities.dart';
import 'app_data.dart';

class ShowNotifier extends InputBasic with ChangeNotifier {
  ShowNotifier(
    final Show item,
    UserProfile profile,
  ) : super(item: item, profile: profile);

  final Set<String> collapsedTrees = {};

  void refresh() => notifyListeners();

  void updateProfile(UserProfile profile) {
    this.profile = profile;
    notifyListeners();
  }

  void addToCollapsedTrees(String path) {
    collapsedTrees.add(path);
    notifyListeners();
  }

  void removeFromCollapsedTrees(String path) {
    collapsedTrees.remove(path);
    notifyListeners();
  }
}

class ShowListNotifier extends ChangeNotifier {
  int? selectedID;
  final Map<int, ShowNotifier> _items = {};
  Map<int, ShowNotifier> get items => _items;

  Future<void> add(List<String> paths) async {
    List<ScanError> failedPaths = [];
    for (var path in paths) {
      if (await PathScanner.isDirectory(path)) {
        try {
          if (_items.isEmpty ||
              !_items.values.any((e) => e.item.directory.path == path)) {
            var show = await PathScanner.scan(path).then((value) {
              if (value.failedGroups.isNotEmpty) {
                failedPaths.add(ScanError(
                    'No subtitles found for: ${value.failedGroups.join(', ')}',
                    path));
              }
              return value.show;
            });
            _items.addAll({
              DateTime.now().millisecondsSinceEpoch:
                  ShowNotifier(show, AppData.profiles.items.entries.first.value)
            });
            notifyListeners();
          }
        } catch (e) {
          failedPaths.add(ScanError(e.toString(), path));
        }
      }
    }
    if (failedPaths.isNotEmpty) {
      showDialog<void>(
        context: AppData.mainNavigatorKey.currentContext!,
        builder: (context) => ParserResultDialog(failedPaths: failedPaths),
      );
    }
    return;
  }

  void remove(int id) {
    if (selectedID == id) {
      selectID(null);
    }
    _items.remove(id);
    notifyListeners();
  }

  void removeAll() {
    selectID(null);
    _items.clear();
    notifyListeners();
  }

  void modifiedProfile(UserProfile profile) {
    for (var showN in _items.values) {
      if (showN.profile != profile) return;
      showN.updateProfile(AppData.profiles.items.entries.first.value);
    }
  }

  void selectID(int? id) {
    if (selectedID == null || selectedID != id) {
      selectedID = id;
    } else {
      selectedID = null;
    }
    notifyListeners();
  }
}
