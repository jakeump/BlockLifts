import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/appscreens/postworkouteditpage.dart';
import 'package:blocklifts/providers/calendarprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<NotesPage> with AutomaticKeepAliveClientMixin {
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int noteCounter = 0;
    for (int i = indivWorkoutsBox.length - 1; i >= 0; i--) {
      if (indivWorkoutsBox.getAt(i)!.note != "") {
        noteCounter++;
      }
    }
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
          backgroundColor: globals.backColor,
          body: Consumer<CalendarProvider>(
              builder: (context, calendarProvider, child) {
            return noteCounter == 0
                ? Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text("No notes logged",
                            style: TextStyle(color: globals.textColor))))
                : ListView(
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
                                                PostWorkoutEditPage(
                                                    i, copyRepsCompleted)))
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
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                  indivWorkoutsBox
                                                      .getAt(i)!
                                                      .note,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: globals.textColor,
                                                  ))),
                                        ],
                                      ))),
                              const Divider(
                                  height: 5, color: Colors.transparent),
                            ])
                      ]);
          }));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
