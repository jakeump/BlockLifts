import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/appscreens/postworkouteditpage.dart';
import 'package:blocklifts/globals.dart' as globals;

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
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
        valueListenable: globals.themeCounter,
        builder: (context, index, child) {
          return Scaffold(
              backgroundColor: globals.backColor,
              body: ValueListenableBuilder(
                  valueListenable: globals.counter,
                  builder: (context, value, child) {
                    return indivWorkoutsBox.length == 0
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                padding: const EdgeInsets.only(top: 100),
                                child: Text("No workouts logged",
                                    style: TextStyle(color: globals.textColor))))
                        : ListView(
                            padding: const EdgeInsets.all(10),
                            scrollDirection: Axis.vertical,
                            children: <Widget>[
                                for (int i = indivWorkoutsBox.length - 1;
                                    i >= 0;
                                    i--)
                                  Column(children: <Widget>[
                                    GestureDetector(
                                        onTap: () {
                                          // workaround to fill (seems to be pass-by-reference, strangely again)
                                          List<List<int>> copyRepsCompleted =
                                              [];

                                          for (int j = 0;
                                              j <
                                                  indivWorkoutsBox
                                                      .getAt(i)!
                                                      .repsCompleted
                                                      .length;
                                              j++) {
                                            copyRepsCompleted.add([0]);
                                            copyRepsCompleted[j].add(
                                                indivWorkoutsBox
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
                                          globals.postWorkoutTempNote =
                                              indivWorkoutsBox.getAt(i)!.note;
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      PostWorkoutEditPage(i,
                                                          copyRepsCompleted)))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: globals.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: globals.tileColor,
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
                                                          color: globals.greyColor,
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
                                                          color: globals.greyColor,
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
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                  indivWorkoutsBox
                                                                      .getAt(i)!
                                                                      .exercisesCompleted[j],
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        globals.textColor,
                                                                  )),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                    makeCompletionString(
                                                                        i, j),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color:
                                                                            globals.textColor))),
                                                          )
                                                        ]),
                                                    Divider(
                                                        // larger divider if not at end of list
                                                        height: j !=
                                                                indivWorkoutsBox
                                                                        .getAt(
                                                                            i)!
                                                                        .exercisesCompleted
                                                                        .length -
                                                                    1
                                                            ? 15
                                                            : 0,
                                                        color:
                                                            Colors.transparent),
                                                  ])
                                              ]),
                                            ]))),
                                    const Divider(
                                        height: 5, color: Colors.transparent),
                                  ]),
                              ]);
                  }));
        });
  }

  String makeCompletionString(int i, int j) {
    String output = "";
    bool allSkipped = true;
    int successCounter = 0;

    for (int k = 0; k < indivWorkoutsBox.getAt(i)!.setsPlanned[j]; k++) {
      if (indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
          indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1) {
        output += "0";
      } else {
        allSkipped = false;
        if (indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
            indivWorkoutsBox.getAt(i)!.repsPlanned[j]) {
          successCounter++;
        }
        output += indivWorkoutsBox.getAt(i)!.repsCompleted[j][k].toString();
      }

      if (k != indivWorkoutsBox.getAt(i)!.setsPlanned[j] - 1) {
        output += "/";
      } else {
        if (successCounter == indivWorkoutsBox.getAt(i)!.setsPlanned[j] &&
            indivWorkoutsBox.getAt(i)!.setsPlanned[j] != 1) {
          output = "";
          output += indivWorkoutsBox.getAt(i)!.setsPlanned[j].toString();
          output += "×";
          output += indivWorkoutsBox.getAt(i)!.repsPlanned[j].toString();
          output += " ";
        } else if (indivWorkoutsBox.getAt(i)!.setsPlanned[j] == 1) {
          output += "×";
        } else {
          output += " ";
        }

        indivWorkoutsBox.getAt(i)!.weights[j] % 1 == 0
            ? output += indivWorkoutsBox.getAt(i)!.weights[j].toInt().toString()
            : output += indivWorkoutsBox.getAt(i)!.weights[j].toString();
        output += globals.lbKg;

        if (allSkipped) {
          output = "";
          output += "Skipped";
        }
      }
    }
    return output;
  }
}
