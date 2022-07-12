import 'package:blocklifts/classes/incrementssettings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/classes/plate.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:blocklifts/globals.dart' as globals;

void defaultState() async {
  AwesomeNotifications().cancelAll();

  Box<double> defaultsBox = Hive.box<double>('defaultsBox');
  defaultsBox.deleteAll(defaultsBox.keys);
  defaultsBox.add(45);
  defaultsBox.add(5);
  defaultsBox.add(5);

  Box<IncrementsSettings> incrementsSettingsBox =
      Hive.box<IncrementsSettings>('incrementsSettingsBox');
  incrementsSettingsBox.deleteAll(incrementsSettingsBox.keys);
  incrementsSettingsBox.add(IncrementsSettings(true, 1, 5, true, 10, 3));

  Workout defaultA = Workout("BlockLifts A");
  Workout defaultB = Workout("BlockLifts B");
  Exercise squat = Exercise(
      "Squat",
      defaultsBox.getAt(0)!,
      defaultsBox.getAt(1)!.toInt(),
      defaultsBox.getAt(2)!.toInt(),
      true,
      1,
      5,
      true,
      10,
      3);
  Exercise benchPress = Exercise(
      "Bench Press",
      defaultsBox.getAt(0)!,
      defaultsBox.getAt(1)!.toInt(),
      defaultsBox.getAt(2)!.toInt(),
      true,
      1,
      5,
      true,
      10,
      3);
  Exercise barbellRow = Exercise(
      "Barbell Row",
      defaultsBox.getAt(0)!,
      defaultsBox.getAt(1)!.toInt(),
      defaultsBox.getAt(2)!.toInt(),
      true,
      1,
      5,
      true,
      10,
      3);
  Exercise overheadPress = Exercise(
      "Overhead Press",
      defaultsBox.getAt(0)!,
      defaultsBox.getAt(1)!.toInt(),
      defaultsBox.getAt(2)!.toInt(),
      true,
      1,
      5,
      true,
      10,
      3);
  Exercise deadlift = Exercise(
      "Deadlift",
      defaultsBox.getAt(0)!,
      defaultsBox.getAt(1)!.toInt(),
      defaultsBox.getAt(2)!.toInt(),
      true,
      1,
      5,
      true,
      10,
      3);
  squat.bookmarked = true;
  benchPress.bookmarked = true;
  deadlift.bookmarked = true;
  deadlift.sets = 1;
  deadlift.increment = 10;

  defaultA.exercises.add(squat);
  defaultB.exercises.add(squat);
  defaultA.exercises.add(benchPress);
  defaultA.exercises.add(barbellRow);
  defaultB.exercises.add(overheadPress);
  defaultB.exercises.add(deadlift);

  Box<Exercise> exercisesBox = Hive.box<Exercise>('exercisesBox');
  exercisesBox.deleteAll(exercisesBox.keys);
  exercisesBox.add(globals.customxyz);
  exercisesBox.add(squat);
  exercisesBox.add(benchPress);
  exercisesBox.add(barbellRow);
  exercisesBox.add(overheadPress);
  exercisesBox.add(deadlift);

  Box<Workout> workoutsBox = Hive.box<Workout>('workoutsBox');
  workoutsBox.deleteAll(workoutsBox.keys);
  workoutsBox.add(defaultA);
  workoutsBox.add(defaultB);

  Box<IndivWorkout> indivWorkoutsBox =
      Hive.box<IndivWorkout>('indivWorkoutsBox');
  indivWorkoutsBox.deleteAll(indivWorkoutsBox.keys);

  Box<double> tempBodyWeightBox = Hive.box<double>('tempBodyWeightBox');
  tempBodyWeightBox.deleteAll(tempBodyWeightBox.keys);
  tempBodyWeightBox.add(150);

  Box<Plate> platesBox = Hive.box<Plate>('platesBox');
  platesBox.deleteAll(platesBox.keys);
  platesBox.add(Plate(45, 8));
  platesBox.add(Plate(35, 4));
  platesBox.add(Plate(25, 4));
  platesBox.add(Plate(10, 4));
  platesBox.add(Plate(5, 4));
  platesBox.add(Plate(2.5, 4));

  Box<int> counterBox = Hive.box<int>('counterBox');
  counterBox.deleteAll(counterBox.keys);
  counterBox.add(0);
  counterBox.add(0);

  Box<bool> boolBox = Hive.box<bool>('boolBox');
  boolBox.deleteAll(boolBox.keys);
  boolBox.add(true); // theme
  boolBox.add(true); // timer
  boolBox.add(true); // ring
  boolBox.add(true); // vibration
  boolBox.add(false); // notifications
  boolBox.add(false); // workout in progress
  boolBox.add(true); // keep awake
  boolBox.add(true); // lb/kg
  boolBox.add(false); // show break timer
  boolBox.add(false); // workout timer in progress
  boolBox.add(false); // failed set
  globals.lbKg = "lb";

  Box<TimerMap> successTimerBox = Hive.box<TimerMap>('successTimerBox');
  successTimerBox.deleteAll(successTimerBox.keys);
  successTimerBox.add(TimerMap(90, true));
  successTimerBox.add(TimerMap(180, true));

  Box<TimerMap> failTimerBox = Hive.box<TimerMap>('failTimerBox');
  failTimerBox.deleteAll(failTimerBox.keys);
  failTimerBox.add(TimerMap(300, true));

  Box<String> tempNoteBox = Hive.box<String>('tempNoteBox');
  tempNoteBox.deleteAll(tempNoteBox.keys);
  tempNoteBox.add("");

  Box<int> indexBox = Hive.box<int>('indexBox');
  indexBox.deleteAll(indexBox.keys);
  indexBox.add(0);
  indexBox.add(0);
  indexBox.add(0);

  Box<DateTime> workoutStartTimeBox = Hive.box<DateTime>('workoutStartTimeBox');
  workoutStartTimeBox.deleteAll(workoutStartTimeBox.keys);

  Box<DateTime> breakStartTimeBox = Hive.box<DateTime>('breakStartTimeBox');
  breakStartTimeBox.deleteAll(breakStartTimeBox.keys);
  breakStartTimeBox.add(DateTime.now());

  Box<bool> scheduleBox = Hive.box<bool>('scheduleBox');
  scheduleBox.deleteAll(scheduleBox.keys);
  scheduleBox.add(false);
  scheduleBox.add(true);
  scheduleBox.add(false);
  scheduleBox.add(true);
  scheduleBox.add(false);
  scheduleBox.add(true);
  scheduleBox.add(false);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('resetToDefault', false);
}
