import 'package:blocklifts/classes/indivworkout.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/appscreens/workoutpage.dart';
import 'package:blocklifts/appscreens/edit.dart';
import 'package:blocklifts/providers/homeprovider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/providers/workouttimerprovider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:blocklifts/globals.dart' as globals;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  late final Box<Workout> workoutsBox;
  late final Box<int> counterBox;
  late final Box<bool> boolBox;
  late final Box<String> tempNoteBox;
  late final Box<bool> scheduleBox;
  late final Box<IndivWorkout> indivWorkoutsBox;
  late dynamic counter;
  List<String> workoutDays = [];
  int workoutDaysIdx = -1;

  @override
  void initState() {
    super.initState();
    workoutsBox = Hive.box<Workout>('workoutsBox');
    counterBox = Hive.box<int>('counterBox');
    boolBox = Hive.box<bool>('boolBox');
    tempNoteBox = Hive.box<String>('tempNoteBox');
    scheduleBox = Hive.box<bool>('scheduleBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
  }

  void pushWorkout(int idx) {
    AwesomeNotifications().cancelAll();
    boolBox.putAt(8, false);
    tempNoteBox.putAt(0, "");
    workoutsBox.getAt(idx)!.isInitialized = true;
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => WorkoutPage(idx)))
        .then((value) {
      setState(() {});
    });
  }

  Widget buildWorkoutTime() {
    String twoDigits(int n) => n.toString();
    final minutes = twoDigits(globals.workoutDuration.inMinutes);
    return Text(
      "${minutes}min",
      style: const TextStyle(fontSize: 12),
    );
  }

  void buildWorkoutDays() {
    List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<String> activeWorkoutDays = [];
    workoutDays.clear();

    if (scheduleBox.isEmpty) {
      scheduleBox.add(false);
      scheduleBox.add(true);
      scheduleBox.add(false);
      scheduleBox.add(true);
      scheduleBox.add(false);
      scheduleBox.add(true);
      scheduleBox.add(false);
    }

    for (int i = 0; i < scheduleBox.length; i++) {
      if (scheduleBox.getAt(i)!) {
        activeWorkoutDays.add(days[i]);
      }
    }

    if (activeWorkoutDays.isEmpty) {
      for (int i = 0; i < workoutsBox.length; i++) {
        workoutDays.add("");
      }
    } else {
      DateTime cur = DateTime.now();
      // if most recent workout is today, move to next day
      if (indivWorkoutsBox.isNotEmpty) {
        if (indivWorkoutsBox.getAt(indivWorkoutsBox.length - 1)!.date ==
            DateFormat('E, d MMM yyyy').format(cur)) {
          cur = DateTime.now().add(const Duration(days: 1));
        }
      }
      // workout in progress
      if (boolBox.getAt(9)!) {
        workoutDays.add("Today");
        cur = DateTime.now().add(const Duration(days: 1));
      }
      int idx = 0;
      for (int i = counter; i < workoutsBox.length; i++) {
        while (workoutDays.length != workoutsBox.length - counter) {
          if (DateFormat('E').format(cur) == activeWorkoutDays[idx]) {
            if (DateFormat('E, d MMM yyyy').format(cur) ==
                DateFormat('E, d MMM yyyy').format(DateTime.now())) {
              workoutDays.add("Today");
            } else if (DateFormat('E, d MMM yyyy').format(cur) ==
                DateFormat('E, d MMM yyyy')
                    .format(DateTime.now().add(const Duration(days: 1)))) {
              workoutDays.add("Tomorrow");
            } else {
              workoutDays.add(DateFormat('E, d MMM').format(cur));
            }
            idx == activeWorkoutDays.length - 1 ? idx = 0 : idx++;
            cur = cur.add(const Duration(days: 1));
          } else {
            if (idx == activeWorkoutDays.length - 1) {
              idx = 0;
              cur = cur.add(const Duration(days: 1));
            } else {
              idx++;
            }
          }
        }
      }
      for (int i = 0; i < counter; i++) {
        while (workoutDays.length != workoutsBox.length) {
          if (DateFormat('E').format(cur) == activeWorkoutDays[idx]) {
            if (DateFormat('E, d MMM yyyy').format(cur) ==
                DateFormat('E, d MMM yyyy').format(DateTime.now())) {
              workoutDays.add("Today");
            } else if (DateFormat('E, d MMM yyyy').format(cur) ==
                DateFormat('E, d MMM yyyy')
                    .format(DateTime.now().add(const Duration(days: 1)))) {
              workoutDays.add("Tomorrow");
            } else {
              workoutDays.add(DateFormat('E, d MMM').format(cur));
            }
            idx == activeWorkoutDays.length - 1 ? idx = 0 : idx++;
            cur = cur.add(const Duration(days: 1));
          } else {
            if (idx == activeWorkoutDays.length - 1) {
              idx = 0;
              cur = cur.add(const Duration(days: 1));
            } else {
              idx++;
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        backgroundColor: globals.backColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: globals.headerColor,
          title: const Text("BLOCKLIFTS", style: TextStyle(fontFamily: 'Teko')),
          titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: globals.redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Edit"),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => const Edit()))
                    .then((value) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
        body: Consumer<HomeProvider>(builder: (context, homeProvider, child) {
          workoutDaysIdx = -1;
          counter = counterBox.getAt(0);
          buildWorkoutDays();
          return Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
              for (int i = counter; i < workoutsBox.length; i++) buildTile(i),
              for (int i = 0; i < counter; i++) buildTile(i),
              const SizedBox(height: 100),
            ]),
          );
        }),
        floatingActionButton: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: boolBox.getAt(5)!
                  ? const EdgeInsets.only(right: 10)
                  : const EdgeInsets.only(right: 10, bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: boolBox.getAt(5)!
                      ? const Size.fromHeight(75)
                      : const Size.fromHeight(50),
                  primary: Colors.white,
                  backgroundColor: globals.redColor,
                  shape: boolBox.getAt(5)!
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))
                      : const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
                onPressed: () {
                  if (boolBox.getAt(5)!) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            WorkoutPage(counterBox.getAt(0)!)));
                  } else {
                    pushWorkout(counterBox.getAt(0)!);
                  }
                },
                child: boolBox.getAt(5)!
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            const Text("Workout In Progress",
                                style: TextStyle(fontSize: 16)),
                            Consumer<WorkoutTimerProvider>(builder:
                                (context, workoutTimerProvider, child) {
                              return buildWorkoutTime();
                            }),
                          ])
                    : const Text("Start Workout",
                        style: TextStyle(fontSize: 16)),
              ),
            )),
        floatingActionButtonLocation: boolBox.getAt(5)!
            ? FloatingActionButtonLocation.centerDocked
            : FloatingActionButtonLocation.centerDocked,
      );
    });
  }

  Widget buildTile(int i) {
    workoutDaysIdx++;
    return Column(children: <Widget>[
      GestureDetector(
          onTap: () {
            if (boolBox.getAt(5)! && i != counterBox.getAt(0)!) {
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                        insetPadding: const EdgeInsets.all(10),
                        child: Container(
                          color: globals.tileColor,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Workout In Progress",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: globals.textColor))),
                                const SizedBox(height: 10),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        "Starting a new workout will delete your workout in progress.",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: globals.textColor))),
                                const SizedBox(height: 20),
                                Column(children: <Widget>[
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("Start New Workout"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          pushWorkout(i);
                                        },
                                      )),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text(
                                            "Resume Workout in Progress"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      WorkoutPage(counterBox
                                                          .getAt(0)!)))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        },
                                      )),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )),
                                ]),
                              ]),
                        ),
                      ));
            } else if (boolBox.getAt(5)! && i == counterBox.getAt(0)!) {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => WorkoutPage(counterBox.getAt(0)!)))
                  .then((value) {
                setState(() {});
              });
            } else {
              pushWorkout(i);
            }
          },
          child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: i == counter
                    ? Border.all(color: globals.redColor)
                    : Border.all(color: globals.borderColor),
                borderRadius: BorderRadius.circular(6),
                color: globals.tileColor,
              ),
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                        flex: 2,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(workoutsBox.getAt(i)!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: globals.greyColor,
                                )))),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(workoutDays[workoutDaysIdx],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            color: globals.greyColor,
                          )),
                    )),
                  ]),
                  const Divider(height: 15, color: Colors.transparent),
                  Column(children: [
                    for (int j = 0;
                        j < workoutsBox.getAt(i)!.exercises.length;
                        j++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text(workoutsBox.getAt(i)!.exercises[j].name,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: globals.textColor,
                                      )),
                            ),
                          ),
                          if (workoutsBox.getAt(i)!.exercises[j].weight % 1 ==
                              0)
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${workoutsBox.getAt(i)!.exercises[j].sets}×${workoutsBox.getAt(i)!.exercises[j].reps} ${workoutsBox.getAt(i)!.exercises[j].weight ~/ 1}${globals.lbKg}",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: globals.textColor,
                                        ))))
                          else
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${workoutsBox.getAt(i)!.exercises[j].sets}×${workoutsBox.getAt(i)!.exercises[j].reps} ${workoutsBox.getAt(i)!.exercises[j].weight.toString()}${globals.lbKg}",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: globals.textColor,
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
