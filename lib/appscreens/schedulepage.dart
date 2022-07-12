import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/globals.dart' as globals;

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);
  @override
  ScheduleState createState() => ScheduleState();
}

class ScheduleState extends State<SchedulePage> {
  late final Box<bool> scheduleBox;
  late final List<String> days;

  @override
  void initState() {
    super.initState();
    scheduleBox = Hive.box<bool>('scheduleBox');
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
        'Saturday'];
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
          title: const Text("Schedule"),
          titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
        ),
        body: ListView(children: <Widget>[
          for (int i = 0; i < 7; i++)
            ListTile(
              leading: Checkbox(
                value: scheduleBox.getAt(i)!,
                activeColor: globals.redColor,
                checkColor: Colors.white,
                onChanged: (val) {
                  scheduleBox.putAt(i, val!);
                  setState(() {});
                },
              ),
              title: Text(days[i], style: TextStyle(color: globals.textColor)),
            ),
        ]));
  }
}
