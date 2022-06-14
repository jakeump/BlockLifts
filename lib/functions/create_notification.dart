import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/globals.dart' as globals;

void createNotification(int exIdx, int setIdx) {
  final workoutsBox = Hive.box<Workout>('workoutsBox');
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(globals.duration.inMinutes.remainder(60));
  final seconds = twoDigits(globals.duration.inSeconds.remainder(60));

  AwesomeNotifications().createNotification(
      content: NotificationContent(
        // workout status, no timer
        id: 123,
        channelKey: 'workout_channel',
        title: globals.lastSet
            ? "$minutes:$seconds - Set equipment, then lift"
            : globals.failed
                ? globals.failureTimes.isEmpty
                    ? "$minutes:$seconds - Rest"
                    : globals.failureTimes.last % 60 == 0
                        ? "$minutes:$seconds - Rest ${(globals.failureTimes.last ~/ 60).toString()}min"
                        : "$minutes:$seconds - Rest ${(globals.failureTimes.last ~/ 60).toString()}min ${(globals.failureTimes.last % 60).toString()}s"
                : globals.successTimes.isEmpty
                    ? "$minutes:$seconds - Rest"
                    : globals.successTimes.last % 60 == 0
                        ? "$minutes:$seconds - Rest ${(globals.successTimes.last ~/ 60).toString()}min"
                        : "$minutes:$seconds - Rest ${(globals.successTimes.last ~/ 60).toString()}min ${(globals.successTimes.last % 60).toString()}s",
        body: setIdx ==
                workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].sets -
                    1
            ? workoutsBox
                            .getAt(globals.workoutIndex)!
                            .exercises[exIdx + 1]
                            .weight %
                        1 ==
                    0
                ? "${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].name} ${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].reps}×${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].weight.toInt()}${globals.lbKg} - Set 1/${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].sets}"
                : "${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].name} ${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].reps}×${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].weight}${globals.lbKg} - Set 1/${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx + 1].sets}"
            : workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].weight %
                        1 ==
                    0
                ? "${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].name} ${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].reps}×${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].weight.toInt()}${globals.lbKg} - Set ${setIdx + 2}/${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].sets}"
                : "${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].name} ${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].reps}×${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].weight}${globals.lbKg} - Set ${setIdx + 2}/${workoutsBox.getAt(globals.workoutIndex)!.exercises[exIdx].sets}",
        payload: {"name": "BlockLifts"},
        autoDismissible: false,
        locked: true,
        largeIcon: 'resource://drawable/icon',
        roundedLargeIcon: false,
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "done",
          label: "Done",
          autoDismissible: false,
          buttonType: ActionButtonType.KeepOnTop,
        ),
        NotificationActionButton(
          key: "failed",
          label: "Failed",
          autoDismissible: false,
          buttonType: ActionButtonType.KeepOnTop,
        )
      ]);
}
