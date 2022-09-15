import 'package:flutter/foundation.dart';
import 'package:merge2mkv/models/models.dart';
import 'package:merge2mkv/utilities/utilities.dart';

class OutputNotifier extends ChangeNotifier {
  final Map<int, OutputBasic> _items = {};
  Map<int, OutputBasic> get items => _items;
  final Set<int> _selected = {};
  Set<int> get selected => _selected;

  static OutputNotifier load() {
    List<String> rawOutputList =
        SharedPrefs.getStringList('OutputNotifier') ?? [];
    Map<int, OutputBasic> imported = {};
    for (var rawOutput in rawOutputList) {
      var output = OutputBasic.fromJson(rawOutput);
      imported.addAll({output.dateTime.millisecondsSinceEpoch: output});
    }
    return OutputNotifier().._items.addAll(imported);
  }

  void save() {
    List<String> tobeSaved = _items.values.map((e) => e.toJson()).toList();
    SharedPrefs.setStringList('OutputNotifier', tobeSaved);
  }

  void add(List<OutputBasic> outputResults) {
    _items.addAll({
      for (var output in outputResults)
        output.dateTime.millisecondsSinceEpoch: output
    });
    notifyListeners();
  }

  void remove(Set<int> keys) {
    for (var key in keys) {
      _items.remove(key);
    }
    notifyListeners();
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
