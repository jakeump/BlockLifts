import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blocklifts/functions/vibrate_notification.dart';
import 'package:blocklifts/functions/play_remote_file.dart';

import 'package:blocklifts/globals.dart' as globals;

// if seconds is equal to any time in list of custom times, play sound
void checkTime(int seconds) {
  Box<TimerMap> successTimerBox = Hive.box<TimerMap>('successTimerBox');
  Box<TimerMap> failTimerBox = Hive.box<TimerMap>('failTimerBox');
  Box<bool> boolBox = Hive.box<bool>('boolBox');
  AwesomeNotifications().cancel(1234);

  if (!globals.failed) {
    for (int i = 0; i < successTimerBox.length; i++) {
      if (seconds == successTimerBox.getAt(i)!.time) {
        if (successTimerBox.getAt(i)!.isChecked) {
          if (boolBox.getAt(3)!) {
            vibrateNotification();
          }
          if (boolBox.getAt(2)!) {
            playRemoteFile();
          }
        }
      }
    }
  }
  for (int i = 0; i < failTimerBox.length; i++) {
    if (seconds == failTimerBox.getAt(i)!.time) {
      if (failTimerBox.getAt(i)!.isChecked) {
        if (boolBox.getAt(3)!) {
          vibrateNotification();
        }
        if (boolBox.getAt(2)!) {
          playRemoteFile();
        }
      }
    }
  }
}