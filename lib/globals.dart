import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blocklifts/classes/exercise.dart';

Exercise customxyz =
    Exercise("Custom Exercise", 0, 0, 0, true, 1, 5, true, 10, 3);

String postWorkoutTempNote = "";

Timer? timer;
Duration duration = const Duration();
Timer? workoutTimer;
Duration workoutDuration = const Duration();
bool lastSet = false;
bool pushInProgress = false;
bool changesMade = false;
late String lbKg;

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

ValueNotifier<int> circleCounter = ValueNotifier<int>(0); // to update circles
ValueNotifier<int> plateCounter =
    ValueNotifier<int>(0); // refreshes plates list
ValueNotifier<int> incrementsCounter = ValueNotifier<int>(0); // for increments
ValueNotifier<int> graphCounter = ValueNotifier<int>(0); // to update graph text
