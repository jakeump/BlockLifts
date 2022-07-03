import 'package:flutter/material.dart';

class WorkoutTimerProvider with ChangeNotifier {
  updateWorkoutTimer() {
    notifyListeners();
  }
}
