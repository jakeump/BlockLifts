import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blocklifts/classes/exercise.dart';

Exercise customxyz = Exercise("Custom Exercise", 0, 0, 0);

String postWorkoutTempNote = "";

Timer? timer;
Duration duration = const Duration();
Timer? workoutTimer;
Duration workoutDuration = const Duration();
bool showTimer = false;
bool lastSet = false;
int workoutIndex = 0;
int exerciseIndex = 0;
int setIndex = 0;
late bool failed;
bool changesMade = false;
late String lbKg;
bool workoutTimerInProgress = false;

List<int> successTimes = [];
List<int> failureTimes = [];

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

ValueNotifier<int> counter = ValueNotifier<int>(0); // dark mode, etc
ValueNotifier<int> circleCounter = ValueNotifier<int>(0); // to update circles
ValueNotifier<int> timerCounter =
    ValueNotifier<int>(0); // for timer on workout page
ValueNotifier<int> workoutTimerCounter =
    ValueNotifier<int>(0); // for timer on home page
ValueNotifier<int> plateCounter =
    ValueNotifier<int>(0); // refrehes plates list
ValueNotifier<int> incrementsCounter = ValueNotifier<int>(0); // for increments
ValueNotifier<int> graphCounter =
    ValueNotifier<int>(0); // to update graph text
ValueNotifier<int> progressCounter =
    ValueNotifier<int>(0); // for progress page
ValueNotifier<int> calendarCounter =
    ValueNotifier<int>(0); // for calendar page
ValueNotifier<int> themeCounter = ValueNotifier<int>(0); // for dark/light mode
