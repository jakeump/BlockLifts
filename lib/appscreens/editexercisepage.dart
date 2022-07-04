import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/plate.dart';
import 'package:blocklifts/appscreens/incrementspage.dart';
import 'package:blocklifts/providers/progressprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class EditExercisePage extends StatefulWidget {
  final int index;

  const EditExercisePage(this.index, {Key? key}) : super(key: key);
  @override
  EditExercisePageState createState() => EditExercisePageState();
}

class EditExercisePageState extends State<EditExercisePage> {
  final _myController = TextEditingController();
  final _myController2 = TextEditingController();
  late final Box<Exercise> exercisesBox;
  late final Box<Workout> workoutsBox;
  late final Box<Plate> platesBox;
  late final Box<bool> boolBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
    platesBox = Hive.box<Plate>('platesBox');
    boolBox = Hive.box<bool>('boolBox');
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: globals.headerColor,
        title: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                exercisesBox.getAt(widget.index)!.name,
                style: TextStyle(
                  fontSize: 18,
                  color: globals.textColor,
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
                  "${exercisesBox.getAt(widget.index)!.weight.toInt().toString()}${globals.lbKg} (${(((exercisesBox.getAt(widget.index)!.weight) - exercisesBox.getAt(widget.index)!.barWeight) ~/ 2)}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: globals.textColor,
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
                  "${exercisesBox.getAt(widget.index)!.weight.toInt().toString()}${globals.lbKg} (${(((exercisesBox.getAt(widget.index)!.weight) - exercisesBox.getAt(widget.index)!.barWeight) / 2).toString()}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: globals.textColor,
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
                    color: globals.textColor,
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
                  "${exercisesBox.getAt(widget.index)!.weight.toString()}${globals.lbKg} (${((exercisesBox.getAt(widget.index)!.weight - exercisesBox.getAt(widget.index)!.barWeight) / 2).toString()}/side)",
                  style: TextStyle(
                    fontSize: 14,
                    color: globals.textColor,
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
                            color: globals.underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // subtracts 5lb/2.5kg from text box
                                    setState(() {
                                      double tempText =
                                          double.parse(_myController.text);
                                      if (boolBox.getAt(7)!) {
                                        if (tempText <= 5) {
                                          tempText = 0;
                                        } else {
                                          tempText -= 5;
                                        }
                                      } else {
                                        if (tempText <= 2.5) {
                                          tempText = 0;
                                        } else {
                                          tempText -= 2.5;
                                        }
                                      }
                                      tempText % 1 == 0
                                          ? _myController.text =
                                              tempText.toInt().toString()
                                          : _myController.text =
                                              tempText.toString();
                                      _myController.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  _myController.text.length);
                                    });
                                  },
                                  child: boolBox.getAt(7)!
                                      ? const Text("-5lb")
                                      : const Text("-2.5kg"),
                                ),
                              )),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // adds 5lb/2.5kg to text box
                                    setState(() {
                                      double tempText =
                                          double.parse(_myController.text);
                                      if (boolBox.getAt(7)!) {
                                        tempText += 5;
                                      } else {
                                        tempText += 2.5;
                                      }
                                      tempText % 1 == 0
                                          ? _myController.text =
                                              tempText.toInt().toString()
                                          : _myController.text =
                                              tempText.toString();
                                      _myController.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  _myController.text.length);
                                    });
                                  },
                                  child: boolBox.getAt(7)!
                                      ? const Text("+5lb")
                                      : const Text("+2.5kg"),
                                ),
                              )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
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
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: globals.redColor,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    alignment: Alignment.center,
                                  ),
                                  child: const Text("OK"),
                                  onPressed: () {
                                    setState(() {
                                      if (_myController.text.isEmpty) {
                                        _myController.text = "0";
                                      }
                                      final tempEx =
                                          Hive.box<Exercise>('exercisesBox')
                                              .getAt(widget.index);
                                      tempEx!.weight =
                                          double.parse(_myController.text);
                                      tempEx.save();

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
                                              tempEx.name) {
                                            tempWorkout.exercises[j].weight =
                                                double.parse(
                                                    _myController.text);
                                          }
                                          tempWorkout.save();
                                        }
                                      }
                                    });
                                    var progressProvider =
                                        Provider.of<ProgressProvider>(context,
                                            listen: false);
                                    progressProvider.updateProgress();
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Exercise Weight",
                          style: TextStyle(
                            fontSize: 18,
                            color: globals.textColor,
                          ),
                        ),
                      ),
                      // if no decimals needed
                      if (exercisesBox.getAt(widget.index)!.weight % 1 == 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.weight.toInt().toString()}${globals.lbKg}",
                            style: TextStyle(
                              fontSize: 16,
                              color: globals.greyColor,
                            ),
                          ),
                        ),
                      if (exercisesBox.getAt(widget.index)!.weight % 1 != 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.weight.toString()}${globals.lbKg}",
                            style: TextStyle(
                              fontSize: 16,
                              color: globals.greyColor,
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
                          const Text("Weight of the bar",
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
                            color: globals.underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // subtracts 5lb/2.5kg from text box
                                    setState(() {
                                      double tempText =
                                          double.parse(_myController.text);
                                      if (boolBox.getAt(7)!) {
                                        if (tempText <= 5) {
                                          tempText = 0;
                                        } else {
                                          tempText -= 5;
                                        }
                                      } else {
                                        if (tempText <= 2.5) {
                                          tempText = 0;
                                        } else {
                                          tempText -= 2.5;
                                        }
                                      }
                                      tempText % 1 == 0
                                          ? _myController.text =
                                              tempText.toInt().toString()
                                          : _myController.text =
                                              tempText.toString();
                                      _myController.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  _myController.text.length);
                                    });
                                  },
                                  child: boolBox.getAt(7)!
                                      ? const Text("-5lb")
                                      : const Text("-2.5kg"),
                                ),
                              )),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // adds 5lb/2.5kg to text box
                                    setState(() {
                                      double tempText =
                                          double.parse(_myController.text);
                                      if (boolBox.getAt(7)!) {
                                        tempText += 5;
                                      } else {
                                        tempText += 2.5;
                                      }
                                      tempText % 1 == 0
                                          ? _myController.text =
                                              tempText.toInt().toString()
                                          : _myController.text =
                                              tempText.toString();
                                      _myController.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  _myController.text.length);
                                    });
                                  },
                                  child: boolBox.getAt(7)!
                                      ? const Text("+5lb")
                                      : const Text("+2.5kg"),
                                ),
                              )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
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
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: globals.redColor,
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    alignment: Alignment.center,
                                  ),
                                  child: const Text("OK"),
                                  onPressed: () {
                                    setState(() {
                                      if (_myController.text.isEmpty) {
                                        _myController.text = "0";
                                      }
                                      final tempEx =
                                          Hive.box<Exercise>('exercisesBox')
                                              .getAt(widget.index);
                                      tempEx!.barWeight =
                                          double.parse(_myController.text);
                                      tempEx.save();

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
                                              tempEx.name) {
                                            tempWorkout.exercises[j].barWeight =
                                                double.parse(
                                                    _myController.text);
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bar Weight",
                          style: TextStyle(
                            fontSize: 18,
                            color: globals.textColor,
                          ),
                        ),
                      ),
                      // if no decimals needed
                      if (exercisesBox.getAt(widget.index)!.barWeight % 1 == 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.barWeight.toInt().toString()}${globals.lbKg}",
                            style: TextStyle(
                              fontSize: 16,
                              color: globals.greyColor,
                            ),
                          ),
                        ),
                      if (exercisesBox.getAt(widget.index)!.barWeight % 1 != 0)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${exercisesBox.getAt(widget.index)!.barWeight.toString()}${globals.lbKg}",
                            style: TextStyle(
                              fontSize: 16,
                              color: globals.greyColor,
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
                    color: globals.textColor,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: exercisesBox.getAt(widget.index)!.increment % 1 == 0
                    ? Text(
                        "${exercisesBox.getAt(widget.index)!.increment.toInt().toString()}${globals.lbKg}",
                        style:
                            TextStyle(fontSize: 16, color: globals.greyColor))
                    : Text(
                        "${exercisesBox.getAt(widget.index)!.increment.toString()}${globals.lbKg}",
                        style:
                            TextStyle(fontSize: 16, color: globals.greyColor)),
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
                              labelStyle: TextStyle(
                                  fontSize: 20, color: globals.textColor),
                              contentPadding: const EdgeInsets.only(bottom: 0),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: globals.underlineColor,
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
                              labelStyle: TextStyle(
                                  fontSize: 20, color: globals.textColor),
                              contentPadding: const EdgeInsets.only(bottom: 0),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: globals.underlineColor,
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
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
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                    style: TextButton.styleFrom(
                                      primary: globals.redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("OK"),
                                    onPressed: () {
                                      int oldReps = exercisesBox
                                          .getAt(widget.index)!
                                          .reps;
                                      int oldSets = exercisesBox
                                          .getAt(widget.index)!
                                          .sets;
                                      setState(() {
                                        if (_myController.text.isEmpty) {
                                          _myController.text = "0";
                                        }
                                        if (_myController2.text.isEmpty) {
                                          _myController2.text = "0";
                                        }
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
                                                  int.parse(
                                                      _myController2.text);

                                              if (oldSets !=
                                                  exercisesBox
                                                      .getAt(widget.index)!
                                                      .sets) {
                                                for (int i = 0;
                                                    i <
                                                        exercisesBox
                                                                .getAt(widget
                                                                    .index)!
                                                                .sets -
                                                            oldSets;
                                                    i++) {
                                                  tempWorkout.exercises[j]
                                                      .repsCompleted
                                                      .add(exercisesBox
                                                              .getAt(
                                                                  widget.index)!
                                                              .reps +
                                                          1);
                                                  exercisesBox
                                                      .getAt(widget.index)!
                                                      .repsCompleted
                                                      .add(exercisesBox
                                                              .getAt(
                                                                  widget.index)!
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
                                                            .getAt(
                                                                widget.index)!
                                                            .sets;
                                                    k++) {
                                                  exercisesBox
                                                      .getAt(widget.index)!
                                                      .repsCompleted
                                                      .add(exercisesBox
                                                              .getAt(
                                                                  widget.index)!
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
                            color: globals.textColor,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${exercisesBox.getAt(widget.index)!.sets.toString()}×${exercisesBox.getAt(widget.index)!.reps.toString()}",
                          style: TextStyle(
                            fontSize: 16,
                            color: globals.greyColor,
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
                        color: globals.textColor,
                      )),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    plateCalculator(),
                    style: TextStyle(
                      fontSize: 16,
                      color: globals.greyColor,
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Change Exercise Name",
                  style: TextStyle(fontSize: 16, color: globals.textColor)),
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
                                color: globals.underlineColor,
                                height: 2,
                                thickness: 2,
                              ),
                              const SizedBox(height: 40),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
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
                                    ),
                                    const SizedBox(width: 20),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: globals.redColor,
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
                                                j <
                                                    tempWorkout!
                                                        .exercises.length;
                                                j++) {
                                              if (tempWorkout
                                                      .exercises[j].name ==
                                                  oldName) {
                                                tempWorkout.exercises[j].name =
                                                    _myController.text;
                                              }
                                              tempWorkout.save();
                                            }
                                          }
                                        });
                                        var progressProvider =
                                            Provider.of<ProgressProvider>(
                                                context,
                                                listen: false);
                                        progressProvider.updateProgress();
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
