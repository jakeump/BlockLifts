import 'package:blocklifts/appscreens/history.dart';
import 'package:blocklifts/appscreens/home.dart';
import 'package:blocklifts/appscreens/progress.dart';
import 'package:blocklifts/appscreens/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/classes/providers/workouttimerprovider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/mybottomnavigationbar.dart';
import 'package:blocklifts/classes/providers/bottomnavigationbarprovider.dart';
import 'package:blocklifts/functions/check_time.dart';
import 'package:blocklifts/functions/create_notification.dart';
import 'dart:async';
import 'package:blocklifts/globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box<bool> boolBox;

  @override
  void initState() {
    super.initState();
    boolBox = Hive.box<bool>('boolBox');
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed && boolBox.getAt(4)! == false) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Allow Notifications',
                  style: TextStyle(fontSize: 20, color: globals.textColor)),
              content: Text(
                  'BlockLifts would like to send you notifications during workouts',
                  style: TextStyle(fontSize: 15, color: globals.textColor)),
              actions: [
                TextButton(
                  onPressed: () {
                    boolBox.putAt(4, true);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Don\'t Allow',
                    style: TextStyle(fontSize: 16, color: globals.textColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      fontSize: 16,
                      color: globals.textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          boolBox.putAt(4, true);
        }
      },
    );
    globals.timer = Timer.periodic(
        const Duration(seconds: 1), (_) => {addTime(globals.timer)});
    globals.workoutTimer = Timer.periodic(const Duration(seconds: 1),
        (_) => {addWorkoutTime(globals.workoutTimer)});
  }

  void addTime(Timer? timer) {
    globals.timerCounter.value++;
    const addSeconds = 1;
    final seconds = globals.duration.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      globals.duration = Duration(seconds: seconds);
      // create notif every second, display time
      if (globals.showTimer) {
        createNotification(globals.exerciseIndex, globals.setIndex);
      }
      // checks every second if sound should be played
      if (globals.showTimer) {
        checkTime(globals.duration.inSeconds);
      }
    }
  }

  void addWorkoutTime(Timer? workoutTimer) {
    const addSeconds = 1;
    final seconds = globals.workoutDuration.inSeconds + addSeconds;
    if (seconds < 0) {
      workoutTimer?.cancel();
    } else {
      globals.workoutDuration = Duration(seconds: seconds);
    }
    if (globals.workoutDuration.inSeconds % 60 == 0) {
      // updates homepage every minute
      var workoutTimerProvider =
          Provider.of<WorkoutTimerProvider>(context, listen: false);
      workoutTimerProvider.updateWorkoutTimer();
    }
  }

  var currentTab = const [
    Home(),
    History(),
    Progress(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationBarProvider>(
        builder: (context, provider, child) {
      return Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          brightness: Brightness.dark,
        ),
        child: Scaffold(
          body: currentTab[provider.currentIndex],
          bottomNavigationBar: MyBottomNavigationBar(onTapped: _onTappedBar),
        ),
      );
    });
  }

  void _onTappedBar(int value) {
    Provider.of<BottomNavigationBarProvider>(context, listen: false)
        .currentIndex = value;
  }
}
