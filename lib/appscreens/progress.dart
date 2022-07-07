import 'package:blocklifts/providers/progressprovider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/appscreens/graphpage.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class Progress extends StatefulWidget {
  const Progress({Key? key}) : super(key: key);
  @override
  ProgressState createState() => ProgressState();
}

class ProgressState extends State<Progress> {
  late final Box<Exercise> exercisesBox;
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
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
            title: const Text("Progress"),
            titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
          ),
          body: Consumer<ProgressProvider>(
              builder: (context, progressProvider, child) {
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
                    TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: <Widget>[
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7),
                                    child: Text(
                                      exercisesBox.getAt(i)!.name,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: globals.textColor),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: const Icon(
                                      Icons.bookmark,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _lastCompletedWeight(i),
                                ),
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
                if (bookmarkCounter > 0)
                  Divider(
                      height: 10,
                      thickness: 1,
                      color: globals.dividerColor,
                      indent: 10,
                      endIndent: 10),
                // body weight
                TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16)),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.8),
                                child: Text(
                                  "Body Weight",
                                  style: TextStyle(
                                      fontSize: 17, color: globals.textColor),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: indivWorkoutsBox.isEmpty
                                    ? Text("150${globals.lbKg}",
                                        style:
                                            TextStyle(color: globals.greyColor))
                                    : indivWorkoutsBox
                                                    .getAt(indivWorkoutsBox
                                                            .length -
                                                        1)!
                                                    .bodyWeight %
                                                1 ==
                                            0
                                        ? Text(
                                            "${indivWorkoutsBox.getAt(indivWorkoutsBox.length - 1)!.bodyWeight.toInt().toString()}${globals.lbKg}",
                                            style: TextStyle(
                                                color: globals.greyColor))
                                        : Text(
                                            "${indivWorkoutsBox.getAt(indivWorkoutsBox.length - 1)!.bodyWeight.toString()}${globals.lbKg}",
                                            style: TextStyle(
                                                color: globals.greyColor)),
                              ),
                            ]),
                      ),
                    ]),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const GraphPage(-1)));
                  },
                ),
                if (bookmarkCounter < exercisesBox.length - 1)
                  Divider(
                      height: 10,
                      thickness: 1,
                      color: globals.dividerColor,
                      indent: 10,
                      endIndent: 10),
                for (int i = 1; i < exercisesBox.length; i++)
                  if (!exercisesBox.getAt(i)!.bookmarked)
                    TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.8),
                                    child: Text(
                                      exercisesBox.getAt(i)!.name,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: globals.textColor),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: exercisesBox.getAt(i)!.weight % 1 ==
                                            0
                                        ? Text(
                                            "${exercisesBox.getAt(i)!.weight.toInt().toString()}${globals.lbKg}",
                                            style: TextStyle(
                                                color: globals.greyColor))
                                        : Text(
                                            "${exercisesBox.getAt(i)!.weight.toString()}${globals.lbKg}",
                                            style: TextStyle(
                                                color: globals.greyColor)),
                                  ),
                                ]),
                          ]),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => GraphPage(i)));
                        }),
              ],
            );
          }));
    });
  }

  Widget _lastCompletedWeight(int exIdx) {
    for (int i = indivWorkoutsBox.length - 1; i >= 0; i--) {
      for (int j = 0;
          j < indivWorkoutsBox.getAt(i)!.exercisesCompleted.length;
          j++) {
        if (indivWorkoutsBox.getAt(i)!.exercisesCompleted[j] ==
            exercisesBox.getAt(exIdx)!.name) {
          bool skipped = true;
          // checks to see if exercise was skipped
          for (int k = 0;
              k < indivWorkoutsBox.getAt(i)!.repsCompleted[j].length;
              k++) {
            if (indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1 !=
                indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]) {
              skipped = false;
            }
          }
          if (skipped) {
            continue;
          } else {
            return indivWorkoutsBox.getAt(i)!.weights[j] % 1 == 0
                ? Text(
                    "${indivWorkoutsBox.getAt(i)!.weights[j].toInt().toString()}${globals.lbKg}",
                    style: TextStyle(color: globals.greyColor))
                : Text(
                    "${indivWorkoutsBox.getAt(i)!.weights[j].toString()}${globals.lbKg}",
                    style: TextStyle(color: globals.greyColor));
          }
        }
      }
    }
    return exercisesBox.getAt(exIdx)!.weight % 1 == 0
        ? Text(
            "${exercisesBox.getAt(exIdx)!.weight.toInt().toString()}${globals.lbKg}",
            style: TextStyle(color: globals.greyColor))
        : Text("${exercisesBox.getAt(exIdx)!.weight.toString()}${globals.lbKg}",
            style: TextStyle(color: globals.greyColor));
  }
}
