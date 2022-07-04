import 'package:flutter/material.dart';

class NotesProvider with ChangeNotifier {
  updateNotes() {
    notifyListeners();
  }
}
