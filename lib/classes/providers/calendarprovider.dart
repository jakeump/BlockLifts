import 'package:flutter/material.dart';

class CalendarProvider with ChangeNotifier {
  updateCalendar() {
    notifyListeners();
  }
}
