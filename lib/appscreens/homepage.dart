import 'package:blocklifts/appscreens/history.dart';
import 'package:blocklifts/appscreens/home.dart';
import 'package:blocklifts/appscreens/progress.dart';
import 'package:blocklifts/appscreens/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/mybottomnavigationbar.dart';
import 'package:blocklifts/classes/bottomnavigationbarprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Box<bool> boolBox;

  @override
  void initState() {
    super.initState();
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
  }

  var currentTab = const [
    Home(),
    History(),
    Progress(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
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
              body: currentTab[provider.currentIndex],
              bottomNavigationBar: MyBottomNavigationBar(onTapped: _onTappedBar),
            ),
          );
        });
  }

  void _onTappedBar(int value) {
    Provider.of<BottomNavigationBarProvider>(context, listen: false).currentIndex = value;
  }
}
