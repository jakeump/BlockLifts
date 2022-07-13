import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:flutter/cupertino.dart';
import 'package:blocklifts/globals.dart' as globals;


class SetTimerPage extends StatefulWidget {
    // a value of 0 corresponds to success timer, 1 to fail timer
    final int index;
    const SetTimerPage(this.index, {Key? key}) : super(key: key);
    @override
    SetTimerState createState() => SetTimerState();
}

class SetTimerState extends State<SetTimerPage> {
  // a widget.index value of 0 corresponds to success timer, 1 to fail timer
  List<Widget> mins = [
    for (int i = 0; i < 11; i++) ListTile(title: Text(i.toString())),
  ];
  List<Widget> secs = [
    for (int i = 0; i < 60; i++) ListTile(title: Text(i.toString())),
  ];

  int minutes = 0;
  int seconds = 0;

  late final Box<TimerMap> successTimerBox;
  late final Box<TimerMap> failTimerBox;
  List<int> times = [];

  @override
  void initState() {
    super.initState();
    successTimerBox = Hive.box<TimerMap>('successTimerBox');
    failTimerBox = Hive.box<TimerMap>('failTimerBox');
    if (widget.index == 0) {
      for (int i = 0; i < successTimerBox.length; i++) {
        times.add(successTimerBox.getAt(i)!.time);
      }
    } else {
      for (int i = 0; i < failTimerBox.length; i++) {
        times.add(failTimerBox.getAt(i)!.time);
      }
    }
    times.sort();
  }

  bool isChecked(Box<TimerMap> input, int index) {
    for (int i = 0; i < input.length; i++) {
      if (input.getAt(i)!.time == times[index]) {
        return input.getAt(i)!.isChecked;
      }
    }
    return false;
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
        title: widget.index == 0
            ? const Text("Success Timer")
            : const Text("Fail Timer"),
        titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
      ),
      body: ListView(children: <Widget>[
        for (int index = 0; index < times.length; index++)
          ListTile(
            leading: Checkbox(
              value: widget.index == 0
                  ? isChecked(successTimerBox, index)
                  : isChecked(failTimerBox, index),
              activeColor: globals.redColor,
              checkColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  if (widget.index == 0) {
                    for (int idx = 0; idx < successTimerBox.length; idx++) {
                      if (successTimerBox.getAt(idx)!.time == times[index]) {
                        final tempTime =
                            Hive.box<TimerMap>('successTimerBox').getAt(idx);
                        tempTime!.isChecked = value!;
                        tempTime.save();
                      }
                    }
                  } else {
                    for (int idx = 0; idx < failTimerBox.length; idx++) {
                      if (failTimerBox.getAt(idx)!.time == times[index]) {
                        final tempTime =
                            Hive.box<TimerMap>('failTimerBox').getAt(idx);
                        tempTime!.isChecked = value!;
                        tempTime.save();
                      }
                    }
                  }
                });
              },
            ),
            title: widget.index == 0
                ? times[index] % 60 == 0
                    ? Text("${(times[index] ~/ 60).toString()}min")
                    : Text(
                        "${(times[index] ~/ 60).toString()}min ${(times[index] % 60).toString()}s")
                : times[index] % 60 == 0
                    ? Text("${(times[index] ~/ 60).toString()}min")
                    : Text(
                        "${(times[index] ~/ 60).toString()}min ${(times[index] % 60).toString()}s"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  if (widget.index == 0) {
                    for (int i = 0; i < successTimerBox.length; i++) {
                      if (successTimerBox.getAt(i)!.time == times[index]) {
                        successTimerBox.deleteAt(i);
                      }
                    }
                    times.removeAt(index);
                  } else {
                    for (int i = 0; i < failTimerBox.length; i++) {
                      if (failTimerBox.getAt(i)!.time == times[index]) {
                        failTimerBox.deleteAt(i);
                      }
                    }
                    times.removeAt(index);
                  }
                });
              },
            ),
          ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
          child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          fixedSize: const Size.fromHeight(50),
          primary: Colors.white,
          backgroundColor: globals.redColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
        ),
        onPressed: () {
          final minController = FixedExtentScrollController();
          final secController = FixedExtentScrollController();
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
                            widget.index == 0
                                ? const Text("Success Timer",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ))
                                : const Text("Fail Timer",
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
                                      width: 70,
                                      child: CupertinoPicker(
                                        scrollController: minController,
                                        looping: true,
                                        diameterRatio: 1.25,
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
                                        itemExtent: 75,
                                        onSelectedItemChanged: (index) => {
                                          minutes = index,
                                        },
                                        children: mins,
                                      )),
                                  const SizedBox(
                                    height: 40,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text("min ",
                                          style: TextStyle(
                                            fontSize: 14,
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                      height: 120,
                                      width: 70,
                                      child: CupertinoPicker(
                                        scrollController: secController,
                                        looping: true,
                                        diameterRatio: 1.25,
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
                                        itemExtent: 75,
                                        onSelectedItemChanged: (index) => {
                                          seconds = index,
                                        },
                                        children: secs,
                                      )),
                                  const SizedBox(
                                    height: 40,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text("sec",
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
                                      bool duplicate = false;
                                      setState(() {
                                        times.add(minutes * 60 + seconds);

                                        if (widget.index == 0) {
                                          // check for duplicate time in success timer box
                                          for (int i = 0;
                                              i < successTimerBox.length;
                                              i++) {
                                            if (successTimerBox
                                                    .getAt(i)!
                                                    .time ==
                                                times.last && !duplicate) {
                                              duplicate = true;
                                              times.removeLast();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Timer already exists"),
                                                duration: Duration(seconds: 2),
                                              ));
                                            }
                                          }
                                          if (!duplicate) {
                                            successTimerBox.add(TimerMap(
                                                minutes * 60 + seconds, true));
                                            times.sort();
                                            Navigator.of(context).pop();
                                            minutes = seconds = 0;
                                          }
                                        } else {
                                          // check for duplicate time in fail timer box
                                          for (int i = 0;
                                              i < failTimerBox.length;
                                              i++) {
                                            if (failTimerBox.getAt(i)!.time ==
                                                times.last && !duplicate) {
                                              duplicate = true;
                                              times.removeLast();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Timer already exists"),
                                                duration: Duration(seconds: 2),
                                              ));
                                            }
                                          }
                                          if (!duplicate) {
                                            failTimerBox.add(TimerMap(
                                                minutes * 60 + seconds, true));
                                            Navigator.of(context).pop();
                                            times.sort();
                                            minutes = seconds = 0;
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ]),
                          ]))));
        },
        child: const Text("Add Timer", style: TextStyle(fontSize: 16)),
      )),
    );
  }
}
