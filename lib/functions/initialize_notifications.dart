import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:typed_data';

void initializeNotifications() {

  Int64List highVibrationPatterns =
      Int64List.fromList([0, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]);

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    // android->app->src->main->res->drawable
    'resource://drawable/res_small_transparent_icon',
    [
      NotificationChannel(
        channelGroupKey: 'workout_channel_group',
        channelKey: 'workout_channel',
        channelName: 'Workout notifications',
        channelDescription: 'Notifications during workout',
        defaultColor: Colors.white,
        ledColor: Colors.red,
        enableVibration: false,
        playSound: false,
        importance: NotificationImportance.Default,
      ),
      NotificationChannel(
        channelGroupKey: 'workout_channel_group',
        channelKey: 'timer_channel',
        channelName: 'Timer notifications',
        channelDescription: 'Timer notifications',
        defaultColor: Colors.white,
        ledColor: Colors.red,
        enableVibration: true,
        vibrationPattern: highVibrationPatterns,
        playSound: false,
        importance: NotificationImportance.Default,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: 'workout_channel_group', channelGroupName: 'Workout')
    ],
  );
}
