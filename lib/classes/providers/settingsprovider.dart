import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider with ChangeNotifier {
  void toggleThemeSwitch() {
    Box<bool> boolBox = Hive.box<bool>('boolBox');
    if (boolBox.getAt(0) == false) {
      boolBox.putAt(0, true);
    } else {
      boolBox.putAt(0, false);
    }
    notifyListeners();
  }

  void toggleAwakeSwitch() {
    Box<bool> boolBox = Hive.box<bool>('boolBox');
    if (boolBox.getAt(6) == false) {
      boolBox.putAt(6, true);
    } else {
      boolBox.putAt(6, false);
    }
    notifyListeners();
  }

  void updatePage() {
    notifyListeners();
  }
}
