import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:blocklifts/appscreens/settimerpage.dart';
import 'package:blocklifts/providers/timerprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  TimerState createState() => TimerState();
}

class TimerState extends State<TimerPage> {
  late final Box<bool> boolBox;
  late final Box<TimerMap> successTimerBox;
  late final Box<TimerMap> failTimerBox;

  String successTimes = '';
  String failTimes = '';

  // ring
  void toggleSwitch2(bool value) {
    if (boolBox.getAt(2)! == false) {
      setState(() {
        boolBox.putAt(2, true);
      });
    } else {
      setState(() {
        boolBox.putAt(2, false);
      });
    }
  }

  // vibration
  void toggleSwitch3(bool value) {
    if (boolBox.getAt(3)! == false) {
      setState(() {
        boolBox.putAt(3, true);
      });
    } else {
      setState(() {
        boolBox.putAt(3, false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    boolBox = Hive.box<bool>('boolBox');
    successTimerBox = Hive.box<TimerMap>('successTimerBox');
    failTimerBox = Hive.box<TimerMap>('failTimerBox');
  }

  String addTimes(Box<TimerMap> input) {
    String output = '';
    List<int> times = [];
    for (int i = 0; i < input.length; i++) {
      if (input.getAt(i)!.isChecked == true) {
        times.add(input.getAt(i)!.time);
      }
    }
    times.sort();
    for (int i = 0; i < times.length - 1; i++) {
      if (times[i] % 60 == 0) {
        output += '${times[i] ~/ 60}min, ';
      } else {
        output += '${times[i] ~/ 60}min ${times[i] % 60}s, ';
      }
    }
    if (times.isNotEmpty) {
      if (times[times.length - 1] % 60 == 0) {
        output += '${times[times.length - 1] ~/ 60}min';
      } else {
        output += '${times[times.length - 1] ~/ 60}min ${times[times.length - 1] % 60}s';
      }
    }
    if (output.isEmpty) {
      output = "No timers";
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    successTimes = addTimes(successTimerBox);
    failTimes = addTimes(failTimerBox);
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
          title: const Text("Timer"),
          titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
        ),
        body: Consumer<TimerProvider>(
            builder: (context, timerProvider, child) {
          return ListView(children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  textStyle: const TextStyle(fontSize: 16)),
              onPressed: (() => timerProvider.toggleTimerSwitch(false)),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Timer",
                              style: TextStyle(color: globals.textColor)),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: boolBox.getAt(1)! == true
                              ? Text("On",
                                  style: TextStyle(color: globals.greyColor))
                              : Text("Off",
                                  style: TextStyle(color: globals.greyColor)),
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
                          value: boolBox.getAt(1)!,
                          onChanged: timerProvider.toggleTimerSwitch,
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
            boolBox.getAt(1)!
                ? TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: (() => toggleSwitch2(false)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Column(children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Ring",
                                    style: TextStyle(color: globals.textColor)),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: boolBox.getAt(2)! == true
                                    ? Text("Enabled",
                                        style:
                                            TextStyle(color: globals.greyColor))
                                    : Text("Disabled",
                                        style: TextStyle(
                                            color: globals.greyColor)),
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
                                value: boolBox.getAt(2)!,
                                onChanged: toggleSwitch2,
                              ),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  )
                : const SizedBox(),
            boolBox.getAt(1)!
                ? TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16)),
                    onPressed: (() => toggleSwitch3(false)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Row(children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: Column(children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Vibration",
                                    style: TextStyle(color: globals.textColor)),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: boolBox.getAt(3)! == true
                                    ? Text("Enabled",
                                        style:
                                            TextStyle(color: globals.greyColor))
                                    : Text("Disabled",
                                        style: TextStyle(
                                            color: globals.greyColor)),
                              ),
                              boolBox.getAt(3)!
                                  ? const SizedBox(height: 8)
                                  : const SizedBox(),
                              boolBox.getAt(3)!
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          "Notification vibrations must be enabled",
                                          style: TextStyle(
                                              color: globals.greyColor,
                                              fontSize: 12)),
                                    )
                                  : const SizedBox(),
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
                                value: boolBox.getAt(3)!,
                                onChanged: toggleSwitch3,
                              ),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  )
                : const SizedBox(),
            boolBox.getAt(1)!
                ? TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Success Timer",
                              style: TextStyle(color: globals.textColor)),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(successTimes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: globals.greyColor)),
                        ),
                      ]),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => const SetTimerPage(0)))
                          .then((value) {
                        setState(() {});
                      });
                    },
                  )
                : const SizedBox(),
            boolBox.getAt(1)!
                ? TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16)),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Fail Timer",
                              style: TextStyle(color: globals.textColor)),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(failTimes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: globals.greyColor)),
                        ),
                      ]),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => const SetTimerPage(1)))
                          .then((value) {
                        setState(() {});
                      });
                    },
                  )
                : const SizedBox(),
          ]);
        }));
  }
}
