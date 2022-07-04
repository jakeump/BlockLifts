import 'package:blocklifts/providers/calendarprovider.dart';
import 'package:blocklifts/providers/progressprovider.dart';
import 'package:blocklifts/providers/settingsprovider.dart';
import 'package:blocklifts/providers/workouttimerprovider.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/functions/increment_circles.dart';
import 'package:blocklifts/classes/customscrollbehavior.dart';
import 'package:blocklifts/appscreens/homepage.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/providers/homeprovider.dart';
import 'package:blocklifts/providers/notesprovider.dart';
import 'package:blocklifts/providers/listprovider.dart';
import 'package:blocklifts/providers/timerprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/functions/set_colors.dart';
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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
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
          ChangeNotifierProvider<NotesProvider>(
            create: (_) => NotesProvider(),
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
        child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          setColors();
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
