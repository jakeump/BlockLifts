import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  updateHome() {
    notifyListeners();
  }
}
