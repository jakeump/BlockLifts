import 'package:blocklifts/classes/indivworkout.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ListProvider with ChangeNotifier {
  List _indivWorkouts = <IndivWorkout>[];
  List get indivWorkouts {
    getIndivWorkouts();
    return _indivWorkouts.toList();
  }

  getIndivWorkouts() {
    final box = Hive.box<IndivWorkout>('indivWorkoutsBox');
    _indivWorkouts = box.values.toList();
  }

  addIndivWorkout(IndivWorkout workout) {
    var indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    indivWorkoutsBox.add(workout);
    notifyListeners();
  }
}
