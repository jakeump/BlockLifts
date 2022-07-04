// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:blocklifts/classes/plate.dart';

Future<void> initializeHive() async {
  final directory = await pathprovider.getApplicationDocumentsDirectory();

  await Hive.initFlutter(directory.path);

  Hive
    ..registerAdapter(ExerciseAdapter())
    ..registerAdapter(WorkoutAdapter())
    ..registerAdapter(IndivWorkoutAdapter())
    ..registerAdapter(TimerMapAdapter())
    ..registerAdapter(PlateAdapter());

  await Hive.openBox<Exercise>('exercisesBox');
  await Hive.openBox<Workout>('workoutsBox');
  await Hive.openBox<IndivWorkout>('indivWorkoutsBox');
  // idx 0 is actual counter, 1 is temp counter
  await Hive.openBox<int>('counterBox');
  // boolBox contains: theme, timer, ring, vibration,
  // notifications, workout in progres, keep awake, lb/kg
  await Hive.openBox<bool>('boolBox');
  await Hive.openBox<TimerMap>('successTimerBox');
  await Hive.openBox<TimerMap>('failTimerBox');
  await Hive.openBox<Plate>('platesBox');
  await Hive.openBox<String>('tempNoteBox');
  await Hive.openBox<double>('tempBodyWeightBox');
  await Hive.openBox<double>('defaultsBox'); // bar weight, sets, reps
}
