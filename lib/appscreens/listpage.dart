import 'package:flutter/material.dart';
import 'package:blocklifts/appscreens/postworkouteditpage.dart';
import 'package:blocklifts/providers/listprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);
  @override
  ListState createState() => ListState();
}

class ListState extends State<ListPage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
          backgroundColor: globals.backColor,
          body: Consumer<ListProvider>(builder: (context, listProvider, child) {
            return listProvider.indivWorkouts.isEmpty
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
                        for (int index = listProvider.indivWorkouts.length - 1;
                            index >= 0;
                            index--)
                          Column(children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  // workaround to fill (seems to be pass-by-reference, strangely again)
                                  List<List<int>> copyRepsCompleted = [];

                                  for (int j = 0;
                                      j <
                                          listProvider.indivWorkouts[index]
                                              .repsCompleted.length;
                                      j++) {
                                    copyRepsCompleted.add([0]);
                                    copyRepsCompleted[j].add(listProvider
                                        .indivWorkouts[index]
                                        .repsCompleted[j][0]);
                                    copyRepsCompleted[j].removeAt(0);
                                    for (int k = 1;
                                        k <
                                            listProvider.indivWorkouts[index]
                                                .repsCompleted[j].length;
                                        k++) {
                                      copyRepsCompleted[j].add(listProvider
                                          .indivWorkouts[index]
                                          .repsCompleted[j][k]);
                                    }
                                  }
                                  globals.postWorkoutTempNote =
                                      listProvider.indivWorkouts[index].note;
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              PostWorkoutEditPage(
                                                  index, copyRepsCompleted)))
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: globals.borderColor),
                                      borderRadius: BorderRadius.circular(6),
                                      color: globals.tileColor,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Column(children: [
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                listProvider
                                                    .indivWorkouts[index].name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: globals.greyColor,
                                                )),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                listProvider
                                                    .indivWorkouts[index].date,
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
                                                listProvider
                                                    .indivWorkouts[index]
                                                    .exercisesCompleted
                                                    .length;
                                            j++)
                                          Column(children: <Widget>[
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                          listProvider
                                                              .indivWorkouts[
                                                                  index]
                                                              .exercisesCompleted[j],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: globals
                                                                .textColor,
                                                          )),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            makeCompletionString(
                                                                index, j),
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: globals
                                                                    .textColor))),
                                                  )
                                                ]),
                                            Divider(
                                                // larger divider if not at end of list
                                                height: j !=
                                                        listProvider
                                                                .indivWorkouts[
                                                                    index]
                                                                .exercisesCompleted
                                                                .length -
                                                            1
                                                    ? 15
                                                    : 0,
                                                color: Colors.transparent),
                                          ])
                                      ]),
                                    ]))),
                            const Divider(height: 5, color: Colors.transparent),
                          ])
                      ]);
          }));
    });
  }

  String makeCompletionString(int i, int j) {
    String output = "";
    bool allSkipped = true;
    int successCounter = 0;
    var listProvider = Provider.of<ListProvider>(context, listen: false);

    for (int k = 0; k < listProvider.indivWorkouts[i].setsPlanned[j]; k++) {
      if (listProvider.indivWorkouts[i].repsCompleted[j][k] ==
          listProvider.indivWorkouts[i].repsPlanned[j] + 1) {
        output += "0";
      } else {
        allSkipped = false;
        if (listProvider.indivWorkouts[i].repsCompleted[j][k] ==
            listProvider.indivWorkouts[i].repsPlanned[j]) {
          successCounter++;
        }
        output += listProvider.indivWorkouts[i].repsCompleted[j][k].toString();
      }

      if (k != listProvider.indivWorkouts[i].setsPlanned[j] - 1) {
        output += "/";
      } else {
        if (successCounter == listProvider.indivWorkouts[i].setsPlanned[j] &&
            listProvider.indivWorkouts[i].setsPlanned[j] != 1) {
          output = "";
          output += listProvider.indivWorkouts[i].setsPlanned[j].toString();
          output += "×";
          output += listProvider.indivWorkouts[i].repsPlanned[j].toString();
          output += " ";
        } else if (listProvider.indivWorkouts[i].setsPlanned[j] == 1) {
          output += "×";
        } else {
          output += " ";
        }

        listProvider.indivWorkouts[i].weights[j] % 1 == 0
            ? output +=
                listProvider.indivWorkouts[i].weights[j].toInt().toString()
            : output += listProvider.indivWorkouts[i].weights[j].toString();
        output += globals.lbKg;

        if (allSkipped) {
          output = "";
          output += "Skipped";
        }
      }
    }
    return output;
  }

  @override
  bool get wantKeepAlive => true;
}
