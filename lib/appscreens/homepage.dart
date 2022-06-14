import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/appscreens/home.dart';
import 'package:blocklifts/appscreens/history.dart';
import 'package:blocklifts/appscreens/progress.dart';
import 'package:blocklifts/appscreens/settings.dart';
import 'package:blocklifts/globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // home page
  int _selectedIndex = 0;
  late final Box<bool> boolBox;

  @override
  void initState() {
    boolBox = Hive.box<bool>('boolBox');
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed && boolBox.getAt(4)! == false) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Allow Notifications',
                  style: TextStyle(fontSize: 20, color: globals.textColor)),
              content: Text(
                  'BlockLifts would like to send you notifications during workouts',
                  style: TextStyle(fontSize: 15, color: globals.textColor)),
              actions: [
                TextButton(
                  onPressed: () {
                    boolBox.putAt(4, true);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Don\'t Allow',
                    style: TextStyle(fontSize: 16, color: globals.textColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      fontSize: 16,
                      color: globals.textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          boolBox.putAt(4, true);
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = const <Widget>[
      Home(),
      History(),
      Progress(),
      Settings(),
    ];
    return ValueListenableBuilder<int>(
        valueListenable: globals.themeCounter,
        builder: (context, index, child) {
          return Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              brightness: Brightness.dark,
            ),
            child: Scaffold(
              body: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: globals.tileColor,
                selectedFontSize: 15,
                selectedItemColor: globals.redColor,
                unselectedItemColor: globals.navIconColor,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    label: "Home",
                    icon: Icon(Icons.home),
                  ),
                  BottomNavigationBarItem(
                    label: "History",
                    icon: Icon(Icons.date_range),
                  ),
                  BottomNavigationBarItem(
                    label: "Progress",
                    icon: Icon(Icons.line_axis),
                  ),
                  BottomNavigationBarItem(
                    label: "Settings",
                    icon: Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
