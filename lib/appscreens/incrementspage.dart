import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:blocklifts/classes/exercise.dart';

import 'package:blocklifts/globals.dart' as globals;

class IncrementsPage extends StatefulWidget {
  final int index;

  const IncrementsPage(this.index, {Key? key}) : super(key: key);
  @override
  _IncrementsPageState createState() => _IncrementsPageState();
}

class _IncrementsPageState extends State<IncrementsPage> {
  late final Box<Exercise> exercisesBox;
  late final Box<bool> boolBox;

  @override
  void initState() {
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    boolBox = Hive.box<bool>('boolBox');
    super.initState();
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
      backgroundColor: globals.backColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: globals.headerColor,
        title: const Text("Increments"),
        titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
      ),
      body: ListView(children: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
              primary: Colors.white, textStyle: const TextStyle(fontSize: 16)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(children: <Widget>[
              Expanded(
                flex: 4,
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Progressive Overload",
                          style: TextStyle(
                              fontSize: 18, color: globals.textColor))),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Add weight if all sets successful",
                        style:
                            TextStyle(fontSize: 16, color: globals.greyColor)),
                  ),
                ]),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                    inactiveThumbColor: globals.greyColor,
                    inactiveTrackColor:
                        const Color.fromARGB(255, 207, 207, 207),
                    activeColor: globals.activeSwitchColor,
                    activeTrackColor: globals.greyColor,
                    value: exercisesBox.getAt(widget.index)!.overload,
                    onChanged: toggleSwitch,
                  ),
                ),
              ),
            ]),
          ),
          onPressed: (() => toggleSwitch(false)),
        ),
        exercisesBox.getAt(widget.index)!.overload
            ? ValueListenableBuilder(
                valueListenable: globals.incrementsCounter,
                builder: (context, value, child) {
                  return TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 16)),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Increments",
                                style: TextStyle(
                                    fontSize: 18, color: globals.textColor)),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: exercisesBox.getAt(widget.index)!.increment %
                                        1 ==
                                    0
                                ? Text(
                                    "${exercisesBox.getAt(widget.index)!.increment.toInt().toString()}${globals.lbKg}",
                                    style: TextStyle(
                                        fontSize: 16, color: globals.greyColor))
                                : Text(
                                    "${exercisesBox.getAt(widget.index)!.increment.toString()}${globals.lbKg}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: globals.greyColor)),
                          ),
                        ]),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => incrementSelector());
                      });
                })
            : const SizedBox(),
        exercisesBox.getAt(widget.index)!.overload
            ? ValueListenableBuilder(
                valueListenable: globals.incrementsCounter,
                builder: (context, value, child) {
                  return TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16)),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Frequency",
                              style: TextStyle(
                                  fontSize: 18, color: globals.textColor)),
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
                                      fontSize: 16, color: globals.greyColor))
                              : Text(
                                  "Every ${exercisesBox.getAt(widget.index)!.incrementFrequency.toString()} Times",
                                  style: TextStyle(
                                      fontSize: 16, color: globals.greyColor)),
                        ),
                      ]),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => frequencySelector());
                    },
                  );
                },
              )
            : const SizedBox(),
        const SizedBox(height: 10),
        exercisesBox.getAt(widget.index)!.overload
            ? Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: globals.incrementsCounter,
                    builder: (context, value, child) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: globals.circleColor,
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
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment.toInt()}${globals.lbKg} in total if you completed all sets on this exercise the last time.",
                                    style: TextStyle(
                                        fontSize: 14, color: globals.greyColor))
                                : Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment.toInt()}${globals.lbKg} in total if you completed all sets on this exercise the last ${exercisesBox.getAt(widget.index)!.incrementFrequency} times.",
                                    style: TextStyle(
                                        fontSize: 14, color: globals.greyColor))
                            : exercisesBox
                                        .getAt(widget.index)!
                                        .incrementFrequency ==
                                    1
                                ? Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment}${globals.lbKg} in total if you completed all sets on this exercise the last time.",
                                    style: TextStyle(
                                        fontSize: 14, color: globals.greyColor))
                                : Text(
                                    "Weight increases by ${exercisesBox.getAt(widget.index)!.increment}${globals.lbKg} in total if you completed all sets on this exercise the last ${exercisesBox.getAt(widget.index)!.incrementFrequency} times.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: globals.greyColor)),
                      );
                    }),
              )
            : const SizedBox(),
        TextButton(
          style: TextButton.styleFrom(
              primary: Colors.white, textStyle: const TextStyle(fontSize: 16)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(children: <Widget>[
              Expanded(
                flex: 4,
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Deload",
                        style:
                            TextStyle(fontSize: 18, color: globals.textColor)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Decrease weight if failed sets",
                        style:
                            TextStyle(fontSize: 16, color: globals.greyColor)),
                  ),
                ]),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                    inactiveThumbColor: globals.greyColor,
                    inactiveTrackColor:
                        const Color.fromARGB(255, 207, 207, 207),
                    activeColor: globals.activeSwitchColor,
                    activeTrackColor: globals.greyColor,
                    value: exercisesBox.getAt(widget.index)!.deload,
                    onChanged: toggleSwitch2,
                  ),
                ),
              ),
            ]),
          ),
          onPressed: (() => toggleSwitch2(false)),
        ),
        exercisesBox.getAt(widget.index)!.deload
            ? ValueListenableBuilder(
                valueListenable: globals.incrementsCounter,
                builder: (context, value, child) {
                  return TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 16)),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Percentage",
                                style: TextStyle(
                                    fontSize: 18, color: globals.textColor)),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "${exercisesBox.getAt(widget.index)!.deloadPercent.toString()}%",
                                style: TextStyle(
                                    fontSize: 16, color: globals.greyColor)),
                          ),
                        ]),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => percentageSelector());
                      });
                })
            : const SizedBox(),
        exercisesBox.getAt(widget.index)!.deload
            ? ValueListenableBuilder(
                valueListenable: globals.incrementsCounter,
                builder: (context, value, child) {
                  return TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16)),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Frequency",
                              style: TextStyle(
                                  fontSize: 18, color: globals.textColor)),
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
                                      fontSize: 16, color: globals.greyColor))
                              : Text(
                                  "Every ${exercisesBox.getAt(widget.index)!.deloadFrequency.toString()} Times",
                                  style: TextStyle(
                                      fontSize: 16, color: globals.greyColor)),
                        ),
                      ]),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => deloadFrequencySelector());
                    },
                  );
                },
              )
            : const SizedBox(),
        const SizedBox(height: 10),
        exercisesBox.getAt(widget.index)!.deload
            ? Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: ValueListenableBuilder(
                    valueListenable: globals.incrementsCounter,
                    builder: (context, value, child) {
                      return Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                          color: globals.circleColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: exercisesBox
                                    .getAt(widget.index)!
                                    .deloadFrequency ==
                                1
                            ? Text(
                                "Weight decreases by ${exercisesBox.getAt(widget.index)!.deloadPercent}% if you failed to complete all sets on this exercise the last time.",
                                style: TextStyle(
                                    fontSize: 14, color: globals.greyColor))
                            : Text(
                                "Weight decreases by ${exercisesBox.getAt(widget.index)!.deloadPercent}% if you failed to complete all sets on this exercise the last ${exercisesBox.getAt(widget.index)!.deloadFrequency} times.",
                                style: TextStyle(
                                    fontSize: 14, color: globals.greyColor)),
                      );
                    }),
              )
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
                      child: boolBox.getAt(7)!
                          ? const Text("-5lb")
                          : const Text("-2.5kg"),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      onPressed: () {
                        // subtracts 5lb/2.5kg from text box
                        setState(() {
                          double tempText = double.parse(_myController.text);
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
                              ? _myController.text = tempText.toInt().toString()
                              : _myController.text = tempText.toString();
                          _myController.selection = TextSelection.collapsed(
                              offset: _myController.text.length);
                        });
                      },
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      child: boolBox.getAt(7)!
                          ? const Text("+5lb")
                          : const Text("+2.5kg"),
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      onPressed: () {
                        // adds 5lb/2.5kg to text box
                        setState(() {
                          double tempText = double.parse(_myController.text);
                          if (boolBox.getAt(7)!) {
                            tempText += 5;
                          } else {
                            tempText += 2.5;
                          }
                          tempText % 1 == 0
                              ? _myController.text = tempText.toInt().toString()
                              : _myController.text = tempText.toString();
                          _myController.selection = TextSelection.collapsed(
                              offset: _myController.text.length);
                        });
                      },
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: globals.redColor,
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
                    primary: globals.redColor,
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

                    globals.incrementsCounter.value++;
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
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("Every",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                            height: 120,
                            width: 80,
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
                              itemExtent: 75,
                              onSelectedItemChanged: (index) => {
                                freq = index + 1,
                              },
                            )),
                        const SizedBox(width: 5),
                        const SizedBox(
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: globals.redColor,
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
                            primary: globals.redColor,
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

                              globals.incrementsCounter.value++;
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
                              itemExtent: 75,
                              onSelectedItemChanged: (index) => {
                                percent = index + 1,
                              },
                            )),
                        const SizedBox(width: 5),
                        const SizedBox(
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: globals.redColor,
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
                            primary: globals.redColor,
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

                              globals.incrementsCounter.value++;
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
                          height: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("Every",
                                style: TextStyle(
                                  fontSize: 14,
                                )),
                          ),
                        ),
                        const SizedBox(width: 5),
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
                              itemExtent: 75,
                              onSelectedItemChanged: (index) => {
                                freq = index + 1,
                              },
                            )),
                        const SizedBox(width: 5),
                        const SizedBox(
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: globals.redColor,
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
                            primary: globals.redColor,
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

                              globals.incrementsCounter.value++;
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ]),
                ])));
  }
}
