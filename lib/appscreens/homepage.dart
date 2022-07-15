import 'package:blocklifts/appscreens/history.dart';
import 'package:blocklifts/appscreens/home.dart';
import 'package:blocklifts/appscreens/progress.dart';
import 'package:blocklifts/appscreens/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/providers/timerprovider.dart';
import 'package:blocklifts/providers/workouttimerprovider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/functions/check_time.dart';
import 'package:blocklifts/functions/create_notification.dart';
import 'package:bottom_nav_layout/bottom_nav_layout.dart';
import 'dart:async';
import 'package:blocklifts/globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final Box<bool> boolBox;
  late final Box<DateTime> workoutStartTimeBox;
  late final Box<DateTime> breakStartTimeBox;
  late final Box<int> indexBox;

  @override
  void initState() {
    super.initState();
    boolBox = Hive.box<bool>('boolBox');
    workoutStartTimeBox = Hive.box<DateTime>('workoutStartTimeBox');
    breakStartTimeBox = Hive.box<DateTime>('breakStartTimeBox');
    indexBox = Hive.box<int>('indexBox');
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
    if (!globals.pushInProgress) {
      globals.workoutTimer = Timer.periodic(const Duration(seconds: 1),
          (_) => {addWorkoutTime(globals.workoutTimer)});
    }
  }

  void addTime(Timer? timer) {
    var timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.updateTimer();
    const addSeconds = 1;
    final seconds = globals.duration.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      Duration diff = DateTime.now().difference(breakStartTimeBox.getAt(0)!);
      globals.duration = Duration(seconds: diff.inSeconds);
      // create notif every second, displays time
      // checks every second if sound should be played
      if (boolBox.getAt(8)!) {
        createNotification();
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
      Duration diff = DateTime.now().difference(workoutStartTimeBox.getAt(0)!);
      globals.workoutDuration = Duration(seconds: diff.inSeconds);
    }
    var workoutTimerProvider =
        Provider.of<WorkoutTimerProvider>(context, listen: false);
    workoutTimerProvider.updateWorkoutTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            brightness: Brightness.dark,
          ),
          child: Scaffold(
              body: BottomNavLayout(
            //savePageState: true,
            pages: [
              (_) => const Home(),
              (_) => const History(),
              (_) => const Progress(),
              (_) => const Settings(),
            ],
            pageTransitionData: _pageTransition(),
            bottomNavigationBar: (currentIndex, onTap) => BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => onTap(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: globals.tileColor,
              selectedItemColor: globals.redColor,
              unselectedItemColor: globals.navIconColor,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.date_range), label: 'History'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.line_axis), label: 'Progress'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          )));
    });
  }

  PageTransitionData _pageTransition() {
    return PageTransitionData(
      builder: (controller, child) => AnimatedBuilder(
        animation: Tween(begin: 0.0, end: 1.0).animate(controller),
        builder: (context, child) => Opacity(
          opacity: 1,
          child: Transform.scale(
            scale: 1,
            child: child,
          ),
        ),
        child: child,
      ),
      duration: 50,
      direction: AnimationDirection.out,
    );
  }
}
