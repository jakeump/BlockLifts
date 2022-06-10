import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:device_info_plus/device_info_plus.dart';

part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final androidSdkVersion = androidInfo.version.sdkInt ?? 0;
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
  await Hive.openBox<int>('counterBox');
  // boolBox contains: theme, timer, ring, vibration, deload, notifications
  await Hive.openBox<bool>('boolBox');
  await Hive.openBox<TimerMap>('successTimerBox');
  await Hive.openBox<TimerMap>('failTimerBox');
  await Hive.openBox<Plate>('platesBox');
  await Hive.openBox<String>('tempNoteBox');
  await Hive.openBox<double>('tempBodyWeightBox');

  // on first time opening app, sets to default state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? resetToDefault = prefs.getBool('resetToDefault');

  // if first time opening app
  if (resetToDefault == null || resetToDefault) {
    defaultState();
  }

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    // android->app->src->main->res->drawable
    'resource://drawable/notification_icon',
    [
      NotificationChannel(
        channelGroupKey: 'workout_channel_group',
        channelKey: 'workout_channel',
        channelName: 'Workout notifications',
        channelDescription: 'Notifications during workout',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        enableVibration: false,
        playSound: false,
        importance: NotificationImportance.Default,
      ),
      /*NotificationChannel(
        channelGroupKey: 'workout_channel_group',
        channelKey: 'timer_channel',
        channelName: 'Timer notifications',
        channelDescription: 'Timer notifications',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        enableVibration: true,
        vibrationPattern: lowVibrationPattern,
        playSound: false,
        importance: NotificationImportance.Default,
      ),*/
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
          channelGroupkey: 'workout_channel_group', channelGroupName: 'Workout')
    ],
  );

  runApp(MyApp(androidSdkVersion: androidSdkVersion));
}

String postWorkoutTempNote = "";

Timer? timer;
Duration duration = const Duration();
bool showTimer = false;
int workoutIndex = 0;
int exerciseIndex = 0;
int setIndex = 0;
late bool failed;

late Color headerColor;
late Color backColor;
late Color tileColor;
late Color textColor;
late Color dividerColor;
late Color underlineColor;
late Color circleColor;
late Color emptyCircleTextColor;
late Color activeSwitchColor;
Color greyColor =
    Colors.grey; // runtime error, not initialized when late. weird
late Color borderColor;
late Color navIconColor;
const Color redColor = Color.fromARGB(255, 210, 45, 45);

bool _canVibrate = true;
ValueNotifier<int> _counter = ValueNotifier<int>(0); // to update list page
ValueNotifier<int> _circleCounter = ValueNotifier<int>(0); // to update circles
ValueNotifier<int> _timerCounter =
    ValueNotifier<int>(0); // for timer on workout page
ValueNotifier<int> _plateCounter =
    ValueNotifier<int>(0); // refrehes plates list
ValueNotifier<int> _incrementsCounter = ValueNotifier<int>(0); // for increments
ValueNotifier<int> _graphCounter =
    ValueNotifier<int>(0); // to update graph text
ValueNotifier<int> _progressCounter =
    ValueNotifier<int>(0); // for progress page
ValueNotifier<int> _calendarCounter =
    ValueNotifier<int>(0); // for calendar page
ValueNotifier<int> _themeCounter = ValueNotifier<int>(0); // for dark/light mode

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  String name; // workout name (like "Workout A")
  @HiveField(1)
  List<Exercise> exercises = []; // List of workouts (bench, squat, curl, etc)
  @HiveField(2)
  bool isInitialized = false; // used to fill the reps completed only once

  Workout(this.name); // constructor for name
}

// Hive doesn't work well with lists, so I'm making a custom class
@HiveType(typeId: 3)
class TimerMap extends HiveObject {
  @HiveField(0)
  int time;
  @HiveField(1)
  bool isChecked;

  TimerMap(this.time, this.isChecked);
}

@HiveType(typeId: 4)
class Plate extends HiveObject {
  @HiveField(0)
  double weight;
  @HiveField(1)
  int number;

  Plate(this.weight, this.number);
}

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  // weight, bar weight, increments, sets x reps
  @HiveField(0)
  String name;
  @HiveField(1)
  double weight = 45;
  @HiveField(2)
  double barWeight = 45;
  @HiveField(3)
  double increment = 5;
  @HiveField(4)
  int sets = 5;
  @HiveField(5)
  int reps = 5;
  @HiveField(6)
  List<int> repsCompleted = [];
  @HiveField(7)
  int failed = 0;
  @HiveField(8)
  bool overload = true;
  @HiveField(9)
  bool deload = true;
  @HiveField(10)
  int incrementFrequency = 1;
  @HiveField(11)
  int success = 0;
  @HiveField(12)
  int deloadFrequency = 3;
  @HiveField(13)
  int deloadPercent = 10;
  @HiveField(14)
  String note = "";
  @HiveField(15)
  bool bookmarked = false;

  Exercise(this.name);
}

// used for the edit page, stores all relevant single-workout data
@HiveType(typeId: 2)
class IndivWorkout extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String date;
  @HiveField(2)
  String sortableDate;
  @HiveField(3)
  List<String> exercisesCompleted;
  @HiveField(4)
  List<double> weights;
  @HiveField(5)
  List<int> repsPlanned;
  @HiveField(6)
  List<int> setsPlanned;
  @HiveField(7)
  List<List<int>> repsCompleted;
  @HiveField(8)
  String note;
  @HiveField(9)
  double bodyWeight;

  IndivWorkout(
      this.name,
      this.date,
      this.sortableDate,
      this.exercisesCompleted,
      this.weights,
      this.repsPlanned,
      this.setsPlanned,
      this.repsCompleted,
      this.note,
      this.bodyWeight);
}

Exercise customxyz = Exercise("Custom Exercise");

void defaultState() async {
  showTimer = false;
  _counter.value++;
  _progressCounter.value++;
  _calendarCounter.value++;
  _themeCounter.value++;
  AwesomeNotifications().cancelAll();

  Workout defaultA = Workout("BlockLifts A");
  Workout defaultB = Workout("BlockLifts B");
  Exercise squat = Exercise("Squat");
  Exercise benchPress = Exercise("Bench Press");
  Exercise barbellRow = Exercise("Barbell Row");
  Exercise overheadPress = Exercise("Overhead Press");
  Exercise deadlift = Exercise("Deadlift");
  squat.bookmarked = true;
  benchPress.bookmarked = true;
  deadlift.bookmarked = true;
  deadlift.sets = 1;
  deadlift.reps = 1;
  deadlift.increment = 10;

  defaultA.exercises.add(squat);
  defaultB.exercises.add(squat);
  defaultA.exercises.add(benchPress);
  defaultA.exercises.add(barbellRow);
  defaultB.exercises.add(overheadPress);
  defaultB.exercises.add(deadlift);

  Box<Exercise> exercisesBox = Hive.box<Exercise>('exercisesBox');
  exercisesBox.deleteAll(exercisesBox.keys);
  exercisesBox.add(customxyz);
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

  Box<bool> boolBox = Hive.box<bool>('boolBox');
  boolBox.deleteAll(boolBox.keys);
  boolBox.add(true);
  boolBox.add(true);
  boolBox.add(true);
  boolBox.add(true);
  boolBox.add(false);

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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('resetToDefault', false);
}

void incrementCircles(int workoutIndex, int exIdx, int setIdx, bool fail) {
  final workoutsBox = Hive.box<Workout>('workoutsBox');
  final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(workoutIndex);
  final boolBox = Hive.box<bool>('boolBox');
  bool showNotification = false;

  void addTime(Timer? timer) {
    const addSeconds = 0;
    final seconds = duration.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      duration = Duration(seconds: seconds);
    }
  }

  void startTimer(Timer? timer) {
    timer?.cancel();
    duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  // failed button clicked from notification
  if (fail) {
    if (exIdx == tempWorkout!.exercises.length - 1 &&
        setIdx == tempWorkout.exercises[exIdx].sets - 1) {
      AwesomeNotifications().cancelAll();
      showTimer = false;
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 2;
      tempWorkout.save();
    } else {
      // starts timer
      if (boolBox.getAt(1)!) {
        showTimer = true;
      }
      showNotification = true;
      startTimer(timer);
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 2;
      tempWorkout.save();
      failed = true;
    }
  } else {
    // loops around
    if (tempWorkout!.exercises[exIdx].repsCompleted[setIdx] == 0) {
      AwesomeNotifications().cancelAll();
      showTimer = false;

      tempWorkout.exercises[exIdx].repsCompleted[setIdx] =
          tempWorkout.exercises[exIdx].reps + 1;
      tempWorkout.save();
      // last exercise, last rep, don't show timer
    } else if (exIdx == tempWorkout.exercises.length - 1 &&
        setIdx == tempWorkout.exercises[exIdx].sets - 1) {
      AwesomeNotifications().cancelAll();
      showTimer = false;
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 1;
      tempWorkout.save();
    } else {
      // starts timer
      if (boolBox.getAt(1)!) {
        showTimer = true;
      }
      showNotification = true;
      startTimer(timer);
      tempWorkout.exercises[exIdx].repsCompleted[setIdx] -= 1;
      tempWorkout.save();
      if (tempWorkout.exercises[exIdx].repsCompleted[setIdx] ==
          tempWorkout.exercises[exIdx].reps) {
        failed = false;
      } else {
        failed = true;
      }
    }
  }

  if (showNotification == true) {
    createNotification(exIdx, setIdx);
  }

  // if last set, set to 0
  if (setIdx == workoutsBox.getAt(workoutIndex)!.exercises[exIdx].sets - 1) {
    setIndex = -1;
    // if not last exercise
    if (exIdx != workoutsBox.getAt(workoutIndex)!.exercises.length - 1) {
      ++exerciseIndex;
    }
  } else {
    ++setIndex;
  }
  _circleCounter.value++;
  _timerCounter.value++;
}

// if seconds is equal to any time in list of custom times, play sound
void checkTime(int seconds) {
  Box<TimerMap> successTimerBox = Hive.box<TimerMap>('successTimerBox');
  Box<TimerMap> failTimerBox = Hive.box<TimerMap>('failTimerBox');
  Box<bool> boolBox = Hive.box<bool>('boolBox');

  if (!failed) {
    for (int i = 0; i < successTimerBox.length; i++) {
      if (seconds == successTimerBox.getAt(i)!.time) {
        if (successTimerBox.getAt(i)!.isChecked) {
          if (_canVibrate && boolBox.getAt(3)!) {
            Vibrate.vibrate();
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
        if (_canVibrate && boolBox.getAt(3)!) {
          /*AwesomeNotifications().createNotification(
              content: NotificationContent(
            id: 1234,
            channelKey: 'timer_channel',
            title: "Timer",
            payload: {"name": "BlockLifts"},
            autoDismissible: true,
            locked: false,
            largeIcon: 'resource://drawable/notification_icon',
            roundedLargeIcon: false,
            notificationLayout: NotificationLayout.Default,
          ));*/
          Vibrate.vibrate();
        }
        if (boolBox.getAt(2)!) {
          playRemoteFile();
        }
      }
    }
  }
}

void playRemoteFile() {
  AudioCache player = AudioCache();
  player.play("workout_alarm.mp3");
}

void createNotification(int exIdx, int setIdx) {
  final workoutsBox = Hive.box<Workout>('workoutsBox');
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  AwesomeNotifications().createNotification(
      content: NotificationContent(
        // workout status, no timer
        id: 123,
        channelKey: 'workout_channel',
        title: "$minutes:$seconds - Rest ",
        body: setIdx ==
                workoutsBox.getAt(workoutIndex)!.exercises[exIdx].sets - 1
            ? workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].weight %
                        1 ==
                    0
                ? "${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].name} ${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].reps}×${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].weight.toInt()}lb - Set 1/${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].sets}"
                : "${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].name} ${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].reps}×${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].weight}lb - Set 1/${workoutsBox.getAt(workoutIndex)!.exercises[exIdx + 1].sets}"
            : workoutsBox.getAt(workoutIndex)!.exercises[exIdx].weight % 1 == 0
                ? "${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].name} ${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].reps}×${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].weight.toInt()}lb - Set ${setIdx + 2}/${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].sets}"
                : "${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].name} ${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].reps}×${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].weight}lb - Set ${setIdx + 2}/${workoutsBox.getAt(workoutIndex)!.exercises[exIdx].sets}",
        payload: {"name": "BlockLifts"},
        autoDismissible: false,
        locked: true,
        largeIcon: 'resource://drawable/notification_icon',
        roundedLargeIcon: true,
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

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.androidSdkVersion}) : super(key: key);

  final int androidSdkVersion;
  final Box<bool> boolBox = Hive.box<bool>('boolBox');

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().actionStream.listen((action) {
      if (action.buttonKeyPressed == "done") {
        incrementCircles(workoutIndex, exerciseIndex, setIndex + 1, false);
      } else if (action.buttonKeyPressed == "failed") {
        incrementCircles(workoutIndex, exerciseIndex, setIndex + 1, true);
      }
    });

    return ValueListenableBuilder(
        valueListenable: _themeCounter,
        builder: (_, model, __) {
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ));
          if (boolBox.getAt(0)!) {
            // dark mode
            backColor = Colors.black;
            headerColor = Colors.black;
            tileColor = const Color.fromARGB(255, 29, 29, 29);
            textColor = Colors.white;
            dividerColor = const Color.fromARGB(133, 65, 64, 64);
            underlineColor = Colors.white.withOpacity(.7);
            circleColor = const Color.fromARGB(255, 38, 38, 38);
            emptyCircleTextColor = const Color.fromARGB(255, 103, 103, 103);
            greyColor = const Color.fromARGB(255, 165, 165, 165);
            borderColor = const Color.fromARGB(255, 62, 62, 62);
            navIconColor = const Color.fromARGB(255, 176, 176, 176);
            activeSwitchColor = Colors.white;
          } else {
            // light mode
            backColor = Colors.white;
            headerColor = Colors.white;
            tileColor = Colors.white;
            textColor = Colors.black;
            dividerColor = greyColor;
            underlineColor = const Color.fromARGB(103, 0, 0, 0);
            circleColor = const Color.fromARGB(255, 238, 238, 238);
            emptyCircleTextColor = const Color.fromARGB(255, 199, 199, 199);
            greyColor = const Color.fromARGB(255, 108, 108, 108);
            borderColor = const Color.fromARGB(255, 224, 224, 224);
            navIconColor = const Color.fromARGB(255, 87, 87, 87);
            activeSwitchColor = const Color.fromARGB(255, 49, 48, 48);
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BlockLifts',
            theme: ThemeData(
              // light theme
              useMaterial3: true,
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(width: 0.0, style: BorderStyle.none)),
              ),
              textSelectionTheme: const TextSelectionThemeData(
                selectionHandleColor: Colors.black,
                cursorColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              backgroundColor: Colors.black,
              brightness: Brightness.dark,
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(width: 0.0, style: BorderStyle.none)),
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionHandleColor: Colors.white.withOpacity(.5),
                cursorColor: Colors.white.withOpacity(.5),
              ),
            ),
            themeMode: boolBox.getAt(0)! ? ThemeMode.dark : ThemeMode.light,
            home: ScrollConfiguration(
              behavior: CustomScrollBehavior(
                androidSdkVersion: androidSdkVersion,
              ),
              child: const HomePage(),
            ),
          );
        });
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  const CustomScrollBehavior({required this.androidSdkVersion}) : super();
  final int androidSdkVersion;
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
        if (androidSdkVersion > 30) {
          return StretchingOverscrollIndicator(
            axisDirection: details.direction,
            child: child,
          );
        }
        continue glow;
      glow:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          axisDirection: details.direction,
          color: Theme.of(context).colorScheme.secondary,
          child: child,
        );
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
  // creating State Object of MyWidget
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
  // creating State Object of MyWidget
}

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);
  @override
  _HistoryState createState() => _HistoryState();
  // creating State Object of MyWidget
}

class Progress extends StatefulWidget {
  const Progress({Key? key}) : super(key: key);
  @override
  _ProgressState createState() => _ProgressState();
  // creating State Object of MyWidget
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
  // creating State Object of MyWidget
}

class GraphPage extends StatefulWidget {
  final int index;
  const GraphPage(this.index, {Key? key}) : super(key: key);
  @override
  _GraphPageState createState() => _GraphPageState();
}

class GraphBuilderPage extends StatefulWidget {
  final int exIndex;
  final int duration;
  const GraphBuilderPage(this.exIndex, this.duration, {Key? key})
      : super(key: key);
  @override
  _GraphBuilderState createState() => _GraphBuilderState();
}

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  _TimerState createState() => _TimerState();
  // creating State Object of MyWidget
}

class SetTimerPage extends StatefulWidget {
  // a value of 0 corresponds to success timer, 1 to fail timer
  final int index;
  const SetTimerPage(this.index, {Key? key}) : super(key: key);
  @override
  _SetTimerState createState() => _SetTimerState();
  // creating State Object of MyWidget
}

class PlatesPage extends StatefulWidget {
  const PlatesPage({Key? key}) : super(key: key);
  @override
  _PlatesState createState() => _PlatesState();
  // creating State Object of MyWidget
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
  // creating State Object of MyWidget
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
  // creating State Object of MyWidget
}

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);
  @override
  _NotesState createState() => _NotesState();
  // creating State Object of MyWidget
}

class WorkoutNotesPage extends StatefulWidget {
  const WorkoutNotesPage({Key? key}) : super(key: key);
  @override
  _WorkoutNotesState createState() => _WorkoutNotesState();
  // creating State Object of MyWidget
}

class PostWorkoutNotesPage extends StatefulWidget {
  final int index;
  const PostWorkoutNotesPage(this.index, {Key? key}) : super(key: key);
  @override
  _PostWorkoutNotesState createState() => _PostWorkoutNotesState();
  // creating State Object of MyWidget
}

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);
  @override
  _EditState createState() => _EditState();
  // creating State Object of MyWidget
}

class WorkoutPage extends StatefulWidget {
  final int index;
  const WorkoutPage(this.index, {Key? key}) : super(key: key);
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
  // creating State Object of MyWidget
}

class EditWorkoutPage extends StatefulWidget {
  final int index;
  const EditWorkoutPage(this.index, {Key? key}) : super(key: key);
  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
  // creating State Object of MyWidget
}

class EditExercisePage extends StatefulWidget {
  final int index;

  const EditExercisePage(this.index, {Key? key}) : super(key: key);
  @override
  _EditExercisePageState createState() => _EditExercisePageState();
  // creating State Object of MyWidget
}

class IncrementsPage extends StatefulWidget {
  final int index;

  const IncrementsPage(this.index, {Key? key}) : super(key: key);
  @override
  _IncrementsPageState createState() => _IncrementsPageState();
  // creating State Object of MyWidget
}

class PostWorkoutEditPage extends StatefulWidget {
  final int index;
  final List<List<int>> copyRepsCompleted;

  const PostWorkoutEditPage(this.index, this.copyRepsCompleted, {Key? key})
      : super(key: key);
  @override
  _PostWorkoutEditState createState() => _PostWorkoutEditState();
  // creating State Object of MyWidget
}

class _HomePageState extends State<HomePage> {
  // home page
  int _selectedIndex = 0;
  late final Box<bool> boolBox;

  @override
  void initState() {
    boolBox = Hive.box<bool>('boolBox');
    _init();
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed && boolBox.getAt(4)! == false) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Allow Notifications', style: TextStyle(fontSize: 20)),
              content: const Text(
                  'BlockLifts would like to send you notifications during workouts', style: TextStyle(fontSize: 15)),
              actions: [
                TextButton(
                  onPressed: () {
                    boolBox.putAt(4, true);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((_) => Navigator.pop(context));
                  },
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        else {
          boolBox.putAt(4, true);
        }
      },
    );
    super.initState();
  }

  Future<void> _init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = const <Widget>[
      Home(),
      History(),
      Progress(),
      Settings(),
    ];
    return ValueListenableBuilder<int>(
        valueListenable: _themeCounter,
        builder: (context, index, child) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              brightness: Brightness.dark,
            ),
            child: Scaffold(
              body: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: tileColor,
                selectedFontSize: 15,
                selectedItemColor: redColor,
                unselectedItemColor: navIconColor,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    label: "Home",
                    icon: Icon(Icons.home),
                  ),
                  BottomNavigationBarItem(
                    label: "History",
                    icon: Icon(Icons.date_range),
                  ),
                  BottomNavigationBarItem(
                    label: "Progress",
                    icon: Icon(Icons.line_axis),
                  ),
                  BottomNavigationBarItem(
                    label: "Settings",
                    icon: Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _HomeState extends State<Home> {
  late final Box<Workout> workoutsBox;
  late final Box<int> counterBox;
  late final Box<bool> boolBox;
  late dynamic counter;

  @override
  void initState() {
    super.initState();
    workoutsBox = Hive.box<Workout>('workoutsBox');
    counterBox = Hive.box<int>('counterBox');
    boolBox = Hive.box<bool>('boolBox');
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  void addTime(Timer? timer) {
    _timerCounter.value++;
    const addSeconds = 1;
    final seconds = duration.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      duration = Duration(seconds: seconds);
      // create notif every second, display time
      if (showTimer == true) {
        createNotification(exerciseIndex, setIndex);
      }
      // checks every second if sound should be played
      if (showTimer) {
        checkTime(duration.inSeconds);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _themeCounter,
        builder: (context, index, child) {
          return Scaffold(
            backgroundColor: backColor,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: headerColor,
              title: const Text("BlockLifts"),
              titleTextStyle: TextStyle(fontSize: 22, color: textColor),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("Edit"),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => const Edit()))
                        .then((value) {
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
            body: ValueListenableBuilder(
                valueListenable: _counter,
                builder: (context, value, child) {
                  counter = counterBox.getAt(0);
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: ListView(
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          for (int i = counter; i < workoutsBox.length; i++)
                            buildTile(i),
                          for (int i = 0; i < counter; i++) buildTile(i),
                        ]),
                  );
                }),
            floatingActionButton: SizedBox(
              width: 150,
              height: 50,
              child: OutlinedButton(
                child: const Text("Start Workout"),
                style: OutlinedButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: redColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
                onPressed: () {
                  // if statement prevents excessive adding to list
                  if (workoutsBox.getAt(counter)!.isInitialized == false) {
                    // change from 0 to counter (index of first workout that's up)
                    for (int i = 0;
                        i < workoutsBox.getAt(counter)!.exercises.length;
                        ++i) {
                      for (int j = 0;
                          j < workoutsBox.getAt(counter)!.exercises[i].sets;
                          j++) {
                        // repsCompleted initialized with initial reps value
                        workoutsBox
                            .getAt(counter)!
                            .exercises[i]
                            .repsCompleted
                            .add(workoutsBox.getAt(counter)!.exercises[i].reps +
                                1);
                      }
                    }
                    workoutsBox.getAt(counter)!.isInitialized = true;
                  }
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => WorkoutPage(counter)))
                      .then((value) {
                    setState(() {});
                  });
                },
              ),
            ),
          );
        });
  }

  Widget buildTile(int i) {
    return Column(children: <Widget>[
      GestureDetector(
          onTap: () {
            // if statement prevents excessive adding to list
            if (workoutsBox.getAt(i)!.isInitialized == false) {
              for (int j = 0; j < workoutsBox.getAt(i)!.exercises.length; ++j) {
                for (int k = 0;
                    k < workoutsBox.getAt(i)!.exercises[j].sets;
                    k++) {
                  // repsCompleted initialized with initial reps value
                  workoutsBox
                      .getAt(i)!
                      .exercises[j]
                      .repsCompleted
                      .add(workoutsBox.getAt(i)!.exercises[j].reps + 1);
                }
              }
              workoutsBox.getAt(i)!.isInitialized = true;
            }
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WorkoutPage(i)))
                .then((value) {
              setState(() {});
            });
          },
          child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: i == counter
                    ? Border.all(color: redColor)
                    : Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
                color: tileColor,
              ),
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(workoutsBox.getAt(i)!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          color: greyColor,
                        )),
                  ),
                  const Divider(height: 15, color: Colors.transparent),
                  Column(children: [
                    for (int j = 0;
                        j < workoutsBox.getAt(i)!.exercises.length;
                        j++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text(workoutsBox.getAt(i)!.exercises[j].name,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: textColor,
                                      )),
                            ),
                          ),
                          if (workoutsBox.getAt(i)!.exercises[j].weight % 1 ==
                              0)
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${workoutsBox.getAt(i)!.exercises[j].sets}×${workoutsBox.getAt(i)!.exercises[j].reps} ${workoutsBox.getAt(i)!.exercises[j].weight ~/ 1}lb",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: textColor,
                                        ))))
                          else
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${workoutsBox.getAt(i)!.exercises[j].sets}×${workoutsBox.getAt(i)!.exercises[j].reps} ${workoutsBox.getAt(i)!.exercises[j].weight.toString()}lb",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: textColor,
                                        )))),
                        ]),
                        Divider(
                            // larger divider if not at end of list
                            height:
                                j != workoutsBox.getAt(i)!.exercises.length - 1
                                    ? 25
                                    : 0,
                            color: Colors.transparent),
                      ])
                  ]),
                ],
              ))),
      const Divider(height: 5, color: Colors.transparent),
    ]);
  }
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _themeCounter,
        builder: (context, index, child) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              brightness: Brightness.dark,
            ),
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: headerColor,
                  title: const Text("History"),
                  titleTextStyle: TextStyle(fontSize: 22, color: textColor),
                  bottom: TabBar(
                    indicatorColor: redColor,
                    labelColor: textColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(
                        text: 'List',
                      ),
                      Tab(
                        text: 'Calendar',
                      ),
                      Tab(
                        text: 'Notes',
                      ),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    ListPage(),
                    CalendarPage(),
                    NotesPage(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _MyData {
  final double xval;
  final double weight;

  _MyData({
    required this.xval,
    required this.weight,
  });
}

class _ProgressState extends State<Progress> {
  late final Box<Exercise> exercisesBox;
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _themeCounter,
        builder: (context, index, child) {
          return Scaffold(
              backgroundColor: backColor,
              appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                backgroundColor: headerColor,
                title: const Text("Progress"),
                titleTextStyle: TextStyle(fontSize: 22, color: textColor),
              ),
              body: ValueListenableBuilder(
                  valueListenable: _progressCounter,
                  builder: (context, value, child) {
                    int bookmarkCounter = 0;
                    for (int i = 1; i < exercisesBox.length; i++) {
                      if (exercisesBox.getAt(i)!.bookmarked) {
                        bookmarkCounter++;
                      }
                    }
                    return ListView(
                      children: <Widget>[
                        // i = 0 is "Custom Exercise"
                        for (int i = 1; i < exercisesBox.length; i++)
                          if (exercisesBox.getAt(i)!.bookmarked)
                            SizedBox(
                              height: 80,
                              width: double.infinity,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      textStyle: const TextStyle(fontSize: 16)),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Row(children: <Widget>[
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Row(children: <Widget>[
                                                Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7),
                                                  child: RichText(
                                                      text: TextSpan(
                                                        text: exercisesBox
                                                            .getAt(i)!
                                                            .name,
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            color: textColor),
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: const Icon(
                                                    Icons.bookmark,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: exercisesBox
                                                              .getAt(i)!
                                                              .weight %
                                                          1 ==
                                                      0
                                                  ? Text(
                                                      "${exercisesBox.getAt(i)!.weight.toInt().toString()}lb",
                                                      style: TextStyle(
                                                          color: greyColor))
                                                  : Text(
                                                      "${exercisesBox.getAt(i)!.weight.toString()}lb",
                                                      style: TextStyle(
                                                          color: greyColor)),
                                            ),
                                          ]),
                                    ]),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => GraphPage(i)))
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }),
                            ),
                        if (bookmarkCounter > 0)
                          Divider(
                              height: 10,
                              thickness: 1,
                              color: dividerColor,
                              indent: 10,
                              endIndent: 10),
                        // body weight
                        SizedBox(
                            height: 80,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  textStyle: const TextStyle(fontSize: 16)),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Row(children: <Widget>[
                                  Expanded(
                                    child: Column(children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Body Weight",
                                          style: TextStyle(
                                              fontSize: 17, color: textColor),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: indivWorkoutsBox.isEmpty
                                            ? Text("150lb",
                                                style:
                                                    TextStyle(color: greyColor))
                                            : indivWorkoutsBox
                                                            .getAt(
                                                                indivWorkoutsBox
                                                                        .length -
                                                                    1)!
                                                            .bodyWeight %
                                                        1 ==
                                                    0
                                                ? Text(
                                                    "${indivWorkoutsBox.getAt(indivWorkoutsBox.length - 1)!.bodyWeight.toInt().toString()}lb",
                                                    style: TextStyle(
                                                        color: greyColor))
                                                : Text(
                                                    "${indivWorkoutsBox.getAt(indivWorkoutsBox.length - 1)!.bodyWeight.toString()}lb",
                                                    style: TextStyle(
                                                        color: greyColor)),
                                      ),
                                    ]),
                                  ),
                                ]),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const GraphPage(-1)));
                              },
                            )),
                        if (bookmarkCounter < exercisesBox.length - 1)
                          Divider(
                              height: 10,
                              thickness: 1,
                              color: dividerColor,
                              indent: 10,
                              endIndent: 10),
                        for (int i = 1; i < exercisesBox.length; i++)
                          if (!exercisesBox.getAt(i)!.bookmarked)
                            SizedBox(
                              height: 80,
                              width: double.infinity,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      textStyle: const TextStyle(fontSize: 16)),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Row(children: <Widget>[
                                      Expanded(
                                        child: Column(children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                exercisesBox.getAt(i)!.name,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: textColor),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: exercisesBox
                                                            .getAt(i)!
                                                            .weight %
                                                        1 ==
                                                    0
                                                ? Text(
                                                    "${exercisesBox.getAt(i)!.weight.toInt().toString()}lb",
                                                    style: TextStyle(
                                                        color: greyColor))
                                                : Text(
                                                    "${exercisesBox.getAt(i)!.weight.toString()}lb",
                                                    style: TextStyle(
                                                        color: greyColor)),
                                          ),
                                        ]),
                                      ),
                                    ]),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GraphPage(i)));
                                  }),
                            ),
                      ],
                    );
                  }));
        });
  }
}

class _SettingsState extends State<Settings> {
  late final Box<bool> boolBox;
  late final Box<Plate> platesBox;
  String platesString = "";

  void toggleSwitch(bool value) {
    if (boolBox.getAt(0) == false) {
      setState(() {
        boolBox.putAt(0, true);
      });
      _themeCounter.value++;
      _calendarCounter.value++;
    } else {
      setState(() {
        boolBox.putAt(0, false);
      });
      _themeCounter.value++;
      _calendarCounter.value++;
    }
  }

  String platesToString() {
    String output = '';
    for (int i = 0; i < platesBox.length; ++i) {
      output += platesBox.getAt(i)!.number.toString();
      output += '×';
      platesBox.getAt(i)!.weight % 1 == 0
          ? output += platesBox.getAt(i)!.weight.toInt().toString()
          : output += platesBox.getAt(i)!.weight.toString();
      i == platesBox.length - 1 ? output += 'lb' : output += ' ⋅ ';
    }
    return output;
  }

  @override
  void initState() {
    super.initState();
    boolBox = Hive.box<bool>('boolBox');
    platesBox = Hive.box<Plate>('platesBox');
  }

  @override
  Widget build(BuildContext context) {
    platesString = platesToString();
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: headerColor,
        title: const Text("Settings"),
        titleTextStyle: TextStyle(fontSize: 22, color: textColor),
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 80,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text("Dark Mode", style: TextStyle(color: textColor)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      inactiveThumbColor: greyColor,
                      inactiveTrackColor:
                          const Color.fromARGB(255, 207, 207, 207),
                      activeColor: activeSwitchColor,
                      activeTrackColor: greyColor,
                      value: boolBox.getAt(0)!,
                      onChanged: toggleSwitch,
                    ),
                  ),
                ),
              ]),
            ),
            onPressed: (() => toggleSwitch(false)),
          ),
        ),
        SizedBox(
          height: 88,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Timer", style: TextStyle(color: textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: boolBox.getAt(1)! == true
                          ? Text("On", style: TextStyle(color: greyColor))
                          : Text("Off", style: TextStyle(color: greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => const TimerPage()))
                  .then((value) {
                setState(() {});
              });
            },
          ),
        ),
        SizedBox(
          height: 92,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Plates", style: TextStyle(color: textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(platesString,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => const PlatesPage()))
                  .then((value) {
                setState(() {});
              });
            },
          ),
        ),
        SizedBox(
          height: 80,
          width: double.infinity,
          child: TextButton(
              style: TextButton.styleFrom(
                  primary: redColor, textStyle: const TextStyle(fontSize: 16)),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Reset", style: TextStyle(color: redColor))),
              ),
              onPressed: () {
                setState(() {
                  defaultState();
                });
              }),
        )
      ]),
    );
  }
}

class _GraphPageState extends State<GraphPage> {
  // widget.index of -1 means body weight
  late final Box<Exercise> exercisesBox;

  @override
  void initState() {
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: widget.index == -1
              ? const Text("Body Weight")
              : Text(exercisesBox.getAt(widget.index)!.name),
          titleTextStyle: TextStyle(fontSize: 22, color: textColor),
          actions: <Widget>[
            if (widget.index != -1)
              IconButton(
                icon: exercisesBox.getAt(widget.index)!.bookmarked
                    ? const Icon(Icons.bookmark)
                    : const Icon(Icons.bookmark_border),
                color: exercisesBox.getAt(widget.index)!.bookmarked
                    ? Colors.orange
                    : textColor,
                iconSize: 24,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  exercisesBox.getAt(widget.index)!.bookmarked =
                      !exercisesBox.getAt(widget.index)!.bookmarked;
                  exercisesBox.getAt(widget.index)!.save();
                  _progressCounter.value++;
                  setState(() {});
                },
              ),
          ],
          bottom: TabBar(
            indicatorColor: redColor,
            labelColor: textColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                text: '1M',
              ),
              Tab(
                text: '3M',
              ),
              Tab(
                text: '6M',
              ),
              Tab(
                text: '1Y',
              ),
              Tab(
                text: '2Y',
              ),
              Tab(
                text: '∞',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GraphBuilderPage(widget.index, 1),
            GraphBuilderPage(widget.index, 3),
            GraphBuilderPage(widget.index, 6),
            GraphBuilderPage(widget.index, 12),
            GraphBuilderPage(widget.index, 24),
            GraphBuilderPage(widget.index, 25), // infinite
          ],
        ),
      ),
    );
  }
}

class _GraphBuilderState extends State<GraphBuilderPage> {
  // widget.exIndex of -1 means body weight
  late final Box<Exercise> exercisesBox;
  late final Box<IndivWorkout> indivWorkoutsBox;
  late List<_MyData> _data;
  double date = 0;
  double graphWeight = 0;
  String graphDate = "";
  double minWeight = 0;
  double maxWeight = 0;

  List<_MyData> _generateData() {
    final List<_MyData> data = <_MyData>[];
    DateTime now = DateTime.now();
    late final DateTime start;
    int dateRange = 0;

    if (widget.duration == 1) {
      start = now.subtract(const Duration(days: 30));
    } else if (widget.duration == 3) {
      start = now.subtract(const Duration(days: 90));
    } else if (widget.duration == 6) {
      start = now.subtract(const Duration(days: 180));
    } else if (widget.duration == 12) {
      start = now.subtract(const Duration(days: 365));
    } else if (widget.duration == 24) {
      start = now.subtract(const Duration(days: 730));
    } else if (widget.duration == 25) {
      start = DateTime(1900);
    }
    // this is the starting date that we compare workout dates to
    // if workout date >= dateRange, it's in range and added to the graph
    dateRange = int.parse(DateFormat('yyyyMMdd').format(start));

    for (int i = 0; i < indivWorkoutsBox.length; ++i) {
      if (int.parse(indivWorkoutsBox.getAt(i)!.sortableDate) >= dateRange) {
        String tempDate = indivWorkoutsBox.getAt(i)!.sortableDate;
        date = DateTime.parse(tempDate).millisecondsSinceEpoch.toDouble();
        DateTime dateToFormat =
            DateTime.fromMillisecondsSinceEpoch(date.toInt());
        if (widget.exIndex == -1) {
          data.add(_MyData(
              xval: date, weight: indivWorkoutsBox.getAt(i)!.bodyWeight));
          graphWeight = indivWorkoutsBox.getAt(i)!.bodyWeight;
          graphDate = DateFormat('d MMM yyyy').format(dateToFormat);
          if (indivWorkoutsBox.getAt(i)!.bodyWeight > maxWeight ||
              maxWeight == 0) {
            maxWeight = indivWorkoutsBox.getAt(i)!.bodyWeight;
          }
          if (indivWorkoutsBox.getAt(i)!.bodyWeight < minWeight ||
              minWeight == 0) {
            minWeight = indivWorkoutsBox.getAt(i)!.bodyWeight;
          }
        } else {
          for (int j = 0;
              j < indivWorkoutsBox.getAt(i)!.exercisesCompleted.length;
              j++) {
            if (indivWorkoutsBox.getAt(i)!.exercisesCompleted[j] ==
                exercisesBox.getAt(widget.exIndex)!.name) {
              data.add(_MyData(
                  xval: date, weight: indivWorkoutsBox.getAt(i)!.weights[j]));
              graphWeight = indivWorkoutsBox.getAt(i)!.weights[j];
              graphDate = DateFormat('d MMM yyyy').format(dateToFormat);
              if (indivWorkoutsBox.getAt(i)!.weights[j] > maxWeight ||
                  maxWeight == 0) {
                maxWeight = indivWorkoutsBox.getAt(i)!.weights[j];
              }
              if (indivWorkoutsBox.getAt(i)!.weights[j] < minWeight ||
                  minWeight == 0) {
                minWeight = indivWorkoutsBox.getAt(i)!.weights[j];
              }
            }
          }
        }
      }
    }
    return data;
  }

  @override
  void initState() {
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    _data = _generateData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      body: _data.isNotEmpty
          ? Column(
              children: <Widget>[
                ValueListenableBuilder(
                    valueListenable: _graphCounter,
                    builder: (context, value, child) {
                      return Container(
                          padding: const EdgeInsets.only(left: 25, top: 25),
                          child: Column(children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: graphWeight % 1 == 0
                                  ? Text("${graphWeight.toInt().toString()}lb",
                                      style: const TextStyle(fontSize: 18))
                                  : Text("${graphWeight.toString()}lb",
                                      style: const TextStyle(fontSize: 18)),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(graphDate,
                                  style: TextStyle(
                                      fontSize: 14, color: greyColor)),
                            ),
                          ]));
                    }),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: _graph(),
                      padding: const EdgeInsets.all(25),
                      height: MediaQuery.of(context).size.height * 0.3,
                    ))
              ],
            )
          : Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.only(top: 100),
                child: widget.duration == 25
                    ? const Text("No workouts logged")
                    : widget.duration == 24
                        ? const Text("No workouts logged in the last two years")
                        : widget.duration == 12
                            ? const Text("No workouts logged in the last year")
                            : widget.duration == 1
                                ? const Text(
                                    "No workouts logged in the last month")
                                : Text(
                                    "No workouts logged in the last ${widget.duration} months"),
              ),
            ),
    );
  }

  Widget _graph() {
    final spots = _data
        .asMap()
        .entries
        .map((element) => FlSpot(
              element.value.xval,
              element.value.weight,
            ))
        .toList();

    return LineChart(
      LineChartData(
        borderData: FlBorderData(
          show: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: Colors.orange,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: const Alignment(0, -1),
                end: const Alignment(0, 1),
                colors: [
                  Colors.orange.withOpacity(0.2),
                  Colors.orange.withOpacity(0.01)
                ],
              ),
            ),
            dotData: FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.orange,
                  strokeWidth: 0,
                );
              },
            ),
          ),
        ],
        minX: _data.length == 1 ? date - 1 : _data.first.xval,
        maxX: _data.length == 1 ? date + 1 : _data.last.xval,
        minY: minWeight * 0.994,
        maxY: maxWeight * 1.006,
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: rightTitleWidgets,
              reservedSize: 45,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: greyColor,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        lineTouchData: LineTouchData(
            enabled: true,
            touchSpotThreshold: 10000, // snaps to nearest point
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
              _graphCounter.value++;
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map(
                  (LineBarSpot touchedSpot) {
                    graphWeight = _data[touchedSpot.spotIndex].weight;
                    int dateInt = _data[touchedSpot.spotIndex].xval.toInt();
                    DateTime tempDate =
                        DateTime.fromMillisecondsSinceEpoch(dateInt);
                    graphDate = DateFormat('d MMM yyyy').format(tempDate);
                  },
                ).toList();
              },
            ),
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> indicators) {
              return indicators.map(
                (int index) {
                  final line = FlLine(
                    color: Colors.orange,
                    strokeWidth: 1,
                  );
                  return TouchedSpotIndicatorData(
                    line,
                    FlDotData(show: false),
                  );
                },
              ).toList();
            },
            getTouchLineEnd: (_, __) => double.infinity),
      ),
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: greyColor,
      fontSize: 9,
    );
    Widget text;
    if (value < maxWeight * 1.006 && value > minWeight * 0.994) {
      value % 1 == 0
          ? text = Text(value.toInt().toString(), style: style)
          : text = Text(value.toStringAsFixed(2), style: style);
    } else {
      text = const Text("");
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: text,
    );
  }
}

class _TimerState extends State<TimerPage> {
  late final Box<bool> boolBox;
  late final Box<TimerMap> successTimerBox;
  late final Box<TimerMap> failTimerBox;

  String successTimes = '';
  String failTimes = '';

  // timer
  void toggleSwitch(bool value) {
    if (boolBox.getAt(1)! == false) {
      setState(() {
        boolBox.putAt(1, true);
      });
      // set dark theme
    } else {
      setState(() {
        boolBox.putAt(1, false);
      });
      // set light theme
    }
  }

  // ring
  void toggleSwitch2(bool value) {
    if (boolBox.getAt(2)! == false) {
      setState(() {
        boolBox.putAt(2, true);
      });
    } else {
      setState(() {
        boolBox.putAt(2, false);
      });
    }
  }

  // vibration
  void toggleSwitch3(bool value) {
    if (boolBox.getAt(3)! == false) {
      setState(() {
        boolBox.putAt(3, true);
      });
      // set dark theme
    } else {
      setState(() {
        boolBox.putAt(3, false);
      });
      // set light theme
    }
  }

  @override
  void initState() {
    super.initState();
    boolBox = Hive.box<bool>('boolBox');
    successTimerBox = Hive.box<TimerMap>('successTimerBox');
    failTimerBox = Hive.box<TimerMap>('failTimerBox');
  }

  String addTimes(Box<TimerMap> input) {
    String output = '';
    List<int> times = [];
    for (int i = 0; i < input.length; i++) {
      if (input.getAt(i)!.isChecked == true) {
        times.add(input.getAt(i)!.time);
      }
    }
    times.sort();
    for (int i = 0; i < times.length - 1; i++) {
      if (times[i] % 60 == 0) {
        output += (times[i] ~/ 60).toString() + 'min, ';
      } else {
        output += (times[i] ~/ 60).toString() +
            'min ' +
            (times[i] % 60).toString() +
            's, ';
      }
    }
    if (times.isNotEmpty) {
      if (times[times.length - 1] % 60 == 0) {
        output += (times[times.length - 1] ~/ 60).toString() + 'min';
      } else {
        output += (times[times.length - 1] ~/ 60).toString() +
            'min ' +
            (times[times.length - 1] % 60).toString() +
            's';
      }
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    successTimes = addTimes(successTimerBox);
    failTimes = addTimes(failTimerBox);
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: const Text("Timer"),
        titleTextStyle: TextStyle(fontSize: 22, color: textColor),
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 88,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                    child: Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text("Timer", style: TextStyle(color: textColor)),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: boolBox.getAt(1)! == true
                            ? Text("On", style: TextStyle(color: greyColor))
                            : Text("Off", style: TextStyle(color: greyColor)),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        inactiveThumbColor: greyColor,
                        inactiveTrackColor:
                            const Color.fromARGB(255, 207, 207, 207),
                        activeColor: activeSwitchColor,
                        activeTrackColor: greyColor,
                        value: boolBox.getAt(1)!,
                        onChanged: toggleSwitch,
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
            onPressed: (() => toggleSwitch(false)),
          ),
        ),
        boolBox.getAt(1)!
            ? SizedBox(
                height: 88,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: ListView(children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: Column(children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Ring",
                                  style: TextStyle(color: textColor)),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: boolBox.getAt(2)! == true
                                  ? Text("Enabled",
                                      style: TextStyle(color: greyColor))
                                  : Text("Disabled",
                                      style: TextStyle(color: greyColor)),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Switch(
                              inactiveThumbColor: greyColor,
                              inactiveTrackColor:
                                  const Color.fromARGB(255, 207, 207, 207),
                              activeColor: activeSwitchColor,
                              activeTrackColor: greyColor,
                              value: boolBox.getAt(2)!,
                              onChanged: toggleSwitch2,
                            ),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  onPressed: (() => toggleSwitch2(false)),
                ),
              )
            : const SizedBox(),
        boolBox.getAt(1)!
            ? SizedBox(
                height: 88,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: Column(children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Vibration",
                                  style: TextStyle(color: textColor)),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: boolBox.getAt(3)! == true
                                  ? Text("Enabled",
                                      style: TextStyle(color: greyColor))
                                  : Text("Disabled",
                                      style: TextStyle(color: greyColor)),
                            ),
                          ]),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Switch(
                              inactiveThumbColor: greyColor,
                              inactiveTrackColor:
                                  const Color.fromARGB(255, 207, 207, 207),
                              activeColor: activeSwitchColor,
                              activeTrackColor: greyColor,
                              value: boolBox.getAt(3)!,
                              onChanged: toggleSwitch3,
                            ),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  onPressed: (() => toggleSwitch3(false)),
                ),
              )
            : const SizedBox(),
        boolBox.getAt(1)!
            ? SizedBox(
                height: 88,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: <Widget>[
                      Expanded(
                        child: Column(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Success Timer",
                                style: TextStyle(color: textColor)),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(successTimes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: greyColor)),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => const SetTimerPage(0)))
                        .then((value) {
                      setState(() {});
                    });
                  },
                ),
              )
            : const SizedBox(),
        boolBox.getAt(1)!
            ? SizedBox(
                height: 88,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: <Widget>[
                      Expanded(
                        child: Column(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Fail Timer",
                                style: TextStyle(color: textColor)),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(failTimes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: greyColor)),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => const SetTimerPage(1)))
                        .then((value) {
                      setState(() {});
                    });
                  },
                ),
              )
            : const SizedBox(),
      ]),
    );
  }
}

class _SetTimerState extends State<SetTimerPage> {
  // a widget.index value of 0 corresponds to success timer, 1 to fail timer
  List<Widget> mins = [
    for (int i = 0; i < 11; i++) ListTile(title: Text(i.toString())),
  ];
  List<Widget> secs = [
    for (int i = 0; i < 60; i++) ListTile(title: Text(i.toString())),
  ];

  int minutes = 0;
  int seconds = 0;

  late final Box<TimerMap> successTimerBox;
  late final Box<TimerMap> failTimerBox;
  List<int> times = [];

  @override
  void initState() {
    super.initState();
    successTimerBox = Hive.box<TimerMap>('successTimerBox');
    failTimerBox = Hive.box<TimerMap>('failTimerBox');
    if (widget.index == 0) {
      for (int i = 0; i < successTimerBox.length; i++) {
        times.add(successTimerBox.getAt(i)!.time);
      }
    } else {
      for (int i = 0; i < failTimerBox.length; i++) {
        times.add(failTimerBox.getAt(i)!.time);
      }
    }
    times.sort();
  }

  bool isChecked(Box<TimerMap> input, int index) {
    for (int i = 0; i < input.length; i++) {
      if (input.getAt(i)!.time == times[index]) {
        return input.getAt(i)!.isChecked;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: widget.index == 0
            ? const Text("Success Timer")
            : const Text("Fail Timer"),
        titleTextStyle: TextStyle(fontSize: 22, color: textColor),
      ),
      body: ListView(children: <Widget>[
        for (int index = 0; index < times.length; index++)
          ListTile(
            leading: Checkbox(
              value: widget.index == 0
                  ? isChecked(successTimerBox, index)
                  : isChecked(failTimerBox, index),
              activeColor: redColor,
              checkColor: backColor,
              onChanged: (value) {
                setState(() {
                  if (widget.index == 0) {
                    for (int idx = 0; idx < successTimerBox.length; idx++) {
                      if (successTimerBox.getAt(idx)!.time == times[index]) {
                        final tempTime =
                            Hive.box<TimerMap>('successTimerBox').getAt(idx);
                        tempTime!.isChecked = value!;
                        tempTime.save();
                      }
                    }
                  } else {
                    for (int idx = 0; idx < failTimerBox.length; idx++) {
                      if (failTimerBox.getAt(idx)!.time == times[index]) {
                        final tempTime =
                            Hive.box<TimerMap>('failTimerBox').getAt(idx);
                        tempTime!.isChecked = value!;
                        tempTime.save();
                      }
                    }
                  }
                });
              },
            ),
            title: widget.index == 0
                ? times[index] % 60 == 0
                    ? Text("${(times[index] ~/ 60).toString()}min")
                    : Text(
                        "${(times[index] ~/ 60).toString()}min ${(times[index] % 60).toString()}s")
                : times[index] % 60 == 0
                    ? Text("${(times[index] ~/ 60).toString()}min")
                    : Text(
                        "${(times[index] ~/ 60).toString()}min ${(times[index] % 60).toString()}s"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  if (widget.index == 0) {
                    for (int i = 0; i < successTimerBox.length; i++) {
                      if (successTimerBox.getAt(i)!.time == times[index]) {
                        successTimerBox.deleteAt(i);
                      }
                    }
                    times.removeAt(index);
                  } else {
                    for (int i = 0; i < failTimerBox.length; i++) {
                      if (failTimerBox.getAt(i)!.time == times[index]) {
                        failTimerBox.deleteAt(i);
                      }
                    }
                    times.removeAt(index);
                  }
                });
              },
            ),
          ),
      ]),
      floatingActionButton: Align(
        alignment: const Alignment(.93, 1), // custom alignment
        child: SizedBox(
          width: 130,
          height: 50,
          child: OutlinedButton(
            child: const Text("Add Timer"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
              final _minController = FixedExtentScrollController();
              final _secController = FixedExtentScrollController();
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(10),
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                widget.index == 0
                                    ? const Text("Success Timer",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ))
                                    : const Text("Fail Timer",
                                        style: TextStyle(
                                          fontSize: 18,
                                        )),
                                const SizedBox(height: 30),
                                Flexible(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                      SizedBox(
                                          height: 120,
                                          width: 70,
                                          child: CupertinoPicker(
                                            scrollController: _minController,
                                            children: mins,
                                            looping: true,
                                            diameterRatio: 1.25,
                                            selectionOverlay:
                                                Column(children: <Widget>[
                                              Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          top: BorderSide(
                                                color: textColor,
                                                width: 2,
                                              )))),
                                              const SizedBox(height: 50),
                                              Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          top: BorderSide(
                                                color: textColor,
                                                width: 2,
                                              ))))
                                            ]),
                                            itemExtent: 75,
                                            onSelectedItemChanged: (index) => {
                                              minutes = index,
                                            },
                                          )),
                                      const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text("min",
                                              style: TextStyle(
                                                fontSize: 14,
                                              )),
                                        ),
                                      ),
                                      SizedBox(
                                          height: 120,
                                          width: 70,
                                          child: CupertinoPicker(
                                            scrollController: _secController,
                                            children: secs,
                                            looping: true,
                                            diameterRatio: 1.25,
                                            selectionOverlay:
                                                Column(children: <Widget>[
                                              Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          top: BorderSide(
                                                color: textColor,
                                                width: 2,
                                              )))),
                                              const SizedBox(height: 50),
                                              Container(
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          top: BorderSide(
                                                color: textColor,
                                                width: 2,
                                              ))))
                                            ]),
                                            itemExtent: 75,
                                            onSelectedItemChanged: (index) => {
                                              seconds = index,
                                            },
                                          )),
                                      const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text("sec",
                                              style: TextStyle(
                                                fontSize: 14,
                                              )),
                                        ),
                                      ),
                                    ])),
                                const SizedBox(height: 30),
                                Row(children: <Widget>[
                                  const SizedBox(width: 187.4),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("OK"),
                                    onPressed: () {
                                      bool duplicate = false;
                                      setState(() {
                                        times.add(minutes * 60 + seconds);

                                        if (widget.index == 0) {
                                          // check for duplicate time in success timer box
                                          for (int i = 0;
                                              i < successTimerBox.length;
                                              i++) {
                                            if (successTimerBox
                                                    .getAt(i)!
                                                    .time ==
                                                times.last) {
                                              duplicate = true;
                                              times.removeLast();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Timer already exists"),
                                                duration: Duration(seconds: 2),
                                              ));
                                            }
                                          }
                                          if (!duplicate) {
                                            successTimerBox.add(TimerMap(
                                                minutes * 60 + seconds, true));
                                            times.sort();
                                            Navigator.of(context).pop();
                                            minutes = seconds = 0;
                                          }
                                        } else {
                                          // check for duplicate time in fail timer box
                                          for (int i = 0;
                                              i < failTimerBox.length;
                                              i++) {
                                            if (failTimerBox.getAt(i)!.time ==
                                                times.last) {
                                              duplicate = true;
                                              times.removeLast();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Timer already exists"),
                                                duration: Duration(seconds: 2),
                                              ));
                                            }
                                          }
                                          if (!duplicate) {
                                            failTimerBox.add(TimerMap(
                                                minutes * 60 + seconds, true));
                                            Navigator.of(context).pop();
                                            times.sort();
                                            minutes = seconds = 0;
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ]),
                              ]))));
            },
          ),
        ),
      ),
    );
  }
}

class _PlatesState extends State<PlatesPage> {
  late final Box<Plate> platesBox;

  List<int> nums = [for (int i = 0; i < 51; i++) i * 2];

  @override
  void initState() {
    super.initState();
    platesBox = Hive.box<Plate>('platesBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: const Text("Plates"),
          titleTextStyle: TextStyle(fontSize: 22, color: textColor),
        ),
        body: ValueListenableBuilder(
            valueListenable: _plateCounter,
            builder: (context, value, child) {
              return ListView(children: <Widget>[
                for (int i = 0; i < platesBox.length; i++)
                  SizedBox(
                    height: 88,
                    width: double.infinity,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(children: <Widget>[
                            Expanded(
                              child: Column(children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: platesBox.getAt(i)!.weight % 1 == 0
                                        ? Text(
                                            "${platesBox.getAt(i)!.weight.toInt().toString()}lb",
                                            style: TextStyle(color: textColor))
                                        : Text(
                                            "${platesBox.getAt(i)!.weight.toString()}lb",
                                            style:
                                                TextStyle(color: textColor))),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      "${platesBox.getAt(i)!.number} plates",
                                      style: TextStyle(color: greyColor)),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => plateSelector(i));
                        }),
                  )
              ]);
            }),
        floatingActionButton: Align(
            alignment: const Alignment(.93, 1), // custom alignment
            child: SizedBox(
              width: 100,
              height: 50,
              child: OutlinedButton(
                  child: const Text("Add"),
                  style: OutlinedButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: redColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context, builder: (context) => addPlate());
                  }),
            )));
  }

  Widget plateSelector(int i) {
    int tempNumber = platesBox.getAt(i)!.number;
    return StatefulBuilder(builder: (context, _setState) {
      return Dialog(
          insetPadding: const EdgeInsets.fromLTRB(10, 100, 10, 100),
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: platesBox.getAt(i)!.weight % 1 == 0
                      ? Text(
                          "${platesBox.getAt(i)!.weight.toInt().toString()}lb Plates",
                          style: const TextStyle(fontSize: 18))
                      : Text(
                          "${platesBox.getAt(i)!.weight.toString()}lb Plates",
                          style: const TextStyle(fontSize: 18)),
                ),
              ),
              Flexible(
                  child: ListView(children: <Widget>[
                for (var j in nums)
                  RadioListTile<int>(
                      title: Text(j.toString(),
                          style: const TextStyle(fontSize: 15)),
                      activeColor: redColor,
                      dense: true,
                      value: j,
                      groupValue: tempNumber,
                      onChanged: (value) {
                        _setState(() {
                          tempNumber = value!;
                        });
                      }),
              ])),
              Row(children: <Widget>[
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                      child: const Text("Delete"),
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      onPressed: () {
                        platesBox.deleteAt(i);
                        _plateCounter.value++;
                        Navigator.of(context).pop();
                      }),
                ),
                const Expanded(child: Text("")),
                Expanded(
                  child: TextButton(
                      child: const Text("Cancel"),
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
                Expanded(
                  child: TextButton(
                      child: const Text("OK"),
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      onPressed: () {
                        final tempPlate =
                            Hive.box<Plate>('platesBox').getAt(i)!;
                        tempPlate.number = tempNumber;
                        tempPlate.save();
                        _plateCounter.value++;
                        Navigator.of(context).pop();
                      }),
                ),
              ]),
            ]),
          ));
    });
  }

  Widget addPlate() {
    final _myController = TextEditingController();
    _myController.text = "10";
    Box<Plate> platesBox = Hive.box<Plate>('platesBox');

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Add New Plate",
                  style: TextStyle(
                    fontSize: 18,
                  )),
              const Text("Plate weight in LB",
                  style: TextStyle(
                    fontSize: 14,
                  )),
              const SizedBox(height: 10),
              TextField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
                ],
                controller: _myController,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 10),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              Divider(
                color: underlineColor,
                height: 2,
                thickness: 2,
              ),
              const SizedBox(height: 40),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: OutlinedButton(
                      child: const Text("-5lb"),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      onPressed: () {
                        // subtracts 5lb from text box
                        double tempText = double.parse(_myController.text);
                        if (tempText % 1 == 0) {
                          setState(() {
                            if (tempText <= 5) {
                              _myController.text = "0";
                            } else {
                              tempText -= 5;
                              _myController.text = tempText.toInt().toString();
                            }
                            _myController.selection = TextSelection.collapsed(
                                offset: _myController.text.length);
                          });
                        } else {
                          setState(() {
                            if (tempText <= 5) {
                              _myController.text = "0";
                            } else {
                              tempText -= 5;
                              _myController.text = tempText.toString();
                            }
                            _myController.selection = TextSelection.collapsed(
                                offset: _myController.text.length);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 170,
                      height: 50,
                      child: OutlinedButton(
                        child: const Text("+5lb"),
                        style: OutlinedButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                        onPressed: () {
                          // subtracts 5lb from text box
                          double tempText = double.parse(_myController.text);
                          if (tempText % 1 == 0) {
                            setState(() {
                              tempText += 5;
                              _myController.text = tempText.toInt().toString();
                              _myController.selection = TextSelection.collapsed(
                                  offset: _myController.text.length);
                            });
                          } else {
                            setState(() {
                              tempText += 5;
                              _myController.text = tempText.toString();
                              _myController.selection = TextSelection.collapsed(
                                  offset: _myController.text.length);
                            });
                          }
                        },
                      ))
                ],
              ),
              const SizedBox(height: 20),
              Row(children: <Widget>[
                const SizedBox(width: 187.4),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("OK"),
                  onPressed: () {
                    // can't add to middle of hive box, so copy box, insert,
                    // clear box, and fill box
                    final List<Plate> platesList = platesBox.values.toList();
                    double weight = double.parse(_myController.text);
                    int i = 0;
                    while (i < platesBox.length &&
                        weight < platesBox.getAt(i)!.weight) {
                      i++;
                    }
                    if (i == platesBox.length) {
                      if (platesBox.getAt(i - 1)!.weight == weight) {
                        final tempPlate =
                            Hive.box<Plate>('platesBox').getAt(i - 1)!;
                        tempPlate.number += 2;
                        tempPlate.save();
                      } else {
                        platesList.add(Plate(weight, 2));
                      }
                    } else {
                      if (platesBox.getAt(i)!.weight == weight) {
                        final tempPlate =
                            Hive.box<Plate>('platesBox').getAt(i)!;
                        tempPlate.number += 2;
                        tempPlate.save();
                      } else {
                        platesList.insert(i, Plate(weight, 2));
                      }
                    }

                    platesBox.deleteAll(platesBox.keys);

                    for (var plate in platesList) {
                      platesBox.add(plate);
                    }
                    _plateCounter.value++;
                    Navigator.of(context).pop();
                  },
                ),
              ]),
            ]),
      ),
    );
  }
}

class _ListState extends State<ListPage> {
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _themeCounter,
        builder: (context, index, child) {
          return Scaffold(
              backgroundColor: backColor,
              body: ValueListenableBuilder(
                  valueListenable: _counter,
                  builder: (context, value, child) {
                    return ListView(
                        padding: const EdgeInsets.all(10),
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          for (int i = indivWorkoutsBox.length - 1; i >= 0; i--)
                            Column(children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    // workaround to fill (seems to be pass-by-reference, strangely again)
                                    List<List<int>> copyRepsCompleted = [];

                                    for (int j = 0;
                                        j <
                                            indivWorkoutsBox
                                                .getAt(i)!
                                                .repsCompleted
                                                .length;
                                        j++) {
                                      copyRepsCompleted.add([0]);
                                      copyRepsCompleted[j].add(indivWorkoutsBox
                                          .getAt(i)!
                                          .repsCompleted[j][0]);
                                      copyRepsCompleted[j].removeAt(0);
                                      for (int k = 1;
                                          k <
                                              indivWorkoutsBox
                                                  .getAt(i)!
                                                  .repsCompleted[j]
                                                  .length;
                                          k++) {
                                        copyRepsCompleted[j].add(
                                            indivWorkoutsBox
                                                .getAt(i)!
                                                .repsCompleted[j][k]);
                                      }
                                    }
                                    postWorkoutTempNote =
                                        indivWorkoutsBox.getAt(i)!.note;
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                PostWorkoutEditPage(
                                                    i, copyRepsCompleted)))
                                        .then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: Flexible(
                                      child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: borderColor),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: tileColor,
                                          ),
                                          alignment: Alignment.topLeft,
                                          child: Column(children: [
                                            Row(children: <Widget>[
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      indivWorkoutsBox
                                                          .getAt(i)!
                                                          .name,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: greyColor,
                                                      )),
                                                ),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      indivWorkoutsBox
                                                          .getAt(i)!
                                                          .date,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: greyColor,
                                                      )),
                                                ),
                                              ),
                                            ]),
                                            const Divider(
                                                height: 15,
                                                color: Colors.transparent),
                                            Column(children: [
                                              for (int j = 0;
                                                  j <
                                                      indivWorkoutsBox
                                                          .getAt(i)!
                                                          .exercisesCompleted
                                                          .length;
                                                  j++)
                                                Column(children: <Widget>[
                                                  Row(children: <Widget>[
                                                    Expanded(
                                                      flex: 3,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            indivWorkoutsBox
                                                                .getAt(i)!
                                                                .exercisesCompleted[j],
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: textColor,
                                                            )),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 4,
                                                        child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  for (int k = 0;
                                                                      k <
                                                                          indivWorkoutsBox.getAt(i)!.setsPlanned[
                                                                              j];
                                                                      k++)
                                                                    if (k == 5 &&
                                                                        indivWorkoutsBox.getAt(i)!.weights[j] % 1 ==
                                                                            0)
                                                                      Text(
                                                                          "... ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                textColor,
                                                                          ))
                                                                    else if (k ==
                                                                            5 &&
                                                                        indivWorkoutsBox.getAt(i)!.weights[j] % 1 !=
                                                                            0)
                                                                      Text(
                                                                          "... ${indivWorkoutsBox.getAt(i)!.weights[j]}lb",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                textColor,
                                                                          ))
                                                                    else if (k >
                                                                        5)
                                                                      const SizedBox(
                                                                          width:
                                                                              0)
                                                                    else if (k ==
                                                                            indivWorkoutsBox.getAt(i)!.setsPlanned[j] -
                                                                                1 &&
                                                                        indivWorkoutsBox.getAt(i)!.weights[j] % 1 ==
                                                                            0)
                                                                      indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
                                                                              indivWorkoutsBox.getAt(i)!.repsPlanned[j] +
                                                                                  1
                                                                          ? Text(
                                                                              "0 ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16,
                                                                                color: textColor,
                                                                              ))
                                                                          : Text(
                                                                              "${indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]} ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                              style:
                                                                                  TextStyle(
                                                                                fontSize: 16,
                                                                                color: textColor,
                                                                              ))
                                                                    else if (k ==
                                                                            indivWorkoutsBox.getAt(i)!.setsPlanned[j] -
                                                                                1 &&
                                                                        indivWorkoutsBox.getAt(i)!.weights[j] %
                                                                                1 !=
                                                                            0)
                                                                      indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
                                                                              indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1
                                                                          ? Text("0 ${indivWorkoutsBox.getAt(i)!.weights[j]}lb",
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                              ))
                                                                          : Text("${indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]} ${indivWorkoutsBox.getAt(i)!.weights[j]}lb",
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                              ))
                                                                    else
                                                                      indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] == indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1
                                                                          ? const Text("0/",
                                                                              style: TextStyle(
                                                                                fontSize: 16,
                                                                              ))
                                                                          : Text("${indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]}/",
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                              ))
                                                                ])))
                                                  ]),
                                                  Divider(
                                                      // larger divider if not at end of list
                                                      height: j !=
                                                              indivWorkoutsBox
                                                                      .getAt(i)!
                                                                      .exercisesCompleted
                                                                      .length -
                                                                  1
                                                          ? 15
                                                          : 0,
                                                      color:
                                                          Colors.transparent),
                                                ])
                                            ]),
                                          ])))),
                              const Divider(
                                  height: 5, color: Colors.transparent),
                            ])
                        ]);
                  }));
        });
  }
}

class _CalendarState extends State<CalendarPage> {
  late final Box<IndivWorkout> indivWorkoutsBox;
  List<DateTime> datesList = [];
  late DateTime minDate;
  late DateTime minDateMonth;
  late DateTime curDate;
  late DateTime maxDate;

  @override
  void initState() {
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    super.initState();
  }

  void getMinMaxDate() {
    minDate = DateTime.now();
    minDateMonth = DateTime.now();
    curDate = DateTime.now();
    maxDate = DateTime.now();
    while (curDate.month == maxDate.month) {
      maxDate = DateTime(maxDate.year, maxDate.month, maxDate.day + 1);
    }
    maxDate = DateTime(maxDate.year, maxDate.month, maxDate.day - 1);

    if (indivWorkoutsBox.isNotEmpty) {
      String tempDate = indivWorkoutsBox.getAt(0)!.sortableDate;
      double date = DateTime.parse(tempDate).millisecondsSinceEpoch.toDouble();
      minDate = DateTime.fromMillisecondsSinceEpoch(date.toInt());
      minDateMonth = DateTime.fromMillisecondsSinceEpoch(date.toInt());
    }
    while (minDateMonth.month == minDate.month) {
      minDateMonth =
          DateTime(minDateMonth.year, minDateMonth.month, minDateMonth.day - 1);
    }
    minDateMonth =
        DateTime(minDateMonth.year, minDateMonth.month, minDateMonth.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _calendarCounter,
        builder: (context, value, child) {
          getMinMaxDate();
          datesList.clear();
          for (int i = 0; i < indivWorkoutsBox.length; i++) {
            String tempDate = indivWorkoutsBox.getAt(i)!.sortableDate;
            double date =
                DateTime.parse(tempDate).millisecondsSinceEpoch.toDouble();
            DateTime finalDate =
                DateTime.fromMillisecondsSinceEpoch(date.toInt());
            datesList.add(finalDate);
          }
          return Scaffold(
              backgroundColor: backColor,
              body: Column(children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("S", style: TextStyle(color: textColor)))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("M", style: TextStyle(color: textColor)))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("T", style: TextStyle(color: textColor)))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("W", style: TextStyle(color: textColor)))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("T", style: TextStyle(color: textColor)))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("F", style: TextStyle(color: textColor)))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * (1 / 7),
                      child: Center(
                          child:
                              Text("S", style: TextStyle(color: textColor)))),
                ]),
                Expanded(
                    child: PagedVerticalCalendar(
                        invisibleMonthsThreshold: 100,
                        startWeekWithSunday: true,
                        minDate: minDateMonth,
                        maxDate: maxDate,
                        dayBuilder: (context, date) {
                          final eventsThisDay =
                              datesList.where((e) => e == date);
                          return Center(
                              child: CircleAvatar(
                            radius: 26,
                            backgroundColor: eventsThisDay.isNotEmpty
                                ? redColor
                                : Colors.transparent,
                            child: Text(DateFormat('d').format(date),
                                style: TextStyle(
                                    color: date.day > DateTime.now().day &&
                                            date.month >=
                                                DateTime.now().month &&
                                            date.year >= DateTime.now().year
                                        ? greyColor
                                        : eventsThisDay.isEmpty &&
                                                date.day ==
                                                    DateTime.now().day &&
                                                date.month ==
                                                    DateTime.now().month &&
                                                date.year == DateTime.now().year
                                            ? redColor
                                            : textColor)),
                          ));
                        },
                        onDayPressed: (date) {
                          final eventsThisDay =
                              datesList.where((e) => e == date);
                          if (eventsThisDay.isNotEmpty) {
                            int i = datesList.indexOf(date);
                            List<List<int>> copyRepsCompleted = [];

                            for (int j = 0;
                                j <
                                    indivWorkoutsBox
                                        .getAt(i)!
                                        .repsCompleted
                                        .length;
                                j++) {
                              copyRepsCompleted.add([0]);
                              copyRepsCompleted[j].add(indivWorkoutsBox
                                  .getAt(i)!
                                  .repsCompleted[j][0]);
                              copyRepsCompleted[j].removeAt(0);
                              for (int k = 1;
                                  k <
                                      indivWorkoutsBox
                                          .getAt(i)!
                                          .repsCompleted[j]
                                          .length;
                                  k++) {
                                copyRepsCompleted[j].add(indivWorkoutsBox
                                    .getAt(i)!
                                    .repsCompleted[j][k]);
                              }
                            }
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => PostWorkoutEditPage(
                                        i, copyRepsCompleted)))
                                .then((value) {
                              setState(() {});
                            });
                          }
                        },
                        monthBuilder: (context, month, year) {
                          return Container(
                            padding: const EdgeInsets.only(right: 20, top: 20),
                            alignment: Alignment.centerRight,
                            child: Text(
                              DateFormat('MMMM yyyy')
                                  .format(DateTime(year, month)),
                              style: TextStyle(fontSize: 14, color: textColor),
                            ),
                          );
                        })),
              ]));
        });
  }
}

class _NotesState extends State<NotesPage> {
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: _themeCounter,
        builder: (context, index, child) {
          return Scaffold(
              backgroundColor: backColor,
              body: ListView(
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    for (int i = indivWorkoutsBox.length - 1; i >= 0; i--)
                      if (indivWorkoutsBox.getAt(i)!.note !=
                          "") // doesn't show empty notes
                        Column(children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                // workaround to fill (seems to be pass-by-reference, strangely again)
                                List<List<int>> copyRepsCompleted = [];

                                for (int j = 0;
                                    j <
                                        indivWorkoutsBox
                                            .getAt(i)!
                                            .repsCompleted
                                            .length;
                                    j++) {
                                  copyRepsCompleted.add([0]);
                                  copyRepsCompleted[j].add(indivWorkoutsBox
                                      .getAt(i)!
                                      .repsCompleted[j][0]);
                                  copyRepsCompleted[j].removeAt(0);
                                  for (int k = 1;
                                      k <
                                          indivWorkoutsBox
                                              .getAt(i)!
                                              .repsCompleted[j]
                                              .length;
                                      k++) {
                                    copyRepsCompleted[j].add(indivWorkoutsBox
                                        .getAt(i)!
                                        .repsCompleted[j][k]);
                                  }
                                }
                                postWorkoutTempNote =
                                    indivWorkoutsBox.getAt(i)!.note;
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            PostWorkoutEditPage(
                                                i, copyRepsCompleted)))
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              child: Flexible(
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(6),
                                        color: tileColor,
                                      ),
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        children: [
                                          Row(children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    indivWorkoutsBox
                                                        .getAt(i)!
                                                        .name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: greyColor,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    indivWorkoutsBox
                                                        .getAt(i)!
                                                        .date,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: greyColor,
                                                    )),
                                              ),
                                            ),
                                          ]),
                                          const Divider(
                                              height: 15,
                                              color: Colors.transparent),
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  indivWorkoutsBox
                                                      .getAt(i)!
                                                      .note,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: textColor,
                                                  ))),
                                        ],
                                      )))),
                          const Divider(height: 5, color: Colors.transparent),
                        ])
                  ]));
        });
  }
}

class _WorkoutNotesState extends State<WorkoutNotesPage> {
  late final Box<String> tempNoteBox;
  final _myController = TextEditingController();

  @override
  void initState() {
    tempNoteBox = Hive.box<String>('tempNoteBox');
    _myController.text = tempNoteBox.getAt(0)!; //default text
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: const Text("Note"),
          titleTextStyle: TextStyle(fontSize: 22, color: textColor),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              autofocus: true,
              maxLines: null,
              showCursor: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                fontSize: 18,
              ),
              focusNode: FocusNode(),
              controller: _myController,
              onChanged: (val) {
                tempNoteBox.putAt(0, _myController.text);
              },
            )));
  }
}

class _PostWorkoutNotesState extends State<PostWorkoutNotesPage> {
  final _myController = TextEditingController();

  @override
  void initState() {
    _myController.text = postWorkoutTempNote; //default text
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: const Text("Note"),
          titleTextStyle: TextStyle(fontSize: 22, color: textColor),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              autofocus: true,
              maxLines: null,
              showCursor: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                fontSize: 18,
              ),
              focusNode: FocusNode(),
              controller: _myController,
              onChanged: (val) {
                postWorkoutTempNote = _myController.text;
              },
            )));
  }
}

class _EditState extends State<Edit> {
  final _myController = TextEditingController();
  late final Box<Workout> workoutsBox;
  late final Box<int> counterBox;

  @override
  void initState() {
    super.initState();
    counterBox = Hive.box<int>('counterBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: const Text("Program"),
        titleTextStyle: TextStyle(fontSize: 22, color: textColor),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(children: <Widget>[
          Flexible(
            child: ReorderableListView(
              shrinkWrap: true,
              // for every item of the List<Workout> class, display the reorder indicator
              // the name, the exercises, and three dots on the right
              scrollDirection: Axis.vertical,
              buildDefaultDragHandles: false,
              children: <Widget>[
                for (int index = 0; index < workoutsBox.length; index++)
                  GestureDetector(
                    key: Key('$index'),
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 80,
                        ),
                        color: backColor, // custom color goes here
                        child: Row(children: <Widget>[
                          Container(
                            width: 70,
                            padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                            child: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_indicator_outlined),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                              width: 280,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      workoutsBox.getAt(index)!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Prints out names of each exercise in the workout
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(children: [
                                        for (int i = 0;
                                            i <
                                                workoutsBox
                                                    .getAt(index)!
                                                    .exercises
                                                    .length;
                                            i++)
                                          // If not last exercise, print comma after
                                          if (i !=
                                              workoutsBox
                                                      .getAt(index)!
                                                      .exercises
                                                      .length -
                                                  1)
                                            Text(
                                              "${workoutsBox.getAt(index)!.exercises[i].name}, ",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            )
                                          else
                                            Text(
                                              workoutsBox
                                                  .getAt(index)!
                                                  .exercises[i]
                                                  .name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                      ])),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (dynamic value) {
                              // edits
                              if (value == 'edit') {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            EditWorkoutPage(index)))
                                    .then((value) {
                                  setState(() {});
                                });
                              }
                              // deletes
                              else if (value == 'delete') {
                                setState(() {
                                  workoutsBox.deleteAt(index);
                                });
                              }
                            },
                            itemBuilder: (BuildContext bc) {
                              return const [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  value: 'delete',
                                ),
                              ];
                            },
                          ),
                        ])),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => EditWorkoutPage(index)))
                          .then((value) {
                        setState(() {});
                      });
                    },
                  ),
              ],
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  final List<Workout> tempList = workoutsBox.values.toList();

                  final oldItem = tempList[oldIndex];
                  final newItem = tempList[newIndex];

                  tempList[oldIndex] = newItem;
                  tempList[newIndex] = oldItem;

                  // interesting dynamic with Box. Traditional putAt
                  // method doesn't work. need to completely refill
                  workoutsBox.deleteAll(workoutsBox.keys);
                  for (var i in tempList) {
                    workoutsBox.add(i);
                  }
                });
              },
            ),
          ),
          const Divider(height: 10, color: Colors.transparent),
          if (workoutsBox.isNotEmpty)
            SizedBox(
              height: 55,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    alignment: Alignment.centerLeft),
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text("Delete All Workouts",
                      style: TextStyle(color: textColor)),
                ),
                onPressed: () {
                  setState(() {
                    counterBox.putAt(0, 0);
                    workoutsBox.deleteAll(workoutsBox.keys);
                    workoutsBox.clear();
                  });
                },
              ),
            ),
        ]),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(.93, 1), // custom alignment
        child: SizedBox(
          width: 150,
          height: 50,
          child: OutlinedButton(
            child: const Text("Add Workout"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(10),
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text("Workout Name",
                                    style: TextStyle(
                                      fontSize: 18,
                                    )),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _myController,
                                  autofocus: true,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.words,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                Divider(
                                  color: underlineColor,
                                  height: 2,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 30),
                                Row(children: <Widget>[
                                  const SizedBox(width: 187.4),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  TextButton(
                                      style: TextButton.styleFrom(
                                        primary: redColor,
                                        textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        alignment: Alignment.center,
                                      ),
                                      child: const Text("OK"),
                                      onPressed: () {
                                        bool duplicate = false;
                                        for (var i in workoutsBox.values) {
                                          if (i.name == _myController.text) {
                                            duplicate = true;
                                          }
                                        }
                                        if (duplicate == false) {
                                          workoutsBox
                                              .add(Workout(_myController.text));
                                          _myController.text = "";
                                          Navigator.of(context).pop();
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditWorkoutPage(
                                                          workoutsBox.length -
                                                              1)))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        } else {
                                          _myController.text = "";
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content:
                                                Text("Workout already exists"),
                                            duration: Duration(seconds: 2),
                                          ));
                                          Navigator.of(context).pop();
                                        }
                                      }),
                                ]),
                              ]))));
            },
          ),
        ),
      ),
    );
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Widget> nums = [
    for (int i = 50; i < 700; i++) ListTile(title: Text(i.toString())),
  ];
  List<Widget> decs = [
    for (int i = 0; i < 10; i++) ListTile(title: Text(i.toString())),
  ];

  late final Box<Workout> workoutsBox;
  late final List<Workout> workoutsList;
  late final Box<IndivWorkout> indivWorkoutsBox;
  late final Box<int> counterBox;
  late final Box<Exercise> exercisesBox;
  late final Box<bool> boolBox;
  late final Box<TimerMap> successTimerBox;
  late final Box<TimerMap> failTimerBox;
  late final Box<Plate> platesBox;
  late final Box<String> tempNoteBox;
  late final Box<double> tempBodyWeightBox;
  final List<int> successTimes = [];
  final List<int> failureTimes = [];

  @override
  void initState() {
    super.initState();
    workoutsBox = Hive.box<Workout>('workoutsBox');
    workoutsList = workoutsBox.values.toList();
    counterBox = Hive.box<int>('counterBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    boolBox = Hive.box<bool>('boolBox');
    successTimerBox = Hive.box<TimerMap>('successTimerBox');
    failTimerBox = Hive.box<TimerMap>('failTimerBox');
    platesBox = Hive.box<Plate>('platesBox');
    tempNoteBox = Hive.box<String>('tempNoteBox');
    tempBodyWeightBox = Hive.box<double>('tempBodyWeightBox');
    getTimes();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  void getTimes() {
    for (int i = 0; i < successTimerBox.length; i++) {
      successTimes.add(successTimerBox.getAt(i)!.time);
    }
    for (int i = 0; i < failTimerBox.length; i++) {
      failureTimes.add(failTimerBox.getAt(i)!.time);
    }
    successTimes.sort();
    failureTimes.sort();
  }

  void decrementWeight(int j) {
    double deloadMultiplier =
        0.01 * (100 - exercisesBox.getAt(j)!.deloadPercent);

    if (exercisesBox.getAt(j)!.weight * deloadMultiplier <=
        exercisesBox.getAt(j)!.barWeight) {
      exercisesBox.getAt(j)!.weight = exercisesBox.getAt(j)!.barWeight;
      exercisesBox.getAt(j)!.save();
    } else {
      exercisesBox.getAt(j)!.weight *= deloadMultiplier;
      // subtracts a little weight until weight can be formed
      // the weight subtracted is the difference to the smallest plate
      while (!plateCalculator(exercisesBox.getAt(j))) {
        if (exercisesBox.getAt(j)!.weight %
                platesBox.getAt(platesBox.length - 1)!.weight !=
            0) {
          exercisesBox.getAt(j)!.weight -= exercisesBox.getAt(j)!.weight %
              platesBox.getAt(platesBox.length - 1)!.weight;
        } else {
          exercisesBox.getAt(j)!.weight -= 0.00001;
        }
      }
      exercisesBox.getAt(j)!.save();
    }
  }

  // returns if weight can be formed
  // used in decrement weight function to ensure weight
  // will be able to be formed
  bool plateCalculator(Exercise? exercise) {
    // weight per side
    double weight = (exercise!.weight - exercise.barWeight) / 2;

    for (int i = 0; i < platesBox.length; i++) {
      int numPlates = weight ~/ platesBox.getAt(i)!.weight;
      if (numPlates > (platesBox.getAt(i)!.number / 2)) {
        numPlates = platesBox.getAt(i)!.number ~/ 2;
      }
      if (numPlates > 0) {
        weight -= numPlates * platesBox.getAt(i)!.weight;
      }
    }
    if (weight != 0) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Workout? selectVal = workoutsBox.getAt(0);
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: Center(
              child: SizedBox(
                  height: 40,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: circleColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 10),
                          child: DropdownButton(
                            underline: const SizedBox(),
                            isExpanded: false,
                            items: workoutsList.map((Workout workout) {
                              return DropdownMenuItem<Workout>(
                                  value: workout, child: Text(workout.name));
                            }).toList(),
                            value: selectVal,
                            selectedItemBuilder: (context) {
                              return [
                                SizedBox(
                                    width: 200,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          workoutsList[widget.index].name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                              ];
                            },
                            onChanged: (Workout? w) {
                              setState(() {
                                // index of selection
                                selectVal = w;
                                int idx = workoutsList.indexOf(selectVal!);
                                // do nothing if same selection
                                if (idx == widget.index) {
                                } else {
                                  for (int j = 0;
                                      j < workoutsList[idx].exercises.length;
                                      ++j) {
                                    final tempWorkout =
                                        Hive.box<Workout>('workoutsBox')
                                            .getAt(idx);
                                    tempWorkout!.exercises[j].repsCompleted
                                        .clear();
                                    for (int k = 0;
                                        k < tempWorkout.exercises[j].sets;
                                        k++) {
                                      // repsCompleted initialized with initial reps value
                                      tempWorkout.exercises[j].repsCompleted
                                          .add(workoutsBox
                                                  .getAt(idx)!
                                                  .exercises[j]
                                                  .reps +
                                              1);
                                      tempWorkout.save();
                                    }
                                    showTimer = false;
                                  }
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => WorkoutPage(idx)));
                                }
                              });
                            },
                          ))))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Finish"),
              onPressed: () {
                AwesomeNotifications().cancelAll();
                widget.index == workoutsBox.length - 1
                    ? counterBox.putAt(0, 0)
                    : counterBox.putAt(
                        0,
                        widget.index +
                            1); // loops counter according to selected workout
                showTimer = false;
                timer?.cancel();

                String name = workoutsBox.getAt(widget.index)!.name;
                DateTime now = DateTime.now();
                String date = DateFormat('E, d MMM yyyy').format(now);
                String sortableDate = DateFormat('yyyyMMdd').format(now);
                List<String> exercisesCompleted = [];
                List<double> weights = [];
                List<int> repsPlanned = [];
                List<int> setsPlanned = [];
                List<List<int>> repsCompleted = [];

                for (int i = 0;
                    i < workoutsBox.getAt(widget.index)!.exercises.length;
                    i++) {
                  bool exerciseFailed = false;

                  exercisesCompleted
                      .add(workoutsBox.getAt(widget.index)!.exercises[i].name);
                  weights.add(
                      workoutsBox.getAt(widget.index)!.exercises[i].weight);
                  repsPlanned
                      .add(workoutsBox.getAt(widget.index)!.exercises[i].reps);
                  setsPlanned
                      .add(workoutsBox.getAt(widget.index)!.exercises[i].sets);

                  // extremely weird error (appeared to be pass-by-reference
                  // with the repsCompleted, despite that not being possible)
                  // this is the roundabout solution I found
                  repsCompleted.add([0]);
                  repsCompleted[i].add(workoutsBox
                      .getAt(widget.index)!
                      .exercises[i]
                      .repsCompleted[0]);
                  repsCompleted[i].removeAt(0);

                  final tempWorkout =
                      Hive.box<Workout>('workoutsBox').getAt(widget.index);

                  if (tempWorkout!.exercises[i].repsCompleted[0] !=
                      tempWorkout.exercises[i].reps) {
                    exerciseFailed = true;
                  }
                  for (int j = 1;
                      j < tempWorkout.exercises[i].repsCompleted.length;
                      j++) {
                    repsCompleted[i]
                        .add(tempWorkout.exercises[i].repsCompleted[j]);

                    if (tempWorkout.exercises[i].repsCompleted[j] !=
                        tempWorkout.exercises[i].reps) {
                      exerciseFailed = true;
                    }
                  }

                  tempWorkout.exercises[i].repsCompleted.clear();
                  String name = tempWorkout.exercises[i].name;
                  tempWorkout.save();

                  int exIdx = 0;
                  for (int i = 0; i < exercisesBox.length; i++) {
                    if (exercisesBox.getAt(i)!.name == name) {
                      exIdx = i;
                    }
                  }

                  if (exerciseFailed == true) {
                    // deloads
                    if (exercisesBox.getAt(exIdx)!.deload &&
                        exercisesBox.getAt(exIdx)!.failed + 1 >=
                            exercisesBox.getAt(exIdx)!.deloadFrequency) {
                      exercisesBox.getAt(exIdx)!.failed = 0;
                      exercisesBox.getAt(exIdx)!.success = 0;
                      decrementWeight(exIdx);
                      exercisesBox.getAt(exIdx)!.save();

                      // because of how Hive works, we also have to
                      // go through each individual workout
                      // inefficient, but I can't find a better way
                      for (int i = 0; i < workoutsBox.length; i++) {
                        final tempWorkout =
                            Hive.box<Workout>('workoutsBox').getAt(i);
                        for (int j = 0;
                            j < tempWorkout!.exercises.length;
                            j++) {
                          if (tempWorkout.exercises[j].name == name) {
                            tempWorkout.exercises[j].weight =
                                exercisesBox.getAt(exIdx)!.weight;
                          }
                          tempWorkout.save();
                        }
                      }
                    }
                    // increments failure counter, not yet at deload
                    else {
                      exercisesBox.getAt(exIdx)!.success = 0;
                      exercisesBox.getAt(exIdx)!.failed += 1;
                      exercisesBox.getAt(exIdx)!.save();
                    }
                  }
                  // increment for all exercises with the same name
                  // if success count matches increment frequency
                  // and overload is on
                  else if (exerciseFailed == false) {
                    // increments for all and resets success counter
                    if (exercisesBox.getAt(exIdx)!.overload &&
                        exercisesBox.getAt(exIdx)!.success + 1 >=
                            exercisesBox.getAt(exIdx)!.incrementFrequency) {
                      exercisesBox.getAt(exIdx)!.weight +=
                          exercisesBox.getAt(exIdx)!.increment;
                      exercisesBox.getAt(exIdx)!.success = 0;
                      exercisesBox.getAt(exIdx)!.failed = 0;
                      exercisesBox.getAt(exIdx)!.save();

                      for (int i = 0; i < workoutsBox.length; i++) {
                        final tempWorkout =
                            Hive.box<Workout>('workoutsBox').getAt(i);
                        for (int j = 0;
                            j < tempWorkout!.exercises.length;
                            j++) {
                          if (tempWorkout.exercises[j].name == name) {
                            tempWorkout.exercises[j].weight =
                                exercisesBox.getAt(exIdx)!.weight;
                          }
                          tempWorkout.save();
                        }
                      }
                    }
                    // increments success counter, but does not add weight because
                    // not at frequency to increment yet
                    else {
                      exercisesBox.getAt(exIdx)!.success += 1;
                      exercisesBox.getAt(exIdx)!.failed = 0;
                      exercisesBox.getAt(exIdx)!.save();
                    }
                  }
                }

                indivWorkoutsBox.add(IndivWorkout(
                    name,
                    date,
                    sortableDate,
                    exercisesCompleted,
                    weights,
                    repsPlanned,
                    setsPlanned,
                    repsCompleted,
                    tempNoteBox.getAt(0)!,
                    tempBodyWeightBox.getAt(0)!));

                tempNoteBox.putAt(0, ""); // clears note for next workout

                _counter.value++;
                _progressCounter.value++;
                _calendarCounter.value++;

                for (int i = 0; i < workoutsBox.length; i++) {
                  final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(i);
                  tempWorkout!.isInitialized = false;

                  for (int j = 0; j < tempWorkout.exercises.length; j++) {
                    tempWorkout.exercises[j].repsCompleted.clear();
                    tempWorkout.save();
                  }
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.76,
            ),
            child: Column(children: <Widget>[
              Flexible(
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                    for (int i = 0;
                        i < workoutsBox.getAt(widget.index)!.exercises.length;
                        i++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    workoutsBox
                                        .getAt(widget.index)!
                                        .exercises[i]
                                        .name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                    )),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        for (int j = 0;
                                            j < exercisesBox.length;
                                            j++) {
                                          if (exercisesBox.getAt(j)!.name ==
                                              workoutsBox
                                                  .getAt(widget.index)!
                                                  .exercises[i]
                                                  .name) {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditExercisePage(j)))
                                                .then((value) {
                                              setState(() {});
                                            });
                                          }
                                        }
                                      },
                                      child: Row(children: <Widget>[
                                        if (workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[i]
                                                    .weight %
                                                1 ==
                                            0)
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${workoutsBox.getAt(widget.index)!.exercises[i].sets}×${workoutsBox.getAt(widget.index)!.exercises[i].reps} ${workoutsBox.getAt(widget.index)!.exercises[i].weight ~/ 1}lb",
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      ))))
                                        else
                                          Expanded(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${workoutsBox.getAt(widget.index)!.exercises[i].sets}×${workoutsBox.getAt(widget.index)!.exercises[i].reps} ${workoutsBox.getAt(widget.index)!.exercises[i].weight.toString()}lb",
                                                      style: const TextStyle(
                                                          fontSize: 17)))),
                                        SizedBox(
                                          width: 17,
                                          child: IconButton(
                                            onPressed: () {
                                              for (int j = 0;
                                                  j < exercisesBox.length;
                                                  j++) {
                                                if (exercisesBox
                                                        .getAt(j)!
                                                        .name ==
                                                    workoutsBox
                                                        .getAt(widget.index)!
                                                        .exercises[i]
                                                        .name) {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditExercisePage(
                                                                  j)))
                                                      .then((value) {
                                                    setState(() {});
                                                  });
                                                }
                                              }
                                            },
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.all(0),
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: const Icon(
                                                Icons.arrow_right_sharp),
                                            color: redColor,
                                            iconSize: 20,
                                          ),
                                        ),
                                      ])))),
                        ]),
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  // one circle for each set, initialized with number of reps
                                  for (int j = 0;
                                      j <
                                          workoutsBox
                                              .getAt(widget.index)!
                                              .exercises[i]
                                              .sets;
                                      j++)
                                    // circle, onTap decrement, loops back to rep number
                                    ValueListenableBuilder(
                                        valueListenable: _circleCounter,
                                        builder: (context, value, child) {
                                          return SizedBox(
                                            width: 78,
                                            height: 50,
                                            child: MaterialButton(
                                              elevation: 0,
                                              splashColor: Colors.transparent,
                                              animationDuration:
                                                  const Duration(milliseconds: 0),
                                              highlightColor:
                                                  Colors.transparent,
                                              shape: const CircleBorder(
                                                  side: BorderSide(
                                                      width: 1,
                                                      style: BorderStyle.none)),
                                              child: workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .repsCompleted[j] >
                                                      workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .reps
                                                  ? Text(
                                                      workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .reps
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 18))
                                                  : Text(
                                                      workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .repsCompleted[j]
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 18)),
                                              color: workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .repsCompleted[j] >
                                                      workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .reps
                                                  ? circleColor
                                                  : redColor,
                                              textColor: workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .repsCompleted[j] >
                                                      workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .reps
                                                  ? emptyCircleTextColor
                                                  : Colors.white,
                                              onPressed: () {
                                                workoutIndex = widget.index;
                                                exerciseIndex = i;
                                                setIndex = j - 1;
                                                incrementCircles(
                                                    widget.index, i, j, false);
                                              },
                                            ),
                                          );
                                        })
                                ]),
                              ]),
                        ),
                        const SizedBox(height: 10),
                      ]),
                  ])),
              Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                            child: Center(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Body Weight",
                                        style: TextStyle(
                                          fontSize: 17,
                                        ))))),
                        Expanded(
                            child: Center(
                                child: GestureDetector(
                                    onTap: () {
                                      // sets initial scroll to weight
                                      final _intController =
                                          FixedExtentScrollController(
                                              initialItem:
                                                  tempBodyWeightBox.getAt(0)! ~/
                                                          1 -
                                                      50);
                                      // annoying floating point precision: 100.6 - 100 = 0.599
                                      // the +0.05 is a way around it
                                      final _decController =
                                          FixedExtentScrollController(
                                              initialItem:
                                                  (tempBodyWeightBox.getAt(0)! -
                                                          (tempBodyWeightBox
                                                                  .getAt(0)! ~/
                                                              1) +
                                                          0.05) *
                                                      10 ~/
                                                      1);
                                      int scrollBodyWeightInt =
                                          tempBodyWeightBox.getAt(0)! ~/ 1;
                                      int scrollBodyWeightDec =
                                          (tempBodyWeightBox.getAt(0)! -
                                                  (tempBodyWeightBox
                                                          .getAt(0)! ~/
                                                      1)) *
                                              10 ~/
                                              1;
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text("Weight",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                            )),
                                                        const SizedBox(
                                                            height: 30),
                                                        Flexible(
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                              SizedBox(
                                                                  height: 120,
                                                                  width: 70,
                                                                  child:
                                                                      CupertinoPicker(
                                                                    scrollController:
                                                                        _intController,
                                                                    children:
                                                                        nums,
                                                                    looping:
                                                                        true,
                                                                    diameterRatio:
                                                                        1.25,
                                                                    selectionOverlay:
                                                                        Column(children: <
                                                                            Widget>[
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      )))),
                                                                      const SizedBox(
                                                                          height:
                                                                              50),
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      ))))
                                                                    ]),
                                                                    itemExtent:
                                                                        75,
                                                                    onSelectedItemChanged:
                                                                        (index) =>
                                                                            {
                                                                      scrollBodyWeightInt =
                                                                          index +
                                                                              50,
                                                                    },
                                                                  )),
                                                              const SizedBox(
                                                                width: 20,
                                                                height: 45,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child: Text(
                                                                      ".",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      )),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 120,
                                                                  width: 70,
                                                                  child:
                                                                      CupertinoPicker(
                                                                    scrollController:
                                                                        _decController,
                                                                    children:
                                                                        decs,
                                                                    looping:
                                                                        true,
                                                                    diameterRatio:
                                                                        1.25,
                                                                    selectionOverlay:
                                                                        Column(children: <
                                                                            Widget>[
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      )))),
                                                                      const SizedBox(
                                                                          height:
                                                                              50),
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      ))))
                                                                    ]),
                                                                    itemExtent:
                                                                        75,
                                                                    onSelectedItemChanged:
                                                                        (index) =>
                                                                            {
                                                                      scrollBodyWeightDec =
                                                                          index,
                                                                    },
                                                                  )),
                                                              const SizedBox(
                                                                width: 20,
                                                                height: 40,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child: Text(
                                                                      "lb",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                      )),
                                                                ),
                                                              ),
                                                            ])),
                                                        const SizedBox(
                                                            height: 30),
                                                        Row(children: <Widget>[
                                                          const SizedBox(
                                                              width: 187.4),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "Cancel"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              tempBodyWeightBox.putAt(
                                                                  0,
                                                                  scrollBodyWeightInt +
                                                                      0.1 *
                                                                          scrollBodyWeightDec);
                                                              setState(() {});
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ]),
                                                      ]))));
                                    },
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${tempBodyWeightBox.getAt(0)!.toString()}lb",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: redColor,
                                              fontWeight: FontWeight.bold,
                                            )))))),
                      ])),
            ])),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: ValueListenableBuilder(
            valueListenable: _timerCounter,
            builder: (context, value, child) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    showTimer
                        ? Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.1,
                            padding: const EdgeInsets.only(left: 25),
                            child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    width: double.infinity,
                                    child: Row(children: <Widget>[
                                      Flexible(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                            buildTime(),
                                          ])),
                                      Flexible(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              failed
                                                  ? failureTimes.isEmpty
                                                      ? const Text(
                                                          "No failure timer")
                                                      : failureTimes.last %
                                                                  60 ==
                                                              0
                                                          ? Text(
                                                              "Rest ${(failureTimes.last ~/ 60).toString()}min",
                                                              style: TextStyle(
                                                                  color:
                                                                      textColor))
                                                          : Text(
                                                              "Rest ${(failureTimes.last ~/ 60).toString()}min ${(failureTimes.last % 60).toString()}s",
                                                              style: TextStyle(
                                                                  color:
                                                                      textColor))
                                                  : successTimes.isEmpty
                                                      ? const Text(
                                                          "No success timer")
                                                      : successTimes.last %
                                                                  60 ==
                                                              0
                                                          ? Text(
                                                              "Rest ${(successTimes.last ~/ 60).toString()}min",
                                                              style: TextStyle(
                                                                  color:
                                                                      textColor))
                                                          : Text(
                                                              "Rest ${(successTimes.last ~/ 60).toString()}min ${(successTimes.last % 60).toString()}s",
                                                              style: TextStyle(
                                                                  color:
                                                                      textColor)),
                                              IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () => setState(
                                                      () => showTimer = false)),
                                            ]),
                                      ),
                                    ]),
                                    decoration: BoxDecoration(
                                      color: circleColor,
                                    ))))
                        : Container(),
                    Container(
                        padding: const EdgeInsets.only(left: 25),
                        child: Row(children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const WorkoutNotesPage()));
                                  },
                                  child: const Text("Note"),
                                  style: TextButton.styleFrom(
                                    primary: redColor,
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    alignment: Alignment.bottomCenter,
                                  )),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                EditWorkoutPage(widget.index)))
                                        .then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: const Text("Edit"),
                                  style: TextButton.styleFrom(
                                    primary: redColor,
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    alignment: Alignment.bottomCenter,
                                  )),
                            ),
                          ),
                        ])),
                  ]);
            }));
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(minutes, 20),
      SizedBox(
          width: 4,
          child: Text(":",
              style: TextStyle(
                fontSize: 30,
                color: textColor,
              ))),
      buildTimeCard(seconds, 5),
    ]);
  }

  void startTimer(Timer? timer) {
    timer?.cancel();
    duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  // the time is incremented in _homeState
  // however, this is used for setState, so the time actually updates and shows
  void addTime(Timer? timer) {
    const addSeconds = 0;
    if (!mounted) return;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  Widget buildTimeCard(String time, double inset) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: inset),
        child: Text(
          time,
          style: TextStyle(color: textColor, fontSize: 30),
        ),
      );
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final _myController = TextEditingController();
  late final Box<Exercise> exercisesBox;
  late List<Exercise> exercisesList;
  late List<Exercise> copyExercisesList;
  late final Box<Workout> workoutsBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: Text(workoutsBox.getAt(widget.index)!.name),
        titleTextStyle: TextStyle(fontSize: 22, color: textColor),
      ),
      body: Container(
        constraints: const BoxConstraints(
          maxHeight: 750,
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ReorderableListView(
                shrinkWrap: true,
                // for every item of the List<Workout> class, display the reorder indicator
                // the name, the exercises, and three dots on the right
                scrollDirection: Axis.vertical,
                buildDefaultDragHandles: false,
                children: <Widget>[
                  for (int i = 0;
                      i < workoutsBox.getAt(widget.index)!.exercises.length;
                      i++)
                    Container(
                      key: Key('$i'),
                      color: backColor, // custom color goes here
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            height: 80,
                            child: ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_indicator_outlined),
                            ),
                          ),
                          GestureDetector(
                            child: SizedBox(
                              width: 280,
                              height: 60,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        workoutsBox
                                            .getAt(widget.index)!
                                            .exercises[i]
                                            .name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Prints out names of each exercise in the workout
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${workoutsBox.getAt(widget.index)!.exercises[i].sets.toString()} sets of ${workoutsBox.getAt(widget.index)!.exercises[i].reps.toString()} reps",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            softWrap: false,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              for (int j = 0; j < exercisesBox.length; j++) {
                                if (exercisesBox.getAt(j)!.name ==
                                    workoutsBox
                                        .getAt(widget.index)!
                                        .exercises[i]
                                        .name) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              EditExercisePage(j)))
                                      .then((value) {
                                    setState(() {});
                                  });
                                }
                              }
                            },
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (dynamic value) {
                              // edits
                              if (value == 'edit') {
                                for (int j = 0; j < exercisesBox.length; j++) {
                                  if (exercisesBox.getAt(j)!.name ==
                                      workoutsBox
                                          .getAt(widget.index)!
                                          .exercises[i]
                                          .name) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                EditExercisePage(j)))
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }
                                }
                              }
                              // deletes
                              else if (value == 'delete') {
                                setState(() {
                                  final tempWorkout =
                                      Hive.box<Workout>('workoutsBox')
                                          .getAt(widget.index);
                                  tempWorkout?.exercises.removeAt(i);
                                  tempWorkout?.save();
                                });
                              } else if (value == 'deleteAll') {
                                setState(() {
                                  for (int k = 0;
                                      k < exercisesBox.length;
                                      k++) {
                                    if (exercisesBox.getAt(k)!.name ==
                                        workoutsBox
                                            .getAt(widget.index)!
                                            .exercises[i]
                                            .name) {
                                      exercisesBox.deleteAt(k);
                                    }
                                  }
                                  for (int j = 0; j < workoutsBox.length; j++) {
                                    if (workoutsBox.getAt(j)! ==
                                        workoutsBox.getAt(widget.index)!) {
                                    } else {
                                      for (int k = 0;
                                          k <
                                              workoutsBox
                                                  .getAt(j)!
                                                  .exercises
                                                  .length;
                                          k++) {
                                        if (workoutsBox
                                                .getAt(j)!
                                                .exercises[k]
                                                .name ==
                                            workoutsBox
                                                .getAt(widget.index)!
                                                .exercises[i]
                                                .name) {
                                          final tempWorkout =
                                              Hive.box<Workout>('workoutsBox')
                                                  .getAt(j);
                                          tempWorkout?.exercises.removeAt(i);
                                          tempWorkout?.save();
                                        }
                                      }
                                    }
                                  }
                                  final tempWorkout =
                                      Hive.box<Workout>('workoutsBox')
                                          .getAt(widget.index);
                                  tempWorkout?.exercises.removeAt(i);
                                  tempWorkout?.save();
                                });
                              }
                            },
                            itemBuilder: (BuildContext bc) {
                              return const [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  value: 'delete',
                                ),
                                PopupMenuItem(
                                  child: Text("Delete From All Workouts"),
                                  value: 'deleteAll',
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                ],
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex = newIndex - 1;
                    }
                    final tempWorkout =
                        Hive.box<Workout>('workoutsBox').getAt(widget.index);

                    final element = tempWorkout?.exercises.removeAt(oldIndex);
                    tempWorkout!.exercises.insert(newIndex, element!);
                    tempWorkout.save();
                  });
                },
              ),
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    alignment: Alignment.centerLeft),
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text("Change Workout Name",
                      style: TextStyle(color: textColor)),
                ),
                onPressed: () {
                  setState(() => _myController.text =
                      workoutsBox.getAt(widget.index)!.name);
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                            insetPadding: const EdgeInsets.all(10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text("Workout Name",
                                        style: TextStyle(
                                          fontSize: 18,
                                        )),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _myController,
                                      autofocus: true,
                                      keyboardType: TextInputType.text,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(bottom: 10),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                    Divider(
                                      color: underlineColor,
                                      height: 2,
                                      thickness: 2,
                                    ),
                                    const SizedBox(height: 40),
                                    Row(children: <Widget>[
                                      const SizedBox(width: 187.4),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("OK"),
                                        onPressed: () {
                                          setState(() {
                                            final tempWorkout =
                                                Hive.box<Workout>('workoutsBox')
                                                    .getAt(widget.index);
                                            tempWorkout?.name =
                                                _myController.text;
                                            tempWorkout?.save();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ]),
                                  ]),
                            ),
                          ));
                },
              ),
            ),
            if (workoutsBox.getAt(widget.index)!.exercises.isNotEmpty)
              SizedBox(
                height: 55,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      alignment: Alignment.centerLeft),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("Delete All Exercises",
                        style: TextStyle(color: textColor)),
                  ),
                  onPressed: () {
                    // add confirmation "would you like to delete all exercises?""
                    setState(() {
                      final tempWorkout =
                          Hive.box<Workout>('workoutsBox').getAt(widget.index);
                      tempWorkout?.exercises.clear();
                      tempWorkout?.save();
                      workoutsBox.getAt(widget.index)!.exercises.clear();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(.93, 1), // custom alignment
        child: SizedBox(
          width: 150,
          height: 50,
          child: OutlinedButton(
            child: const Text("Add Exercise"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
              exercisesList = exercisesBox.values.toList();
              exercisesList.removeAt(0);
              copyExercisesList = exercisesBox.values.toList();
              copyExercisesList.removeAt(0);
              copyExercisesList.sort((a, b) {
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              });
              // removes if already in workout
              for (var ex in exercisesList) {
                for (int i = 0;
                    i < workoutsBox.getAt(widget.index)!.exercises.length;
                    i++) {
                  if (ex.name ==
                      workoutsBox.getAt(widget.index)!.exercises[i].name) {
                    copyExercisesList.remove(ex);
                  }
                }
              }
              copyExercisesList.insert(0, customxyz);

              Exercise? selectVal = customxyz;
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text("Add Exercise",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const SizedBox(height: 10),

                          // dropdown list with "custom" at top
                          DropdownButton(
                              isExpanded: true,
                              items: copyExercisesList.map((Exercise exercise) {
                                return DropdownMenuItem<Exercise>(
                                    value: exercise,
                                    child: Text(exercise.name));
                              }).toList(),
                              value: selectVal,
                              selectedItemBuilder: (context) {
                                return [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(selectVal!.name))
                                ];
                              },
                              onChanged: (Exercise? e) {
                                setState(() => selectVal = e);
                              }),
                          const SizedBox(height: 30),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("OK"),
                              onPressed: () {
                                _myController.text = "";
                                setState(() {
                                  if (selectVal == customxyz) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                            insetPadding:
                                                const EdgeInsets.all(10),
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      const Text(
                                                          "Exercise Name",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      TextField(
                                                        controller:
                                                            _myController,
                                                        autofocus: true,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .bottom,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        decoration:
                                                            const InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  bottom: 10),
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                      Divider(
                                                        color: underlineColor,
                                                        height: 2,
                                                        thickness: 2,
                                                      ),
                                                      const SizedBox(
                                                          height: 30),
                                                      Row(children: <Widget>[
                                                        const SizedBox(
                                                            width: 187.4),
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            primary: redColor,
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                          child: const Text(
                                                              "Cancel"),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            width: 20),
                                                        TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              bool duplicate =
                                                                  false;
                                                              // check that it's not in all exercises and it's not in current workout
                                                              for (int i = 0;
                                                                  i <
                                                                      exercisesBox
                                                                          .length;
                                                                  i++) {
                                                                if (_myController
                                                                        .text ==
                                                                    exercisesBox
                                                                        .getAt(
                                                                            i)!
                                                                        .name) {
                                                                  duplicate =
                                                                      true;
                                                                }
                                                              }
                                                              for (int i = 0;
                                                                  i <
                                                                      workoutsBox
                                                                          .getAt(
                                                                              widget.index)!
                                                                          .exercises
                                                                          .length;
                                                                  i++) {
                                                                if (_myController
                                                                        .text ==
                                                                    workoutsBox
                                                                        .getAt(widget
                                                                            .index)!
                                                                        .exercises[
                                                                            i]
                                                                        .name) {
                                                                  duplicate =
                                                                      true;
                                                                }
                                                              }
                                                              if (duplicate ==
                                                                  false) {
                                                                Exercise newEx =
                                                                    Exercise(
                                                                        _myController
                                                                            .text);
                                                                // Adds to Hive local storage
                                                                exercisesBox
                                                                    .add(newEx);

                                                                final tempWorkout = Hive.box<
                                                                            Workout>(
                                                                        'workoutsBox')
                                                                    .getAt(widget
                                                                        .index);
                                                                tempWorkout
                                                                    ?.exercises
                                                                    .add(newEx);
                                                                tempWorkout
                                                                    ?.save();
                                                                _progressCounter
                                                                    .value++;

                                                                if (workoutsBox
                                                                        .getAt(widget
                                                                            .index)!
                                                                        .isInitialized ==
                                                                    false) {
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .exercises
                                                                              .length;
                                                                      ++j) {
                                                                    for (int k =
                                                                            0;
                                                                        k < workoutsBox.getAt(widget.index)!.exercises[j].sets;
                                                                        k++) {
                                                                      // repsCompleted initialized with initial reps value
                                                                      workoutsBox
                                                                          .getAt(widget
                                                                              .index)!
                                                                          .exercises[
                                                                              j]
                                                                          .repsCompleted
                                                                          .add(workoutsBox.getAt(widget.index)!.exercises[j].reps +
                                                                              1);
                                                                    }
                                                                  }
                                                                  workoutsBox
                                                                      .getAt(widget
                                                                          .index)!
                                                                      .isInitialized = true;
                                                                } else {
                                                                  // adds to repsCompleted, initializes it
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1]
                                                                              .sets;
                                                                      j++) {
                                                                    workoutsBox
                                                                        .getAt(widget
                                                                            .index)!
                                                                        .exercises[
                                                                            workoutsBox.getAt(widget.index)!.exercises.length -
                                                                                1]
                                                                        .repsCompleted
                                                                        .add(workoutsBox.getAt(widget.index)!.exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1].reps +
                                                                            1);
                                                                  }
                                                                  setState(() =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop());
                                                                }
                                                                _myController
                                                                    .text = "";
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            EditExercisePage(exercisesBox.length -
                                                                                1)))
                                                                    .then(
                                                                        (value) {
                                                                  setState(
                                                                      () {});
                                                                });
                                                              } else if (duplicate ==
                                                                  true) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          "Exercise already exists"),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2)),
                                                                );
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }),
                                                      ]),
                                                    ]))));
                                  } else {
                                    final tempWorkout =
                                        Hive.box<Workout>('workoutsBox')
                                            .getAt(widget.index);
                                    tempWorkout?.exercises.add(selectVal!);

                                    tempWorkout?.save();

                                    if (workoutsBox
                                            .getAt(widget.index)!
                                            .isInitialized ==
                                        false) {
                                      for (int j = 0;
                                          j <
                                              workoutsBox
                                                  .getAt(widget.index)!
                                                  .exercises
                                                  .length;
                                          ++j) {
                                        for (int k = 0;
                                            k <
                                                workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[j]
                                                    .sets;
                                            k++) {
                                          // repsCompleted initialized with initial reps value
                                          workoutsBox
                                              .getAt(widget.index)!
                                              .exercises[j]
                                              .repsCompleted
                                              .add(workoutsBox
                                                      .getAt(widget.index)!
                                                      .exercises[j]
                                                      .reps +
                                                  1);
                                        }
                                      }
                                      workoutsBox
                                          .getAt(widget.index)!
                                          .isInitialized = true;
                                    } else {
                                      // adds to repsCompleted, initializes it
                                      for (int j = 0;
                                          j <
                                              workoutsBox
                                                  .getAt(widget.index)!
                                                  .exercises[workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises
                                                          .length -
                                                      1]
                                                  .sets;
                                          j++) {
                                        workoutsBox
                                            .getAt(widget.index)!
                                            .exercises[workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises
                                                    .length -
                                                1]
                                            .repsCompleted
                                            .add(workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises
                                                            .length -
                                                        1]
                                                    .reps +
                                                1);
                                      }
                                      setState(
                                          () => Navigator.of(context).pop());
                                    }
                                  }
                                });
                              },
                            ),
                          ]),
                        ]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditExercisePageState extends State<EditExercisePage> {
  final _myController = TextEditingController();
  final _myController2 = TextEditingController();
  late final Box<Exercise> exercisesBox;
  late final Box<Workout> workoutsBox;
  late final Box<Plate> platesBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
    platesBox = Hive.box<Plate>('platesBox');
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                exercisesBox.getAt(widget.index)!.name,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
            // displays no decimal points if it's not a decimal (casts to int)
            if (exercisesBox.getAt(widget.index)!.weight % 1 == 0 &&
                ((exercisesBox.getAt(widget.index)!.weight -
                                exercisesBox.getAt(widget.index)!.barWeight) /
                            2) %
                        1 ==
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${exercisesBox.getAt(widget.index)!.weight.toInt().toString()}lb (${(((exercisesBox.getAt(widget.index)!.weight) - exercisesBox.getAt(widget.index)!.barWeight) ~/ 2)}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            if (exercisesBox.getAt(widget.index)!.weight % 1 == 0 &&
                ((exercisesBox.getAt(widget.index)!.weight -
                                exercisesBox.getAt(widget.index)!.barWeight) /
                            2) %
                        1 !=
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${exercisesBox.getAt(widget.index)!.weight.toInt().toString()}lb (${(((exercisesBox.getAt(widget.index)!.weight) - exercisesBox.getAt(widget.index)!.barWeight) / 2).toString()}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            // if there are decimals
            if (exercisesBox.getAt(widget.index)!.weight % 1 != 0 &&
                ((exercisesBox.getAt(widget.index)!.weight -
                                exercisesBox.getAt(widget.index)!.barWeight) /
                            2) %
                        1 ==
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${exercisesBox.getAt(widget.index)!.weight.toString()}lb (${(((exercisesBox.getAt(widget.index)!.weight) - exercisesBox.getAt(widget.index)!.barWeight) ~/ 2)}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
            if (exercisesBox.getAt(widget.index)!.weight % 1 != 0 &&
                ((exercisesBox.getAt(widget.index)!.weight -
                                exercisesBox.getAt(widget.index)!.barWeight) /
                            2) %
                        2 !=
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${exercisesBox.getAt(widget.index)!.weight.toString()}lb (${((exercisesBox.getAt(widget.index)!.weight - exercisesBox.getAt(widget.index)!.barWeight) / 2).toString()}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ),
          ],
        ),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: ListView(children: <Widget>[
        TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: () {
              if (exercisesBox.getAt(widget.index)!.weight % 1 == 0) {
                setState(() => _myController.text = exercisesBox
                    .getAt(widget.index)!
                    .weight
                    .toInt()
                    .toString());
              }
              if (exercisesBox.getAt(widget.index)!.weight % 1 != 0) {
                setState(() => _myController.text =
                    exercisesBox.getAt(widget.index)!.weight.toString());
              }
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text("Exercise Weight",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const Text("Includes weight of bar",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          const SizedBox(height: 10),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-9.]'),
                                  allow: true)
                            ],
                            controller: _myController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 10),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 170,
                                height: 50,
                                child: OutlinedButton(
                                  child: const Text("-5lb"),
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // subtracts 5lb from text box
                                    if (exercisesBox
                                                .getAt(widget.index)!
                                                .weight %
                                            1 ==
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toInt().toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    } else if (exercisesBox
                                                .getAt(widget.index)!
                                                .weight %
                                            1 !=
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 170,
                                  height: 50,
                                  child: OutlinedButton(
                                      child: const Text("+5lb"),
                                      style: OutlinedButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                      ),
                                      onPressed: () {
                                        // adds 5lb to text box
                                        if (exercisesBox
                                                    .getAt(widget.index)!
                                                    .weight %
                                                1 ==
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toInt().toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                        if (exercisesBox
                                                    .getAt(widget.index)!
                                                    .weight %
                                                1 !=
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                      }))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("OK"),
                              onPressed: () {
                                setState(() {
                                  final tempEx =
                                      Hive.box<Exercise>('exercisesBox')
                                          .getAt(widget.index);
                                  tempEx!.weight =
                                      double.parse(_myController.text);
                                  tempEx.save();

                                  for (int i = 0; i < workoutsBox.length; i++) {
                                    final tempWorkout =
                                        Hive.box<Workout>('workoutsBox')
                                            .getAt(i);
                                    for (int j = 0;
                                        j < tempWorkout!.exercises.length;
                                        j++) {
                                      if (tempWorkout.exercises[j].name ==
                                          tempEx.name) {
                                        tempWorkout.exercises[j].weight =
                                            double.parse(_myController.text);
                                      }
                                      tempWorkout.save();
                                    }
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ]),
                        ]),
                  ),
                ),
              );
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Exercise Weight",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                      // if no decimals needed
                      if (exercisesBox.getAt(widget.index)!.weight % 1 == 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.weight.toInt().toString()}lb",
                            style: TextStyle(
                              fontSize: 16,
                              color: greyColor,
                            ),
                          ),
                        ),
                      if (exercisesBox.getAt(widget.index)!.weight % 1 != 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.weight.toString()}lb",
                            style: TextStyle(
                              fontSize: 16,
                              color: greyColor,
                            ),
                          ),
                        ),
                    ]))),
        // bar weight
        TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: () {
              if (exercisesBox.getAt(widget.index)!.barWeight % 1 == 0) {
                setState(() => _myController.text = exercisesBox
                    .getAt(widget.index)!
                    .barWeight
                    .toInt()
                    .toString());
              }
              if (exercisesBox.getAt(widget.index)!.barWeight % 1 != 0) {
                setState(() => _myController.text =
                    exercisesBox.getAt(widget.index)!.barWeight.toString());
              }
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text("Bar Weight",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const Text("Weight of the bar (LB)",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          const SizedBox(height: 10),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-9.]'),
                                  allow: true)
                            ],
                            controller: _myController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(bottom: 10),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 170,
                                height: 50,
                                child: OutlinedButton(
                                  child: const Text("-5lb"),
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // subtracts 5lb from text box
                                    if (exercisesBox
                                                .getAt(widget.index)!
                                                .barWeight %
                                            1 ==
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toInt().toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    } else if (exercisesBox
                                                .getAt(widget.index)!
                                                .barWeight %
                                            1 !=
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 170,
                                  height: 50,
                                  child: OutlinedButton(
                                      child: const Text("+5lb"),
                                      style: OutlinedButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                      ),
                                      onPressed: () {
                                        // adds 5lb to text box
                                        if (exercisesBox
                                                    .getAt(widget.index)!
                                                    .barWeight %
                                                1 ==
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toInt().toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                        if (exercisesBox
                                                    .getAt(widget.index)!
                                                    .barWeight %
                                                1 !=
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                      }))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("OK"),
                              onPressed: () {
                                setState(() {
                                  final tempEx =
                                      Hive.box<Exercise>('exercisesBox')
                                          .getAt(widget.index);
                                  tempEx!.barWeight =
                                      double.parse(_myController.text);
                                  tempEx.save();

                                  for (int i = 0; i < workoutsBox.length; i++) {
                                    final tempWorkout =
                                        Hive.box<Workout>('workoutsBox')
                                            .getAt(i);
                                    for (int j = 0;
                                        j < tempWorkout!.exercises.length;
                                        j++) {
                                      if (tempWorkout.exercises[j].name ==
                                          tempEx.name) {
                                        tempWorkout.exercises[j].barWeight =
                                            double.parse(_myController.text);
                                      }
                                      tempWorkout.save();
                                    }
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ]),
                        ]),
                  ),
                ),
              );
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bar Weight",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                      // if no decimals needed
                      if (exercisesBox.getAt(widget.index)!.barWeight % 1 == 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.barWeight.toInt().toString()}lb",
                            style: TextStyle(
                              fontSize: 16,
                              color: greyColor,
                            ),
                          ),
                        ),
                      if (exercisesBox.getAt(widget.index)!.barWeight % 1 != 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.barWeight.toString()}lb",
                            style: TextStyle(
                              fontSize: 16,
                              color: greyColor,
                            ),
                          ),
                        ),
                    ]))),
        TextButton(
          style: TextButton.styleFrom(
              primary: Colors.white, textStyle: const TextStyle(fontSize: 16)),
          child: Container(
            padding: const EdgeInsets.all(10),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Increments",
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: exercisesBox.getAt(widget.index)!.increment % 1 == 0
                    ? Text(
                        "${exercisesBox.getAt(widget.index)!.increment.toInt().toString()}lb",
                        style: TextStyle(fontSize: 16, color: greyColor))
                    : Text(
                        "${exercisesBox.getAt(widget.index)!.increment.toString()}lb",
                        style: TextStyle(fontSize: 16, color: greyColor)),
              ),
            ]),
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => IncrementsPage(widget.index)))
                .then((value) {
              setState(() {});
            });
          },
        ),
        // sets x reps
        TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: () {
              setState(() => _myController.text =
                  exercisesBox.getAt(widget.index)!.sets.toString());
              setState(() => _myController2.text =
                  exercisesBox.getAt(widget.index)!.reps.toString());

              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text("Sets × Reps",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const Text(
                              "Number of sets and reps for this exercise",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          const SizedBox(height: 20),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-99]'),
                                  allow: true)
                            ],
                            controller: _myController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: InputDecoration(
                              labelText: "Sets",
                              labelStyle:
                                  TextStyle(fontSize: 20, color: textColor),
                              contentPadding: const EdgeInsets.only(bottom: 0),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                  allow: true)
                            ],
                            controller: _myController2,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: InputDecoration(
                              labelText: "Reps",
                              labelStyle:
                                  TextStyle(fontSize: 20, color: textColor),
                              contentPadding: const EdgeInsets.only(bottom: 0),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 20),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 20),
                            TextButton(
                                style: TextButton.styleFrom(
                                  primary: redColor,
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  alignment: Alignment.center,
                                ),
                                child: const Text("OK"),
                                onPressed: () {
                                  int oldReps =
                                      exercisesBox.getAt(widget.index)!.reps;
                                  int oldSets =
                                      exercisesBox.getAt(widget.index)!.sets;
                                  setState(() {
                                    final tempExercise =
                                        Hive.box<Exercise>('exercisesBox')
                                            .getAt(widget.index);

                                    tempExercise!.sets =
                                        int.parse(_myController.text);
                                    tempExercise.reps =
                                        int.parse(_myController2.text);
                                    tempExercise.save();

                                    for (int i = 0;
                                        i < workoutsBox.length;
                                        i++) {
                                      final tempWorkout =
                                          Hive.box<Workout>('workoutsBox')
                                              .getAt(i);
                                      for (int j = 0;
                                          j < tempWorkout!.exercises.length;
                                          j++) {
                                        if (tempWorkout.exercises[j].name ==
                                            exercisesBox
                                                .getAt(widget.index)!
                                                .name) {
                                          tempWorkout.exercises[j].sets =
                                              int.parse(_myController.text);
                                          tempWorkout.exercises[j].reps =
                                              int.parse(_myController2.text);

                                          if (oldSets !=
                                              exercisesBox
                                                  .getAt(widget.index)!
                                                  .sets) {
                                            for (int i = 0;
                                                i <
                                                    exercisesBox
                                                            .getAt(
                                                                widget.index)!
                                                            .sets -
                                                        oldSets;
                                                i++) {
                                              tempWorkout
                                                  .exercises[j].repsCompleted
                                                  .add(exercisesBox
                                                          .getAt(widget.index)!
                                                          .reps +
                                                      1);
                                              exercisesBox
                                                  .getAt(widget.index)!
                                                  .repsCompleted
                                                  .add(exercisesBox
                                                          .getAt(widget.index)!
                                                          .reps +
                                                      1);
                                            }
                                          }
                                          if (oldReps !=
                                              exercisesBox
                                                  .getAt(widget.index)!
                                                  .reps) {
                                            tempWorkout
                                                .exercises[j].repsCompleted
                                                .clear();
                                            exercisesBox
                                                .getAt(widget.index)!
                                                .repsCompleted
                                                .clear();
                                            for (int k = 0;
                                                k <
                                                    exercisesBox
                                                        .getAt(widget.index)!
                                                        .sets;
                                                k++) {
                                              exercisesBox
                                                  .getAt(widget.index)!
                                                  .repsCompleted
                                                  .add(exercisesBox
                                                          .getAt(widget.index)!
                                                          .reps +
                                                      1);

                                              tempWorkout.exercises[j] =
                                                  exercisesBox
                                                      .getAt(widget.index)!;
                                            }
                                          }
                                        }
                                        tempWorkout.save();
                                      }
                                    }
                                  });
                                  Navigator.of(context).pop();
                                }),
                          ]),
                        ]),
                  ),
                ),
              );
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sets × Reps",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${exercisesBox.getAt(widget.index)!.sets.toString()}×${exercisesBox.getAt(widget.index)!.reps.toString()}",
                          style: TextStyle(
                            fontSize: 16,
                            color: greyColor,
                          ),
                        ),
                      ),
                    ]))),
        const SizedBox(height: 10),
        // plate calculator
        TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Plate Calculator",
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                      )),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    plateCalculator(),
                    style: TextStyle(
                      fontSize: 16,
                      color: greyColor,
                    ),
                  ),
                ),
              ]),
            )),
        const SizedBox(height: 5),
        TextButton(
          style: TextButton.styleFrom(
              primary: Colors.white, textStyle: const TextStyle(fontSize: 16)),
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 55,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Change Exercise Name",
                  style: TextStyle(fontSize: 16, color: textColor)),
            ),
          ),
          onPressed: () {
            setState(() =>
                _myController.text = exercisesBox.getAt(widget.index)!.name);
            showDialog(
                context: context,
                builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text("Exercise Name",
                                  style: TextStyle(
                                    fontSize: 18,
                                  )),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _myController,
                                autofocus: true,
                                keyboardType: TextInputType.text,
                                textAlignVertical: TextAlignVertical.bottom,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 10),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                              Divider(
                                color: underlineColor,
                                height: 2,
                                thickness: 2,
                              ),
                              const SizedBox(height: 40),
                              Row(children: <Widget>[
                                const SizedBox(width: 187.4),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: redColor,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    alignment: Alignment.center,
                                  ),
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: redColor,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    alignment: Alignment.center,
                                  ),
                                  child: const Text("OK"),
                                  onPressed: () {
                                    setState(() {
                                      String oldName = exercisesBox
                                          .getAt(widget.index)!
                                          .name;

                                      final tempEx =
                                          Hive.box<Exercise>('exercisesBox')
                                              .getAt(widget.index);
                                      tempEx!.name = _myController.text;
                                      tempEx.save();

                                      // despite Workout class containing list of Exercises,
                                      // updating Exercise in exercisesBox does not update
                                      // the list of exercises in each workout, so we must
                                      // loop through all workouts and update accordingly
                                      for (int i = 0;
                                          i < workoutsBox.length;
                                          i++) {
                                        final tempWorkout =
                                            Hive.box<Workout>('workoutsBox')
                                                .getAt(i);
                                        for (int j = 0;
                                            j < tempWorkout!.exercises.length;
                                            j++) {
                                          if (tempWorkout.exercises[j].name ==
                                              oldName) {
                                            tempWorkout.exercises[j].name =
                                                _myController.text;
                                          }
                                          tempWorkout.save();
                                        }
                                      }
                                    });
                                    _progressCounter.value++;
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ]),
                            ]),
                      ),
                    ));
          },
        ),
      ]),
    );
  }

  String plateCalculator() {
    String output = "";
    // weight per side
    double weight = (exercisesBox.getAt(widget.index)!.weight -
            exercisesBox.getAt(widget.index)!.barWeight) /
        2;

    for (int i = 0; i < platesBox.length; i++) {
      int numPlates = weight ~/ platesBox.getAt(i)!.weight;
      if (numPlates > (platesBox.getAt(i)!.number / 2)) {
        numPlates = platesBox.getAt(i)!.number ~/ 2;
      }
      if (numPlates > 0) {
        output += numPlates.toInt().toString();
        output += '×';
        platesBox.getAt(i)!.weight % 1 == 0
            ? output += platesBox.getAt(i)!.weight.toInt().toString()
            : output += platesBox.getAt(i)!.weight.toString();
        output += ' ⋅ ';
        weight -= numPlates * platesBox.getAt(i)!.weight;
      }
    }
    if (weight != 0) {
      return "Weight cannot be made with your plates";
    } else if (output.isEmpty) {
      return "No plates needed";
    }
    // gets rid of dot at end
    else {
      return output.substring(0, output.length - 3);
    }
  }
}

class _IncrementsPageState extends State<IncrementsPage> {
  late final Box<Exercise> exercisesBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
  }

  void toggleSwitch(bool value) {
    final tempExercise = Hive.box<Exercise>('exercisesBox').getAt(widget.index);
    if (tempExercise!.overload == false) {
      setState(() {
        tempExercise.overload = true;
        tempExercise.save();
      });
    } else {
      setState(() {
        tempExercise.overload = false;
        tempExercise.save();
      });
    }
  }

  void toggleSwitch2(bool value) {
    final tempExercise = Hive.box<Exercise>('exercisesBox').getAt(widget.index);
    if (tempExercise!.deload == false) {
      setState(() {
        tempExercise.deload = true;
        tempExercise.save();
      });
    } else {
      setState(() {
        tempExercise.deload = false;
        tempExercise.save();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: const Text("Increments"),
        titleTextStyle: TextStyle(fontSize: 22, color: textColor),
      ),
      body: ListView(children: <Widget>[
        SizedBox(
          height: 91,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Progressive Overload",
                              style:
                                  TextStyle(fontSize: 18, color: textColor))),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Add weight if all sets successful",
                            style: TextStyle(fontSize: 16, color: greyColor)),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        inactiveThumbColor: greyColor,
                        inactiveTrackColor:
                            const Color.fromARGB(255, 207, 207, 207),
                        activeColor: activeSwitchColor,
                        activeTrackColor: greyColor,
                        value: exercisesBox.getAt(widget.index)!.overload,
                        onChanged: toggleSwitch,
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
            onPressed: (() => toggleSwitch(false)),
          ),
        ),
        exercisesBox.getAt(widget.index)!.overload
            ? SizedBox(
                height: 80,
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: _incrementsCounter,
                    builder: (context, value, child) {
                      return TextButton(
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Row(children: <Widget>[
                              Expanded(
                                child: Column(children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Increments",
                                        style: TextStyle(
                                            fontSize: 18, color: textColor)),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: exercisesBox
                                                    .getAt(widget.index)!
                                                    .increment %
                                                1 ==
                                            0
                                        ? Text(
                                            "${exercisesBox.getAt(widget.index)!.increment.toInt().toString()}lb",
                                            style: TextStyle(
                                                fontSize: 16, color: greyColor))
                                        : Text(
                                            "${exercisesBox.getAt(widget.index)!.increment.toString()}lb",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: greyColor)),
                                  ),
                                ]),
                              ),
                            ]),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => incrementSelector());
                          });
                    }))
            : const SizedBox(),
        exercisesBox.getAt(widget.index)!.overload
            ? SizedBox(
                height: 80,
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: _incrementsCounter,
                    builder: (context, value, child) {
                      return TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Row(children: <Widget>[
                            Expanded(
                              child: Column(children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Frequency",
                                      style: TextStyle(
                                          fontSize: 18, color: textColor)),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: exercisesBox
                                              .getAt(widget.index)!
                                              .incrementFrequency ==
                                          1
                                      ? Text("Every Time",
                                          style: TextStyle(
                                              fontSize: 16, color: greyColor))
                                      : Text(
                                          "Every ${exercisesBox.getAt(widget.index)!.incrementFrequency.toString()} Times",
                                          style: TextStyle(
                                              fontSize: 16, color: greyColor)),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => frequencySelector());
                        },
                      );
                    }),
              )
            : const SizedBox(),
        exercisesBox.getAt(widget.index)!.overload
            ? Flexible(
                child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: _incrementsCounter,
                    builder: (context, value, child) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: circleColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: exercisesBox.getAt(widget.index)!.increment %
                                    1 ==
                                0
                            ? exercisesBox
                                        .getAt(widget.index)!
                                        .incrementFrequency ==
                                    1
                                ? Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment.toInt()}lb in total if you completed all sets on this exercise the last time.",
                                    style: TextStyle(
                                        fontSize: 14, color: greyColor))
                                : Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment.toInt()}lb in total if you completed all sets on this exercise the last ${exercisesBox.getAt(widget.index)!.incrementFrequency} times.",
                                    style: TextStyle(
                                        fontSize: 14, color: greyColor))
                            : exercisesBox
                                        .getAt(widget.index)!
                                        .incrementFrequency ==
                                    1
                                ? Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment}lb in total if you completed all sets on this exercise the last time.",
                                    style: TextStyle(
                                        fontSize: 14, color: greyColor))
                                : Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment}lb in total if you completed all sets on this exercise the last ${exercisesBox.getAt(widget.index)!.incrementFrequency} times.",
                                    style: TextStyle(
                                        fontSize: 14, color: greyColor)),
                      );
                    }),
              ))
            : const SizedBox(),
        SizedBox(
          height: 91,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Deload",
                            style: TextStyle(fontSize: 18, color: textColor)),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Decrease weight if failed sets",
                            style: TextStyle(fontSize: 16, color: greyColor)),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        inactiveThumbColor: greyColor,
                        inactiveTrackColor:
                            const Color.fromARGB(255, 207, 207, 207),
                        activeColor: activeSwitchColor,
                        activeTrackColor: greyColor,
                        value: exercisesBox.getAt(widget.index)!.deload,
                        onChanged: toggleSwitch2,
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
            onPressed: (() => toggleSwitch2(false)),
          ),
        ),
        exercisesBox.getAt(widget.index)!.deload
            ? SizedBox(
                height: 80,
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: _incrementsCounter,
                    builder: (context, value, child) {
                      return TextButton(
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              textStyle: const TextStyle(fontSize: 16)),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Row(children: <Widget>[
                              Expanded(
                                child: Column(children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Percentage",
                                        style: TextStyle(
                                            fontSize: 18, color: textColor)),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "${exercisesBox.getAt(widget.index)!.deloadPercent.toString()}%",
                                        style: TextStyle(
                                            fontSize: 16, color: greyColor)),
                                  ),
                                ]),
                              ),
                            ]),
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => percentageSelector());
                          });
                    }))
            : const SizedBox(),
        exercisesBox.getAt(widget.index)!.deload
            ? SizedBox(
                height: 80,
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: _incrementsCounter,
                    builder: (context, value, child) {
                      return TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Row(children: <Widget>[
                            Expanded(
                              child: Column(children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Frequency",
                                      style: TextStyle(
                                          fontSize: 18, color: textColor)),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: exercisesBox
                                              .getAt(widget.index)!
                                              .deloadFrequency ==
                                          1
                                      ? Text("Every Time",
                                          style: TextStyle(
                                              fontSize: 16, color: greyColor))
                                      : Text(
                                          "Every ${exercisesBox.getAt(widget.index)!.deloadFrequency.toString()} Times",
                                          style: TextStyle(
                                              fontSize: 16, color: greyColor)),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => deloadFrequencySelector());
                        },
                      );
                    }),
              )
            : const SizedBox(),
        exercisesBox.getAt(widget.index)!.deload
            ? Flexible(
                child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: _incrementsCounter,
                    builder: (context, value, child) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: circleColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: exercisesBox
                                    .getAt(widget.index)!
                                    .deloadFrequency ==
                                1
                            ? Text(
                                "Weight decreases by ${exercisesBox.getAt(widget.index)!.deloadPercent}% if you failed to complete all sets on this exercise the last time.",
                                style:
                                    TextStyle(fontSize: 14, color: greyColor))
                            : Text(
                                "Weight decreases by ${exercisesBox.getAt(widget.index)!.deloadPercent}% if you failed to complete all sets on this exercise the last ${exercisesBox.getAt(widget.index)!.deloadFrequency} times.",
                                style:
                                    TextStyle(fontSize: 14, color: greyColor)),
                      );
                    }),
              ))
            : const SizedBox(),
      ]),
    );
  }

  Widget incrementSelector() {
    final _myController = TextEditingController();

    exercisesBox.getAt(widget.index)!.increment % 1 == 0
        ? _myController.text =
            exercisesBox.getAt(widget.index)!.increment.toInt().toString()
        : _myController.text =
            exercisesBox.getAt(widget.index)!.increment.toString();
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Increments",
                  style: TextStyle(
                    fontSize: 18,
                  )),
              const Text("Weight added each increment",
                  style: TextStyle(
                    fontSize: 14,
                  )),
              const SizedBox(height: 10),
              TextField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
                ],
                controller: _myController,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 10),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              Divider(
                color: underlineColor,
                height: 2,
                thickness: 2,
              ),
              const SizedBox(height: 40),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: OutlinedButton(
                      child: const Text("-5lb"),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      onPressed: () {
                        // subtracts 5lb from text box
                        double tempText = double.parse(_myController.text);
                        if (tempText % 1 == 0) {
                          setState(() {
                            if (tempText <= 5) {
                              _myController.text = "0";
                            } else {
                              tempText -= 5;
                              _myController.text = tempText.toInt().toString();
                            }
                            _myController.selection = TextSelection.collapsed(
                                offset: _myController.text.length);
                          });
                        } else {
                          setState(() {
                            if (tempText <= 5) {
                              _myController.text = "0";
                            } else {
                              tempText -= 5;
                              _myController.text = tempText.toString();
                            }
                            _myController.selection = TextSelection.collapsed(
                                offset: _myController.text.length);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 170,
                      height: 50,
                      child: OutlinedButton(
                        child: const Text("+5lb"),
                        style: OutlinedButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                        onPressed: () {
                          // subtracts 5lb from text box
                          double tempText = double.parse(_myController.text);
                          if (tempText % 1 == 0) {
                            setState(() {
                              tempText += 5;
                              _myController.text = tempText.toInt().toString();
                              _myController.selection = TextSelection.collapsed(
                                  offset: _myController.text.length);
                            });
                          } else {
                            setState(() {
                              tempText += 5;
                              _myController.text = tempText.toString();
                              _myController.selection = TextSelection.collapsed(
                                  offset: _myController.text.length);
                            });
                          }
                        },
                      ))
                ],
              ),
              const SizedBox(height: 20),
              Row(children: <Widget>[
                const SizedBox(width: 187.4),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("OK"),
                  onPressed: () {
                    final tempExercise =
                        Hive.box<Exercise>('exercisesBox').getAt(widget.index);
                    tempExercise!.increment = double.parse(_myController.text);
                    tempExercise.save();

                    _incrementsCounter.value++;
                    Navigator.of(context).pop();
                  },
                ),
              ]),
            ]),
      ),
    );
  }

  Widget frequencySelector() {
    final _controller = FixedExtentScrollController(
        initialItem: exercisesBox.getAt(widget.index)!.incrementFrequency - 1);
    int freq = exercisesBox.getAt(widget.index)!.incrementFrequency;

    List<Widget> freqs = [
      for (int i = 1; i < 11; i++) ListTile(title: Text(i.toString())),
    ];

    return Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Frequency",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  const SizedBox(height: 30),
                  Flexible(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        const SizedBox(
                          width: 60,
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("Every",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                        SizedBox(
                            height: 120,
                            width: 60,
                            child: CupertinoPicker(
                              scrollController: _controller,
                              children: freqs,
                              looping: true,
                              diameterRatio: 1.25,
                              selectionOverlay: Column(children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                  color: textColor,
                                  width: 2,
                                )))),
                                const SizedBox(height: 50),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                  color: textColor,
                                  width: 2,
                                ))))
                              ]),
                              itemExtent: 75,
                              onSelectedItemChanged: (index) => {
                                freq = index + 1,
                              },
                            )),
                        const SizedBox(
                          width: 60,
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("times",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ])),
                  const SizedBox(height: 30),
                  Row(children: <Widget>[
                    const SizedBox(width: 187.4),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        setState(() {
                          final tempExercise =
                              Hive.box<Exercise>('exercisesBox')
                                  .getAt(widget.index);
                          tempExercise!.incrementFrequency = freq;
                          tempExercise.save();

                          _incrementsCounter.value++;
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ]),
                ])));
  }

  Widget percentageSelector() {
    final _controller = FixedExtentScrollController(
        initialItem: exercisesBox.getAt(widget.index)!.deloadPercent - 1);
    int percent = exercisesBox.getAt(widget.index)!.deloadPercent;

    List<Widget> percentages = [
      for (int i = 1; i < 100; i++) ListTile(title: Text(i.toString())),
    ];

    return Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Percentage",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  const SizedBox(height: 30),
                  Flexible(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        SizedBox(
                            height: 120,
                            width: 60,
                            child: CupertinoPicker(
                              scrollController: _controller,
                              children: percentages,
                              looping: true,
                              diameterRatio: 1.25,
                              selectionOverlay: Column(children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                  color: textColor,
                                  width: 2,
                                )))),
                                const SizedBox(height: 50),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                  color: textColor,
                                  width: 2,
                                ))))
                              ]),
                              itemExtent: 75,
                              onSelectedItemChanged: (index) => {
                                percent = index + 1,
                              },
                            )),
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("%",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ])),
                  const SizedBox(height: 30),
                  Row(children: <Widget>[
                    const SizedBox(width: 187.4),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        setState(() {
                          final tempExercise =
                              Hive.box<Exercise>('exercisesBox')
                                  .getAt(widget.index);
                          tempExercise!.deloadPercent = percent;
                          tempExercise.save();

                          _incrementsCounter.value++;
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ]),
                ])));
  }

  Widget deloadFrequencySelector() {
    final _controller = FixedExtentScrollController(
        initialItem: exercisesBox.getAt(widget.index)!.deloadFrequency - 1);
    int freq = exercisesBox.getAt(widget.index)!.deloadFrequency;

    List<Widget> freqs = [
      for (int i = 1; i < 11; i++) ListTile(title: Text(i.toString())),
    ];

    return Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Frequency",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  const SizedBox(height: 30),
                  Flexible(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        const SizedBox(
                          width: 60,
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("Every",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                        SizedBox(
                            height: 120,
                            width: 60,
                            child: CupertinoPicker(
                              scrollController: _controller,
                              children: freqs,
                              looping: true,
                              diameterRatio: 1.25,
                              selectionOverlay: Column(children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                  color: textColor,
                                  width: 2,
                                )))),
                                const SizedBox(height: 50),
                                Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            top: BorderSide(
                                  color: textColor,
                                  width: 2,
                                ))))
                              ]),
                              itemExtent: 75,
                              onSelectedItemChanged: (index) => {
                                freq = index + 1,
                              },
                            )),
                        const SizedBox(
                          width: 60,
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("times",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                      ])),
                  const SizedBox(height: 30),
                  Row(children: <Widget>[
                    const SizedBox(width: 187.4),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        setState(() {
                          final tempExercise =
                              Hive.box<Exercise>('exercisesBox')
                                  .getAt(widget.index);
                          tempExercise!.deloadFrequency = freq;
                          tempExercise.save();

                          _incrementsCounter.value++;
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ]),
                ])));
  }
}

class _PostWorkoutEditState extends State<PostWorkoutEditPage> {
  List<Widget> nums = [
    for (int i = 50; i < 700; i++) ListTile(title: Text(i.toString())),
  ];
  List<Widget> decs = [
    for (int i = 0; i < 10; i++) ListTile(title: Text(i.toString())),
  ];

  List<int> copySetsPlanned = [];
  List<int> copyRepsPlanned = [];
  List<double> copyWeights = [];

  double postTempBodyWeight = 0;
  TextEditingController dateinput = TextEditingController();
  String originalDate = "";
  String dateChange = "";
  String sortableDateChange = "";
  late DateTime tempDate;

  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    dateinput.text = indivWorkoutsBox.getAt(widget.index)!.date.substring(5);
    dateChange = indivWorkoutsBox.getAt(widget.index)!.date;
    originalDate = indivWorkoutsBox.getAt(widget.index)!.date;
    tempDate = DateTime.parse(indivWorkoutsBox.getAt(widget.index)!.sortableDate);
    postTempBodyWeight = indivWorkoutsBox.getAt(widget.index)!.bodyWeight;
    // yet again roundabout way of making a copy
    for (int i = 0;
        i < indivWorkoutsBox.getAt(widget.index)!.setsPlanned.length;
        i++) {
      copySetsPlanned.add(indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]);
    }
    for (int i = 0;
        i < indivWorkoutsBox.getAt(widget.index)!.repsPlanned.length;
        i++) {
      copyRepsPlanned.add(indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]);
    }
    for (int i = 0;
        i < indivWorkoutsBox.getAt(widget.index)!.weights.length;
        i++) {
      copyWeights.add(indivWorkoutsBox.getAt(widget.index)!.weights[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // handles back button
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 18,
              onPressed: () => _onBackPressed()),
          backgroundColor: headerColor,
          title: Center(
              child: SizedBox(
                  height: 40,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: circleColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextButton(
                              child: Text(dateinput.text, // workout date
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  )),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    helpText: "",
                                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                                    initialDate: tempDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.red, // header background color
                                            onPrimary: Colors.white, // header text color
                                            onSurface: textColor, // body text color
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              primary: Colors.red, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });
                                setState(() {
                                  tempDate = pickedDate!;
                                  dateinput.text = DateFormat('d MMM yyyy')
                                      .format(pickedDate);
                                  dateChange = DateFormat('E, d MMM yyyy')
                                      .format(pickedDate);
                                  sortableDateChange =
                                      DateFormat('yyyyMMdd').format(pickedDate);
                                });
                              }))))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Save"),
              onPressed: () {
                final tempIndiv = Hive.box<IndivWorkout>('indivWorkoutsBox')
                    .getAt(widget.index);

                tempIndiv!.note = postWorkoutTempNote;
                tempIndiv.bodyWeight = postTempBodyWeight;

                postWorkoutTempNote = "";

                if (originalDate != dateChange) {
                  tempIndiv.date = dateChange;
                  tempIndiv.sortableDate = sortableDateChange;

                  List<IndivWorkout> copyIndivs = [];
                  // again, no deep copies. workaround
                  // sorts workouts by date on date change
                  // to ensure list page is ordered by date
                  for (int i = 0; i < indivWorkoutsBox.length; i++) {
                    copyIndivs.add(indivWorkoutsBox.getAt(i)!);
                  }
                  copyIndivs.sort((a, b) {
                    return a.sortableDate.compareTo(b.sortableDate);
                  });
                  indivWorkoutsBox.deleteAll(indivWorkoutsBox.keys);
                  for (int i = 0; i < copyIndivs.length; i++) {
                    indivWorkoutsBox.add(copyIndivs[i]);
                  }
                }
                tempIndiv.save();
                _calendarCounter.value++;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: Column(children: <Widget>[
              Flexible(
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                    for (int i = 0;
                        i <
                            indivWorkoutsBox
                                .getAt(widget.index)!
                                .repsCompleted
                                .length;
                        i++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    indivWorkoutsBox
                                        .getAt(widget.index)!
                                        .exercisesCompleted[i],
                                    style: const TextStyle(
                                      fontSize: 17,
                                    )),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                      onTap: () =>
                                          _weightsSetsReps(widget.index, i),
                                      child: Row(children: <Widget>[
                                        if (indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .weights[i] %
                                                1 ==
                                            0)
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]}×${indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]} ${indivWorkoutsBox.getAt(widget.index)!.weights[i] ~/ 1}lb",
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      ))))
                                        else
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]}×${indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]} ${indivWorkoutsBox.getAt(widget.index)!.weights[i].toString()}lb",
                                                      style: const TextStyle(
                                                          fontSize: 17)))),
                                        SizedBox(
                                          width: 17,
                                          child: IconButton(
                                            onPressed: () => _weightsSetsReps(
                                                widget.index, i),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.all(0),
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: const Icon(
                                                Icons.arrow_right_sharp),
                                            color: redColor,
                                            iconSize: 20,
                                          ),
                                        ),
                                      ])))),
                        ]),
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  // one circle for each set, initialized with number of reps
                                  for (int j = 0;
                                      j <
                                          indivWorkoutsBox
                                              .getAt(widget.index)!
                                              .setsPlanned[i];
                                      j++)
                                    // circle, onTap decrement, loops back to rep number
                                    SizedBox(
                                      width: 78,
                                      height: 50,
                                      child: MaterialButton(
                                        elevation: 0,
                                        splashColor: Colors.transparent,
                                        animationDuration:
                                            const Duration(milliseconds: 0),
                                        shape: const CircleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                style: BorderStyle.none)),
                                        child: indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsCompleted[i][j] >
                                                indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsPlanned[i]
                                            ? Text(
                                                indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsPlanned[i]
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 18))
                                            : Text(
                                                indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsCompleted[i][j]
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 18)),
                                        color: indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsCompleted[i][j] >
                                                indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsPlanned[i]
                                            ? circleColor
                                            : redColor,
                                        textColor: indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsCompleted[i][j] >
                                                indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsPlanned[i]
                                            ? emptyCircleTextColor
                                            : Colors.white,
                                        onPressed: () {
                                          final tempIndiv =
                                              Hive.box<IndivWorkout>(
                                                      'indivWorkoutsBox')
                                                  .getAt(widget.index);
                                          // loops around
                                          if (tempIndiv!.repsCompleted[i][j] ==
                                              0) {
                                            setState(() => tempIndiv
                                                    .repsCompleted[i][j] =
                                                tempIndiv.repsPlanned[i] + 1);
                                          } else {
                                            setState(() => tempIndiv
                                                .repsCompleted[i][j] -= 1);
                                          }
                                        },
                                      ),
                                    ),
                                ]),
                              ]),
                        ),
                        const SizedBox(height: 10),
                      ]),
                  ])),
              Container(
                  padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                            child: Center(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Body Weight",
                                        style: TextStyle(
                                          fontSize: 17,
                                        ))))),
                        Expanded(
                            child: Center(
                                child: GestureDetector(
                                    onTap: () {
                                      // sets initial scroll to weight
                                      final _intController =
                                          FixedExtentScrollController(
                                              initialItem:
                                                  postTempBodyWeight ~/ 1 - 50);
                                      // annoying floating point precision: 100.6 - 100 = 0.599
                                      // the +0.05 is a way around it
                                      final _decController =
                                          FixedExtentScrollController(
                                              initialItem: (postTempBodyWeight -
                                                      (postTempBodyWeight ~/
                                                          1) +
                                                      0.05) *
                                                  10 ~/
                                                  1);
                                      int scrollBodyWeightInt =
                                          postTempBodyWeight ~/ 1;
                                      int scrollBodyWeightDec =
                                          (postTempBodyWeight -
                                                  (postTempBodyWeight ~/ 1)) *
                                              10 ~/
                                              1;
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text("Weight",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                            )),
                                                        const SizedBox(
                                                            height: 30),
                                                        Flexible(
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                              SizedBox(
                                                                  height: 120,
                                                                  width: 70,
                                                                  child:
                                                                      CupertinoPicker(
                                                                    scrollController:
                                                                        _intController,
                                                                    children:
                                                                        nums,
                                                                    looping:
                                                                        true,
                                                                    diameterRatio:
                                                                        1.25,
                                                                    selectionOverlay:
                                                                        Column(children: <
                                                                            Widget>[
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      )))),
                                                                      const SizedBox(
                                                                          height:
                                                                              50),
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      ))))
                                                                    ]),
                                                                    itemExtent:
                                                                        75,
                                                                    onSelectedItemChanged:
                                                                        (index) =>
                                                                            {
                                                                      scrollBodyWeightInt =
                                                                          index +
                                                                              50,
                                                                    },
                                                                  )),
                                                              const SizedBox(
                                                                width: 20,
                                                                height: 45,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child: Text(
                                                                      ".",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      )),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 120,
                                                                  width: 70,
                                                                  child:
                                                                      CupertinoPicker(
                                                                    scrollController:
                                                                        _decController,
                                                                    children:
                                                                        decs,
                                                                    looping:
                                                                        true,
                                                                    diameterRatio:
                                                                        1.25,
                                                                    selectionOverlay:
                                                                        Column(children: <
                                                                            Widget>[
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      )))),
                                                                      const SizedBox(
                                                                          height:
                                                                              50),
                                                                      Container(
                                                                          decoration: BoxDecoration(
                                                                              border: Border(
                                                                                  top: BorderSide(
                                                                        color:
                                                                            textColor,
                                                                        width:
                                                                            2,
                                                                      ))))
                                                                    ]),
                                                                    itemExtent:
                                                                        75,
                                                                    onSelectedItemChanged:
                                                                        (index) =>
                                                                            {
                                                                      scrollBodyWeightDec =
                                                                          index,
                                                                    },
                                                                  )),
                                                              const SizedBox(
                                                                width: 20,
                                                                height: 40,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child: Text(
                                                                      "lb",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                      )),
                                                                ),
                                                              ),
                                                            ])),
                                                        const SizedBox(
                                                            height: 30),
                                                        Row(children: <Widget>[
                                                          const SizedBox(
                                                              width: 187.4),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "Cancel"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              setState(
                                                                () => postTempBodyWeight =
                                                                    scrollBodyWeightInt +
                                                                        0.1 *
                                                                            scrollBodyWeightDec,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ]),
                                                      ]))));
                                    },
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "${postTempBodyWeight.toString()}lb",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: redColor,
                                              fontWeight: FontWeight.bold,
                                            )))))),
                      ])),
            ])),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Container(
            padding: const EdgeInsets.only(left: 25),
            child: Row(children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                PostWorkoutNotesPage(widget.index)));
                      },
                      child: const Text("Note"),
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        alignment: Alignment.bottomCenter,
                      )),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () {
                        indivWorkoutsBox.deleteAt(widget.index);
                        _calendarCounter.value++;
                        Navigator.of(context).pop();
                      },
                      child: const Text("Delete"),
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        alignment: Alignment.bottomCenter,
                      )),
                ),
              ),
            ])),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    // reverts to old reps completed, sets planned, reps planned, weights
    indivWorkoutsBox.getAt(widget.index)!.repsCompleted =
        widget.copyRepsCompleted;
    indivWorkoutsBox.getAt(widget.index)!.setsPlanned = copySetsPlanned;
    indivWorkoutsBox.getAt(widget.index)!.repsPlanned = copyRepsPlanned;
    indivWorkoutsBox.getAt(widget.index)!.weights = copyWeights;
    Navigator.of(context).pop();
    return true;
  }

  void _weightsSetsReps(int idx, int exIdx) {
    final _myController = TextEditingController();
    final _myController2 = TextEditingController();
    final _weightsController = TextEditingController();
    _myController.text =
        indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx].toString();
    _myController2.text =
        indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx].toString();

    indivWorkoutsBox.getAt(idx)!.weights[exIdx] % 1 == 0
        ? _weightsController.text =
            indivWorkoutsBox.getAt(idx)!.weights[exIdx].toInt().toString()
        : _weightsController.text =
            indivWorkoutsBox.getAt(idx)!.weights[exIdx].toString();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Edit Exercise",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                const Text("Changes are only for this individual workout",
                    style: TextStyle(
                      fontSize: 14,
                    )),
                const SizedBox(height: 20),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
                  ],
                  controller: _weightsController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    labelText: "Weight",
                    labelStyle: TextStyle(fontSize: 20, color: textColor),
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: underlineColor,
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(height: 30),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(RegExp(r'[0-99]'), allow: true)
                  ],
                  controller: _myController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    labelText: "Sets",
                    labelStyle: TextStyle(fontSize: 20, color: textColor),
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: underlineColor,
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(height: 30),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
                  ],
                  controller: _myController2,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    labelText: "Reps",
                    labelStyle: TextStyle(fontSize: 20, color: textColor),
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: underlineColor,
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(height: 20),
                Row(children: <Widget>[
                  const SizedBox(width: 187.4),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: redColor,
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      alignment: Alignment.center,
                    ),
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        int oldReps =
                            indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx];
                        int oldSets =
                            indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx];
                        setState(() => {
                              indivWorkoutsBox.getAt(idx)!.weights[exIdx] =
                                  double.parse(_weightsController.text),
                              indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx] =
                                  int.parse(_myController.text),
                              indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx] =
                                  int.parse(_myController2.text),
                              if (oldSets !=
                                  indivWorkoutsBox
                                      .getAt(idx)!
                                      .setsPlanned[exIdx])
                                {
                                  for (int i = 0;
                                      i <
                                          indivWorkoutsBox
                                                  .getAt(idx)!
                                                  .setsPlanned[exIdx] -
                                              oldSets;
                                      i++)
                                    {
                                      indivWorkoutsBox
                                          .getAt(idx)!
                                          .repsCompleted[exIdx]
                                          .add(indivWorkoutsBox
                                                  .getAt(idx)!
                                                  .repsPlanned[exIdx] +
                                              1),
                                    },
                                },
                              if (oldReps !=
                                  indivWorkoutsBox
                                      .getAt(idx)!
                                      .repsPlanned[exIdx])
                                {
                                  indivWorkoutsBox
                                      .getAt(idx)!
                                      .repsCompleted[exIdx]
                                      .clear(),
                                  for (int j = 0;
                                      j <
                                          indivWorkoutsBox
                                              .getAt(idx)!
                                              .setsPlanned[exIdx];
                                      ++j)
                                    {
                                      indivWorkoutsBox
                                          .getAt(idx)!
                                          .repsCompleted[exIdx]
                                          .add(indivWorkoutsBox
                                                  .getAt(idx)!
                                                  .repsPlanned[exIdx] +
                                              1),
                                    },
                                }
                            });
                        Navigator.of(context).pop();
                      }),
                ]),
              ]),
        ),
      ),
    );
  }
}
