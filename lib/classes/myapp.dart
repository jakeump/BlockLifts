import 'package:blocklifts/classes/providers/calendarprovider.dart';
import 'package:blocklifts/classes/providers/progressprovider.dart';
import 'package:blocklifts/classes/providers/settingsprovider.dart';
import 'package:blocklifts/classes/providers/workouttimerprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/functions/increment_circles.dart';
import 'package:blocklifts/classes/customscrollbehavior.dart';
import 'package:blocklifts/appscreens/homepage.dart';
import 'package:blocklifts/classes/providers/themeprovider.dart';
import 'package:blocklifts/classes/providers/bottomnavigationbarprovider.dart';
import 'package:blocklifts/classes/providers/homeprovider.dart';
import 'package:blocklifts/classes/providers/listprovider.dart';
import 'package:blocklifts/classes/providers/timerprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.androidSdkVersion}) : super(key: key);

  final int androidSdkVersion;
  final Box<bool> boolBox = Hive.box<bool>('boolBox');

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().actionStream.listen((action) {
      if (action.buttonKeyPressed == "done") {
        incrementCircles(globals.workoutIndex, globals.exerciseIndex,
            globals.setIndex + 1, false);
      } else if (action.buttonKeyPressed == "failed") {
        incrementCircles(globals.workoutIndex, globals.exerciseIndex,
            globals.setIndex + 1, true);
      }
    });
    boolBox.getAt(7)! ? globals.lbKg = "lb" : globals.lbKg = "kg";
    if (boolBox.getAt(0)!) {
      // dark mode
      globals.backColor = Colors.black;
      globals.tileColor = const Color.fromARGB(255, 29, 29, 29);
      globals.textColor = Colors.white;
      globals.dividerColor = const Color.fromARGB(133, 65, 64, 64);
      globals.underlineColor = Colors.white.withOpacity(.7);
      globals.circleColor = const Color.fromARGB(255, 38, 38, 38);
      globals.emptyCircleTextColor = const Color.fromARGB(255, 103, 103, 103);
      globals.greyColor = const Color.fromARGB(255, 165, 165, 165);
      globals.headerColor = Colors.black;
      globals.borderColor = const Color.fromARGB(255, 62, 62, 62);
      globals.navIconColor = const Color.fromARGB(255, 176, 176, 176);
      globals.activeSwitchColor = Colors.white;
    } else {
      // light mode
      globals.backColor = Colors.white;
      globals.headerColor = Colors.white;
      globals.tileColor = Colors.white;
      globals.textColor = Colors.black;
      globals.dividerColor = globals.greyColor;
      globals.underlineColor = const Color.fromARGB(103, 0, 0, 0);
      globals.circleColor = const Color.fromARGB(255, 238, 238, 238);
      globals.emptyCircleTextColor = const Color.fromARGB(255, 199, 199, 199);
      globals.greyColor = const Color.fromARGB(255, 108, 108, 108);
      globals.borderColor = const Color.fromARGB(255, 224, 224, 224);
      globals.navIconColor = const Color.fromARGB(255, 87, 87, 87);
      globals.activeSwitchColor = const Color.fromARGB(255, 49, 48, 48);
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<BottomNavigationBarProvider>(
            create: (_) => BottomNavigationBarProvider(),
          ),
          ChangeNotifierProvider<HomeProvider>(
            create: (_) => HomeProvider(),
          ),
          ChangeNotifierProvider<ListProvider>(
            create: (_) => ListProvider(),
          ),
          ChangeNotifierProvider<CalendarProvider>(
            create: (_) => CalendarProvider(),
          ),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(),
          ),
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider(),
          ),
          ChangeNotifierProvider<TimerProvider>(
            create: (_) => TimerProvider(),
          ),
          ChangeNotifierProvider<WorkoutTimerProvider>(
            create: (_) => WorkoutTimerProvider(),
          ),
        ],
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'BlockLifts',
              theme: ThemeData(
                // light theme
                useMaterial3: true,
                backgroundColor: Colors.white,
                brightness: Brightness.light,
                dialogTheme: DialogTheme(
                  backgroundColor: globals.tileColor,
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          width: 0.0, style: BorderStyle.none)),
                ),
                popupMenuTheme: PopupMenuThemeData(
                  color: globals.tileColor,
                ),
                textSelectionTheme: const TextSelectionThemeData(
                  selectionHandleColor: Colors.black,
                  cursorColor: Colors.black,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                backgroundColor: Colors.black,
                brightness: Brightness.dark,
                dialogTheme: DialogTheme(
                  backgroundColor: globals.tileColor,
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          width: 0.0, style: BorderStyle.none)),
                ),
                popupMenuTheme: PopupMenuThemeData(
                  color: globals.tileColor,
                ),
                textSelectionTheme: TextSelectionThemeData(
                  selectionHandleColor: Colors.white.withOpacity(.5),
                  cursorColor: Colors.white.withOpacity(.5),
                ),
              ),
              themeMode: boolBox.getAt(0)! ? ThemeMode.dark : ThemeMode.light,
              home: ScrollConfiguration(
                behavior: CustomScrollBehavior(
                  androidSdkVersion: androidSdkVersion,
                ),
                child: const HomePage(),
              ));
        }));
  }
}
