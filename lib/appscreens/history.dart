import 'package:flutter/material.dart';
import 'package:blocklifts/appscreens/listpage.dart';
import 'package:blocklifts/appscreens/calendarpage.dart';
import 'package:blocklifts/appscreens/notespage.dart';
import 'package:blocklifts/globals.dart' as globals;

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              brightness: Brightness.dark,
            ),
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: globals.headerColor,
                  title: const Text("History"),
                  titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
                  bottom: TabBar(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    isScrollable: false,
                    indicatorColor: globals.redColor,
                    labelColor: globals.textColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'List'),
                      Tab(text: 'Calendar'),
                      Tab(text: 'Notes'),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    ListPage(),
                    CalendarPage(),
                    NotesPage(),
                  ],
                ),
              ),
            ),
          );
  }
}
