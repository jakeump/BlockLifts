import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/globals.dart' as globals;

void incrementCircles(int workoutIndex, int exIdx, int setIdx, bool fail) {
  final workoutsBox = Hive.box<Workout>('workoutsBox');
  final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(workoutIndex);
  final boolBox = Hive.box<bool>('boolBox');
  globals.lastSet = false;

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

  if (setIdx == tempWorkout!.exercises[exIdx].sets - 1) {
    globals.lastSet = true;
  }
  if (!globals.workoutTimerInProgress) {
    globals.workoutDuration = const Duration(seconds: 0);
    startTimer(globals.workoutTimer);
    globals.workoutTimerInProgress = true;
  }
  // failed button clicked from notification
  if (fail) {
    if (exIdx == tempWorkout.exercises.length - 1 &&
        setIdx == tempWorkout.exercises[exIdx].sets - 1) {
      AwesomeNotifications().cancelAll();
      globals.showTimer = false;
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 2;
      tempWorkout.save();
    } else {
      // starts timer
      if (boolBox.getAt(1)!) {
        globals.showTimer = true;
      }
      startTimer(globals.timer);
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 2;
      tempWorkout.save();
      globals.failed = true;
    }
  } else {
    // loops around
    if (tempWorkout.exercises[exIdx].repsCompleted[setIdx] == 0) {
      AwesomeNotifications().cancelAll();
      globals.showTimer = false;

      tempWorkout.exercises[exIdx].repsCompleted[setIdx] =
          tempWorkout.exercises[exIdx].reps + 1;
      tempWorkout.save();
      // last exercise, last rep, don't show timer
    } else if (exIdx == tempWorkout.exercises.length - 1 &&
        setIdx == tempWorkout.exercises[exIdx].sets - 1) {
      AwesomeNotifications().cancelAll();
      globals.showTimer = false;
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 1;
      tempWorkout.save();
    } else {
      // starts timer
      if (boolBox.getAt(1)!) {
        globals.showTimer = true;
      }
      startTimer(globals.timer);
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 1;
      tempWorkout.save();
      if (tempWorkout.exercises[exIdx].repsCompleted[setIdx] ==
          tempWorkout.exercises[exIdx].reps) {
        globals.failed = false;
      } else {
        globals.failed = true;
      }
    }
  }

  // if last set, set to 0
  if (setIdx == workoutsBox.getAt(workoutIndex)!.exercises[exIdx].sets - 1) {
    globals.setIndex = -1;
    // if not last exercise
    if (exIdx != workoutsBox.getAt(workoutIndex)!.exercises.length - 1) {
      ++globals.exerciseIndex;
    }
  } else {
    ++globals.setIndex;
  }
  globals.circleCounter.value++;
}
