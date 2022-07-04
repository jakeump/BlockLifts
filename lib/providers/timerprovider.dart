import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TimerProvider with ChangeNotifier {
  void toggleTimerSwitch(bool value) {
    Box<bool> boolBox = Hive.box<bool>('boolBox');
    if (boolBox.getAt(1)! == false) {
      boolBox.putAt(1, true);
    } else {
      boolBox.putAt(1, false);
    }
    notifyListeners();
  }
}
