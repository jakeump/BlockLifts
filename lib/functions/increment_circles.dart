import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/globals.dart' as globals;

void incrementCircles(bool fail, bool fromNotification) {
  final indexBox = Hive.box<int>('indexBox');
  final workoutsBox = Hive.box<Workout>('workoutsBox');
  final tempWorkout =
      Hive.box<Workout>('workoutsBox').getAt(indexBox.getAt(0)!);
  final boolBox = Hive.box<bool>('boolBox');
  final workoutStartTimeBox = Hive.box<DateTime>('workoutStartTimeBox');
  final breakStartTimeBox = Hive.box<DateTime>('breakStartTimeBox');
  globals.lastSet = false;

  int setIdx = indexBox.getAt(2)!;
  if (fromNotification) {
    ++setIdx;
  }

  void addTime(Timer? timer) {
    const addSeconds = 0;
    final seconds = globals.duration.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      globals.duration = Duration(seconds: seconds);
    }
  }

  void startTimer(Timer? timer) {
    timer?.cancel();
    globals.duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  if (setIdx == tempWorkout!.exercises[indexBox.getAt(1)!].sets - 1) {
    globals.lastSet = true;
  }
  if (!boolBox.getAt(9)!) {
    workoutStartTimeBox.add(DateTime.now().subtract(const Duration(seconds: 1)));
    globals.workoutDuration = const Duration(seconds: 0);
    startTimer(globals.workoutTimer);
    boolBox.putAt(9, true);
  }
  // failed button clicked from notification
  if (fail) {
    if (indexBox.getAt(1)! == tempWorkout.exercises.length - 1 &&
        setIdx == tempWorkout.exercises[indexBox.getAt(1)!].sets - 1) {
      AwesomeNotifications().cancelAll();
      boolBox.putAt(8, false);
      tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] -= 2;
      tempWorkout.save();
    } else {
      // starts timer
      if (boolBox.getAt(1)!) {
        boolBox.putAt(8, true);
      }
      breakStartTimeBox.putAt(0, DateTime.now().subtract(const Duration(seconds: 1)));
      if (!fromNotification) {
        startTimer(globals.timer);
      }
      tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] -= 2;
      tempWorkout.save();
      boolBox.putAt(10, true);
    }
  } else {
    // loops around
    if (tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] == 0) {
      AwesomeNotifications().cancelAll();
      boolBox.putAt(8, false);

      tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] =
          tempWorkout.exercises[indexBox.getAt(1)!].reps + 1;
      tempWorkout.save();
      // last exercise, last rep, don't show timer
    } else if (indexBox.getAt(1)! == tempWorkout.exercises.length - 1 &&
        setIdx == tempWorkout.exercises[indexBox.getAt(1)!].sets - 1) {
      AwesomeNotifications().cancelAll();
      boolBox.putAt(8, false);
      tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] -= 1;
      tempWorkout.save();
    } else {
      // starts timer
      if (boolBox.getAt(1)!) {
        boolBox.putAt(8, true);
      }
      breakStartTimeBox.putAt(0, DateTime.now().subtract(const Duration(seconds: 1)));
      if (!fromNotification) {
        startTimer(globals.timer);
      }
      tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] -= 1;
      tempWorkout.save();
      if (tempWorkout.exercises[indexBox.getAt(1)!].repsCompleted[setIdx] ==
          tempWorkout.exercises[indexBox.getAt(1)!].reps) {
        boolBox.putAt(10, false);
      } else {
        boolBox.putAt(10, true);
      }
    }
  }

  // if last set, set to 0
  if (setIdx ==
      workoutsBox
              .getAt(indexBox.getAt(0)!)!
              .exercises[indexBox.getAt(1)!]
              .sets -
          1) {
    indexBox.putAt(2, -1);
    // if not last exercise
    if (indexBox.getAt(1)! !=
        workoutsBox.getAt(indexBox.getAt(0)!)!.exercises.length - 1) {
      indexBox.putAt(1, indexBox.getAt(1)! + 1);
    }
  } else {
    indexBox.putAt(2, setIdx);
  }
  globals.circleCounter.value++;
}
