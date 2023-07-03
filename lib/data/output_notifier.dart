import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../utilities/utilities.dart';

class OutputNotifier extends ChangeNotifier {
  final Map<int, OutputBasic> _items = {};
  Map<int, OutputBasic> get items => _items;
  final Set<int> _selected = {};
  Set<int> get selected => _selected;

  void load() {
    final outputsJson = SharedPrefs.getStringList('Outputs') ?? [];
    _items.addAll({
      for (var output
          in outputsJson.map((e) => OutputBasic.fromJson(jsonDecode(e))))
        output.dateTime.millisecondsSinceEpoch: output
    });
  }

  Future<void> save() async {
    final tobeSaved = _items.values.map((e) => jsonEncode(e)).toList();
    await SharedPrefs.setStringList('Outputs', tobeSaved);
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
