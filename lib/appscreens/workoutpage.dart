import 'package:blocklifts/providers/progressprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/functions/increment_circles.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:blocklifts/classes/plate.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/appscreens/editexercisepage.dart';
import 'package:blocklifts/appscreens/workoutnotespage.dart';
import 'package:blocklifts/appscreens/editworkoutpage.dart';
import 'package:blocklifts/providers/listprovider.dart';
import 'package:blocklifts/providers/homeprovider.dart';
import 'package:blocklifts/providers/calendarprovider.dart';
import 'package:blocklifts/providers/notesprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class WorkoutPage extends StatefulWidget {
  final int index;
  const WorkoutPage(this.index, {Key? key}) : super(key: key);
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
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
    globals.timer = Timer.periodic(
        const Duration(seconds: 1), (_) => {addTime(globals.timer)});
    globals.workoutTimer = Timer.periodic(const Duration(seconds: 1),
        (_) => {addWorkoutTime(globals.workoutTimer)});
  }

  void getTimes() {
    globals.successTimes.clear();
    globals.failureTimes.clear();
    for (int i = 0; i < successTimerBox.length; i++) {
      globals.successTimes.add(successTimerBox.getAt(i)!.time);
    }
    for (int i = 0; i < failTimerBox.length; i++) {
      globals.failureTimes.add(failTimerBox.getAt(i)!.time);
    }
    globals.successTimes.sort();
    globals.failureTimes.sort();
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

  void checkWorkoutInProgress(int idx) {
    boolBox.putAt(5, false);
    final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(idx);
    if (tempNoteBox.getAt(0) != "") {
      boolBox.putAt(5, true);
    }
    for (int i = 0; i < workoutsBox.getAt(idx)!.exercises.length; ++i) {
      for (int j = 0; j < workoutsBox.getAt(idx)!.exercises[i].sets; j++) {
        if (tempWorkout!.exercises[i].repsCompleted[j] !=
            tempWorkout.exercises[i].reps + 1) {
          boolBox.putAt(5, true);
        }
      }
    }
    if (boolBox.getAt(5)!) {
      counterBox.putAt(0, idx);
    } else if (!boolBox.getAt(5)!) {
      Wakelock.disable();
      counterBox.putAt(0, counterBox.getAt(1)!);
      globals.workoutTimerInProgress = false;
      globals.workoutDuration = const Duration(seconds: 0);
    }
    var homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.updateHome();
  }

  void switchWorkout(int idx) {
    setState(() {
      globals.showTimer = false;
      tempNoteBox.putAt(0, "");
      for (int j = 0; j < workoutsBox.getAt(idx)!.exercises.length; ++j) {
        final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(idx);
        tempWorkout!.exercises[j].repsCompleted.clear();
        for (int k = 0; k < tempWorkout.exercises[j].sets; k++) {
          // repsCompleted initialized with initial reps value
          tempWorkout.exercises[j].repsCompleted
              .add(workoutsBox.getAt(idx)!.exercises[j].reps + 1);
          tempWorkout.save();
        }
      }
      Navigator.of(context).pop();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => WorkoutPage(idx)));
    });
    boolBox.putAt(5, false);
  }

  @override
  Widget build(BuildContext context) {
    boolBox.getAt(6)! ? Wakelock.enable() : Wakelock.disable();
    Workout? selectVal = workoutsBox.getAt(0);
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            backgroundColor: globals.backColor,
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                iconSize: 18,
                onPressed: () {
                  checkWorkoutInProgress(widget.index);
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: globals.headerColor,
              title: Center(
                  child: SizedBox(
                      height: 40,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: globals.circleColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 10),
                              child: DropdownButton(
                                dropdownColor: globals.circleColor,
                                itemHeight: null,
                                underline: const SizedBox(),
                                isExpanded: false,
                                items: workoutsList.map((Workout workout) {
                                  return DropdownMenuItem<Workout>(
                                      value: workout,
                                      child: Text(workout.name));
                                }).toList(),
                                value: selectVal,
                                selectedItemBuilder: (context) {
                                  return [
                                    Expanded(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .45),
                                              child: Text(
                                                  workoutsList[widget.index]
                                                      .name,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ))),
                                  ];
                                },
                                onChanged: (Workout? w) {
                                  checkWorkoutInProgress(widget.index);
                                  selectVal = w;
                                  int idx = workoutsList.indexOf(selectVal!);
                                  if (idx != widget.index) {
                                    if (boolBox.getAt(5)!) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: globals.tileColor,
                                          title: Text('Switch Workout?',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: globals.textColor)),
                                          content: Text(
                                              'This will delete this workout, erasing all sets and notes entered.',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: globals.textColor)),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: globals.redColor),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                switchWorkout(idx);
                                              },
                                              child: const Text(
                                                'Switch',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: globals.redColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      switchWorkout(idx);
                                    }
                                  }
                                },
                              ))))),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: globals.redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("Finish"),
                  onPressed: () {
                    bool complete = true;
                    bool allIncomplete = true;
                    for (int i = 0;
                        i < workoutsBox.getAt(widget.index)!.exercises.length;
                        i++) {
                      for (int j = 0;
                          j <
                              workoutsBox
                                  .getAt(widget.index)!
                                  .exercises[i]
                                  .sets;
                          j++) {
                        if (workoutsBox
                                .getAt(widget.index)!
                                .exercises[i]
                                .repsCompleted[j] ==
                            workoutsBox.getAt(widget.index)!.exercises[i].reps +
                                1) {
                          complete = false;
                        } else {
                          allIncomplete = false;
                        }
                      }
                    }
                    if (!complete) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                backgroundColor: globals.tileColor,
                                title: Text('Finish Workout?',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: globals.textColor)),
                                content: Text(
                                    'You haven\'t logged all sets. Are you sure you want to finish this workout?',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: globals.textColor)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: globals.redColor),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      if (allIncomplete) {
                                      } else {
                                        workoutFinish();
                                      }
                                    },
                                    child: const Text(
                                      'Finish',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: globals.redColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                    } else {
                      workoutFinish();
                    }
                  },
                ),
              ],
            ),
            body: Container(
                padding: const EdgeInsets.all(10),
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
                                child: Container(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                            onTap: () {
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
                                            child: Row(children: <Widget>[
                                              if (workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .weight %
                                                      1 ==
                                                  0)
                                                Flexible(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            "${workoutsBox.getAt(widget.index)!.exercises[i].sets}×${workoutsBox.getAt(widget.index)!.exercises[i].reps} ${workoutsBox.getAt(widget.index)!.exercises[i].weight ~/ 1}${globals.lbKg}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 17,
                                                            ))))
                                              else
                                                Expanded(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            "${workoutsBox.getAt(widget.index)!.exercises[i].sets}×${workoutsBox.getAt(widget.index)!.exercises[i].reps} ${workoutsBox.getAt(widget.index)!.exercises[i].weight.toString()}${globals.lbKg}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        17)))),
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
                                                              .getAt(
                                                                  widget.index)!
                                                              .exercises[i]
                                                              .name) {
                                                        Navigator.of(context)
                                                            .push(MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        EditExercisePage(
                                                                            j)))
                                                            .then((value) {
                                                          setState(() {});
                                                        });
                                                      }
                                                    }
                                                  },
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  icon: const Icon(
                                                      Icons.arrow_right_sharp),
                                                  color: globals.redColor,
                                                  iconSize: 20,
                                                ),
                                              ),
                                            ]))))),
                          ]),
                          Container(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: (MediaQuery.of(context).size.width -
                                          300) /
                                      4.01,
                                  runSpacing: 15,
                                  children: <Widget>[
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
                                          valueListenable:
                                              globals.circleCounter,
                                          builder: (context, value, child) {
                                            return SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: MaterialButton(
                                                elevation: 0,
                                                splashColor: Colors.transparent,
                                                animationDuration:
                                                    const Duration(
                                                        milliseconds: 0),
                                                highlightColor:
                                                    Colors.transparent,
                                                shape: const CircleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        style:
                                                            BorderStyle.none)),
                                                child: workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .repsCompleted[j] >
                                                        workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .reps
                                                    ? workoutsBox.getAt(widget.index)!.exercises[i].repsCompleted[j] <
                                                            10
                                                        ? FittedBox(
                                                            child: Text(
                                                                workoutsBox
                                                                    .getAt(widget
                                                                        .index)!
                                                                    .exercises[
                                                                        i]
                                                                    .reps
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        18)))
                                                        : FittedBox(
                                                            child: Text(
                                                                workoutsBox.getAt(widget.index)!.exercises[i].reps.toString(),
                                                                style: const TextStyle(fontSize: 18)))
                                                    : workoutsBox.getAt(widget.index)!.exercises[i].repsCompleted[j] < 10
                                                        ? FittedBox(child: Text(workoutsBox.getAt(widget.index)!.exercises[i].repsCompleted[j].toString(), style: const TextStyle(fontSize: 18)))
                                                        : FittedBox(child: Text(workoutsBox.getAt(widget.index)!.exercises[i].repsCompleted[j].toString(), style: const TextStyle(fontSize: 12))),
                                                color: workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .repsCompleted[j] >
                                                        workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .reps
                                                    ? globals.circleColor
                                                    : globals.redColor,
                                                textColor: workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .repsCompleted[j] >
                                                        workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .reps
                                                    ? globals
                                                        .emptyCircleTextColor
                                                    : Colors.white,
                                                onPressed: () {
                                                  globals.workoutIndex =
                                                      widget.index;
                                                  globals.exerciseIndex = i;
                                                  globals.setIndex = j - 1;
                                                  incrementCircles(widget.index,
                                                      i, j, false);
                                                  checkWorkoutInProgress(
                                                      widget.index);
                                                },
                                              ),
                                            );
                                          }),
                                  ])),
                          const SizedBox(height: 10),
                        ]),
                      Container(
                          padding: const EdgeInsets.all(15),
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
                                                          tempBodyWeightBox
                                                                      .getAt(
                                                                          0)! ~/
                                                                  1 -
                                                              50);
                                              // annoying floating point precision: 100.6 - 100 = 0.599
                                              // the +0.05 is a way around it
                                              final _decController =
                                                  FixedExtentScrollController(
                                                      initialItem: (tempBodyWeightBox
                                                                  .getAt(0)! -
                                                              (tempBodyWeightBox
                                                                      .getAt(
                                                                          0)! ~/
                                                                  1) +
                                                              0.05) *
                                                          10 ~/
                                                          1);
                                              int scrollBodyWeightInt =
                                                  tempBodyWeightBox.getAt(0)! ~/
                                                      1;
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
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                const Text(
                                                                    "Weight",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
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
                                                                          height:
                                                                              120,
                                                                          width:
                                                                              80,
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
                                                                                Column(children: <Widget>[
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              )))),
                                                                              const SizedBox(height: 50),
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              ))))
                                                                            ]),
                                                                            itemExtent:
                                                                                75,
                                                                            onSelectedItemChanged: (index) =>
                                                                                {
                                                                              scrollBodyWeightInt = index + 50,
                                                                            },
                                                                          )),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      const SizedBox(
                                                                        height:
                                                                            45,
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.topCenter,
                                                                          child: Text(
                                                                              ".",
                                                                              style: TextStyle(
                                                                                fontSize: 17,
                                                                              )),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              120,
                                                                          width:
                                                                              70,
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
                                                                                Column(children: <Widget>[
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              )))),
                                                                              const SizedBox(height: 50),
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              ))))
                                                                            ]),
                                                                            itemExtent:
                                                                                75,
                                                                            onSelectedItemChanged: (index) =>
                                                                                {
                                                                              scrollBodyWeightDec = index,
                                                                            },
                                                                          )),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      SizedBox(
                                                                        height:
                                                                            40,
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.topCenter,
                                                                          child: Text(
                                                                              globals.lbKg,
                                                                              style: const TextStyle(
                                                                                fontSize: 14,
                                                                              )),
                                                                        ),
                                                                      ),
                                                                    ])),
                                                                const SizedBox(
                                                                    height: 30),
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          primary:
                                                                              globals.redColor,
                                                                          textStyle: const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold),
                                                                          alignment:
                                                                              Alignment.center,
                                                                        ),
                                                                        child: const Text(
                                                                            "Cancel"),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              20),
                                                                      TextButton(
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          primary:
                                                                              globals.redColor,
                                                                          textStyle: const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold),
                                                                          alignment:
                                                                              Alignment.center,
                                                                        ),
                                                                        child: const Text(
                                                                            "OK"),
                                                                        onPressed:
                                                                            () {
                                                                          tempBodyWeightBox.putAt(
                                                                              0,
                                                                              scrollBodyWeightInt + 0.1 * scrollBodyWeightDec);
                                                                          setState(
                                                                              () {});
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ]),
                                                              ]))));
                                            },
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    "${tempBodyWeightBox.getAt(0)!.toString()}${globals.lbKg}",
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: globals.redColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )))))),
                              ])),
                      SizedBox(height: boolBox.getAt(1)! ? 150 : 50),
                    ])),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ValueListenableBuilder(
                valueListenable: globals.timerCounter,
                builder: (context, value, child) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        globals.showTimer
                            ? Container(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 15, bottom: 15),
                                        child: Row(children: <Widget>[
                                          buildTime(),
                                          Flexible(
                                              child: Align(
                                            alignment: Alignment.centerRight,
                                            child: globals.lastSet
                                                ? const Text(
                                                    "Set equipment, then lift",
                                                    overflow: TextOverflow.fade)
                                                : globals.failed
                                                    ? globals.failureTimes
                                                            .isEmpty
                                                        ? const Text(
                                                            "No failure timer")
                                                        : globals.failureTimes.last %
                                                                    60 ==
                                                                0
                                                            ? Text("Rest ${(globals.failureTimes.last ~/ 60).toString()}min",
                                                                style: TextStyle(
                                                                    color: globals
                                                                        .textColor))
                                                            : Text(
                                                                "Rest ${(globals.failureTimes.last ~/ 60).toString()}min ${(globals.failureTimes.last % 60).toString()}s",
                                                                style: TextStyle(
                                                                    color: globals
                                                                        .textColor))
                                                    : globals.successTimes
                                                            .isEmpty
                                                        ? const Text(
                                                            "No success timer")
                                                        : globals.successTimes.last % 60 ==
                                                                0
                                                            ? Text("Rest ${(globals.successTimes.last ~/ 60).toString()}min",
                                                                style: TextStyle(
                                                                    color: globals
                                                                        .textColor))
                                                            : Text("Rest ${(globals.successTimes.last ~/ 60).toString()}min ${(globals.successTimes.last % 60).toString()}s",
                                                                style: TextStyle(color: globals.textColor)),
                                          )),
                                          IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () => setState(() {
                                                    globals.showTimer = false;
                                                    AwesomeNotifications()
                                                        .cancelAll();
                                                  })),
                                        ]),
                                        decoration: BoxDecoration(
                                          color: globals.circleColor,
                                        ))))
                            : Container(),
                        Container(
                            width: double.infinity,
                            color: globals.backColor,
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
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
                                            primary: globals.redColor,
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            alignment: Alignment.center,
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
                                                        EditWorkoutPage(
                                                            widget.index)))
                                                .then((value) {
                                              setState(() {});
                                            });
                                          },
                                          child: const Text("Edit"),
                                          style: TextButton.styleFrom(
                                            primary: globals.redColor,
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                            alignment: Alignment.center,
                                          )),
                                    ),
                                  ),
                                ])),
                      ]);
                })));
  }

  void workoutFinish() {
    AwesomeNotifications().cancelAll();
    widget.index == workoutsBox.length - 1
        ? {counterBox.putAt(0, 0), counterBox.putAt(1, 0)}
        // loops counter according to selected workout
        : {
            counterBox.putAt(0, widget.index + 1),
            counterBox.putAt(1, widget.index + 1)
          };

    globals.showTimer = false;
    globals.workoutTimerInProgress = false;
    globals.timer?.cancel();
    globals.workoutTimer?.cancel();
    boolBox.putAt(5, false);
    Wakelock.disable();

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
      weights.add(workoutsBox.getAt(widget.index)!.exercises[i].weight);
      repsPlanned.add(workoutsBox.getAt(widget.index)!.exercises[i].reps);
      setsPlanned.add(workoutsBox.getAt(widget.index)!.exercises[i].sets);

      // extremely weird error (appeared to be pass-by-reference
      // with the repsCompleted, despite that not being possible)
      // this is the roundabout solution I found
      repsCompleted.add([0]);
      repsCompleted[i]
          .add(workoutsBox.getAt(widget.index)!.exercises[i].repsCompleted[0]);
      repsCompleted[i].removeAt(0);

      final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(widget.index);

      if (tempWorkout!.exercises[i].repsCompleted[0] !=
          tempWorkout.exercises[i].reps) {
        exerciseFailed = true;
      }
      for (int j = 1; j < tempWorkout.exercises[i].repsCompleted.length; j++) {
        repsCompleted[i].add(tempWorkout.exercises[i].repsCompleted[j]);

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
            final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(i);
            for (int j = 0; j < tempWorkout!.exercises.length; j++) {
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
            final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(i);
            for (int j = 0; j < tempWorkout!.exercises.length; j++) {
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
    var listProvider = Provider.of<ListProvider>(context, listen: false);

    listProvider.addIndivWorkout(IndivWorkout(
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

    var progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.updateProgress();

    var calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    calendarProvider.updateCalendar();

    var notesProvider = Provider.of<NotesProvider>(context, listen: false);
    notesProvider.updateNotes();

    for (int i = 0; i < workoutsBox.length; i++) {
      final tempWorkout = Hive.box<Workout>('workoutsBox').getAt(i);
      tempWorkout!.isInitialized = false;

      for (int j = 0; j < tempWorkout.exercises.length; j++) {
        tempWorkout.exercises[j].repsCompleted.clear();
        tempWorkout.save();
      }
    }

    Navigator.of(context).pop();
  }

  Future<bool> _onBackPressed() async {
    checkWorkoutInProgress(widget.index);
    var calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    calendarProvider.updateCalendar();
    return true;
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(globals.duration.inMinutes.remainder(60));
    final seconds = twoDigits(globals.duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      buildTimeCard(minutes, 20),
      SizedBox(
          width: 4,
          child: Text(":",
              style: TextStyle(
                fontSize: 30,
                color: globals.textColor,
              ))),
      buildTimeCard(seconds, 5),
    ]);
  }

  void startTimer(Timer? timer) {
    timer?.cancel();
    globals.duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  void startWorkoutTimer(Timer? workoutTimer) {
    workoutTimer?.cancel();
    globals.workoutDuration = const Duration(seconds: 0);
    workoutTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => {addWorkoutTime(workoutTimer)});
  }

  // the time is incremented in _homeState
  // however, this is used for setState, so the time actually updates and shows
  void addTime(Timer? timer) {
    const addSeconds = 0;
    if (!mounted) return;
    setState(() {
      final seconds = globals.duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        globals.duration = Duration(seconds: seconds);
      }
    });
  }

  void addWorkoutTime(Timer? workoutTimer) {
    const addSeconds = 0;
    if (!mounted) return;
    setState(() {
      final seconds = globals.workoutDuration.inSeconds + addSeconds;
      if (seconds < 0) {
        workoutTimer?.cancel();
      } else {
        globals.workoutDuration = Duration(seconds: seconds);
      }
    });
  }

  Widget buildTimeCard(String time, double inset) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: inset),
        child: Text(
          time,
          style: TextStyle(color: globals.textColor, fontSize: 30),
        ),
      );
}
