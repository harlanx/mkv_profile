import 'package:flutter/foundation.dart';

class PageNotifier extends ChangeNotifier {
  int _current = 0;
  int get current => _current;

  void update(int index) {
    _current = index;
    notifyListeners();
  }
}
