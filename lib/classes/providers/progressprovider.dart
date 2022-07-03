import 'package:flutter/material.dart';

class ProgressProvider with ChangeNotifier {
  updateProgress() {
    notifyListeners();
  }
}
