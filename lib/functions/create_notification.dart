import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/globals.dart' as globals;

void createNotification() {
  final workoutsBox = Hive.box<Workout>('workoutsBox');
  final boolBox = Hive.box<bool>('boolBox');
  final indexBox = Hive.box<int>('indexBox');
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
            : boolBox.getAt(10)!
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
        body: indexBox.getAt(2)! ==
                workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].sets -
                    1
            ? workoutsBox
                            .getAt(indexBox.getAt(0)!)!
                            .exercises[indexBox.getAt(1)!]
                            .weight %
                        1 ==
                    0
                ? "${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].name} ${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].reps}×${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].weight.toInt()}${globals.lbKg} - Set 1/${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].sets}"
                : "${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].name} ${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].reps}×${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].weight}${globals.lbKg} - Set 1/${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].sets}"
            : workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].weight %
                        1 ==
                    0
                ? "${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].name} ${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].reps}×${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].weight.toInt()}${globals.lbKg} - Set ${indexBox.getAt(2)! + 2}/${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].sets}"
                : "${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].name} ${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].reps}×${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].weight}${globals.lbKg} - Set ${indexBox.getAt(2)! + 2}/${workoutsBox.getAt(indexBox.getAt(0)!)!.exercises[indexBox.getAt(1)!].sets}",
        payload: {"name": "BlockLifts"},
        autoDismissible: false,
        locked: true,
        largeIcon: 'resource://drawable/res_icon',
        roundedLargeIcon: false,
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "done",
          label: "Done",
          autoDismissible: false,
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: "failed",
          label: "Failed",
          autoDismissible: false,
          actionType: ActionType.KeepOnTop,
        )
      ]);
}
