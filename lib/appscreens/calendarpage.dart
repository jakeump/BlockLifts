import 'package:blocklifts/providers/calendarprovider.dart';
import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/appscreens/postworkouteditpage.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  CalendarState createState() => CalendarState();
}

class CalendarState extends State<CalendarPage>
    with AutomaticKeepAliveClientMixin {
  late final Box<IndivWorkout> indivWorkoutsBox;
  List<DateTime> datesList = [];
  late DateTime minDate;
  late DateTime minDateMonth;
  late DateTime curDate;
  late DateTime maxDate;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
  }

  void getMinMaxDate() {
    minDate = DateTime.now();
    minDateMonth = DateTime.now();
    curDate = DateTime.now();
    maxDate = DateTime.now();
    while (curDate.month == maxDate.month) {
      maxDate = DateTime(maxDate.year, maxDate.month, maxDate.day + 1);
    }
    maxDate = DateTime(maxDate.year, maxDate.month, maxDate.day - 1);

    if (indivWorkoutsBox.isNotEmpty) {
      String tempDate = indivWorkoutsBox.getAt(0)!.sortableDate;
      double date = DateTime.parse(tempDate).millisecondsSinceEpoch.toDouble();
      minDate = DateTime.fromMillisecondsSinceEpoch(date.toInt());
      minDateMonth = DateTime.fromMillisecondsSinceEpoch(date.toInt());
    }
    while (minDateMonth.month == minDate.month) {
      minDateMonth =
          DateTime(minDateMonth.year, minDateMonth.month, minDateMonth.day - 1);
    }
    minDateMonth =
        DateTime(minDateMonth.year, minDateMonth.month, minDateMonth.day + 1);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Consumer<CalendarProvider>(
          builder: (context, calendarProvider, child) {
        getMinMaxDate();
        datesList.clear();
        for (int i = 0; i < indivWorkoutsBox.length; i++) {
          String tempDate = indivWorkoutsBox.getAt(i)!.sortableDate;
          double date =
              DateTime.parse(tempDate).millisecondsSinceEpoch.toDouble();
          DateTime finalDate =
              DateTime.fromMillisecondsSinceEpoch(date.toInt());
          datesList.add(finalDate);
        }
        return Scaffold(
            backgroundColor: globals.backColor,
            body: Column(children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(children: <Widget>[
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("S",
                            style: TextStyle(color: globals.textColor)))),
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("M",
                            style: TextStyle(color: globals.textColor)))),
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("T",
                            style: TextStyle(color: globals.textColor)))),
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("W",
                            style: TextStyle(color: globals.textColor)))),
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("T",
                            style: TextStyle(color: globals.textColor)))),
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("F",
                            style: TextStyle(color: globals.textColor)))),
                SizedBox(
                    width: MediaQuery.of(context).size.width * (1 / 7),
                    child: Center(
                        child: Text("S",
                            style: TextStyle(color: globals.textColor)))),
              ]),
              Expanded(
                  child: PagedVerticalCalendar(
                      invisibleMonthsThreshold: 100,
                      startWeekWithSunday: true,
                      minDate: minDateMonth,
                      maxDate: maxDate,
                      dayBuilder: (context, date) {
                        final eventsThisDay = datesList.where((e) => e == date);
                        return Center(
                            child: CircleAvatar(
                          radius: 26,
                          backgroundColor: eventsThisDay.isNotEmpty
                              ? globals.redColor
                              : Colors.transparent,
                          child: Text(DateFormat('d').format(date),
                              style: TextStyle(
                                  color: date.day > DateTime.now().day &&
                                          date.month >= DateTime.now().month &&
                                          date.year >= DateTime.now().year
                                      ? globals.greyColor
                                      : eventsThisDay.isEmpty &&
                                              date.day == DateTime.now().day &&
                                              date.month ==
                                                  DateTime.now().month &&
                                              date.year == DateTime.now().year
                                          ? globals.redColor
                                          : globals.textColor)),
                        ));
                      },
                      onDayPressed: (date) {
                        final eventsThisDay = datesList.where((e) => e == date);
                        if (eventsThisDay.isNotEmpty) {
                          int i = datesList.indexOf(date);
                          List<List<int>> copyRepsCompleted = [];

                          for (int j = 0;
                              j <
                                  indivWorkoutsBox
                                      .getAt(i)!
                                      .repsCompleted
                                      .length;
                              j++) {
                            copyRepsCompleted.add([0]);
                            copyRepsCompleted[j].add(
                                indivWorkoutsBox.getAt(i)!.repsCompleted[j][0]);
                            copyRepsCompleted[j].removeAt(0);
                            for (int k = 1;
                                k <
                                    indivWorkoutsBox
                                        .getAt(i)!
                                        .repsCompleted[j]
                                        .length;
                                k++) {
                              copyRepsCompleted[j].add(indivWorkoutsBox
                                  .getAt(i)!
                                  .repsCompleted[j][k]);
                            }
                          }
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => PostWorkoutEditPage(
                                      i, copyRepsCompleted)))
                              .then((value) {
                            setState(() {});
                          });
                        }
                      },
                      monthBuilder: (context, month, year) {
                        return Container(
                          padding: const EdgeInsets.only(right: 20, top: 20),
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat('MMMM yyyy')
                                .format(DateTime(year, month)),
                            style: TextStyle(
                                fontSize: 14, color: globals.textColor),
                          ),
                        );
                      })),
            ]));
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
