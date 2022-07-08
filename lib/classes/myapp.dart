import 'package:blocklifts/providers/calendarprovider.dart';
import 'package:blocklifts/providers/progressprovider.dart';
import 'package:blocklifts/providers/settingsprovider.dart';
import 'package:blocklifts/providers/workouttimerprovider.dart';
import 'package:flutter/material.dart';
import 'package:blocklifts/appscreens/workoutpage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/customscrollbehavior.dart';
import 'package:blocklifts/appscreens/homepage.dart';
import 'package:blocklifts/appscreens/home.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/providers/homeprovider.dart';
import 'package:blocklifts/providers/notesprovider.dart';
import 'package:blocklifts/providers/listprovider.dart';
import 'package:blocklifts/providers/timerprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/functions/set_colors.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blocklifts/classes/notificationcontroller.dart';
import 'package:blocklifts/classes/timermap.dart';
import 'package:blocklifts/globals.dart' as globals;

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.androidSdkVersion}) : super(key: key);

  final int androidSdkVersion;
  final Box<bool> boolBox = Hive.box<bool>('boolBox');
  final Box<int> counterBox = Hive.box<int>('counterBox');
  final Box<TimerMap> successTimerBox = Hive.box<TimerMap>('successTimerBox');
  final Box<TimerMap> failTimerBox = Hive.box<TimerMap>('failTimerBox');
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
    globals.successTimes.clear();
    globals.failureTimes.clear();
    for (int i = 0; i < successTimerBox.length; i++) {
      globals.successTimes.add(successTimerBox.getAt(i)!.time);
    }
    for (int i = 0; i < failTimerBox.length; i++) {
      globals.failureTimes.add(failTimerBox.getAt(i)!.time);
    }
    globals.successTimes.sort();
    globals.failureTimes.sort();
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
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          setColors();
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'BlockLifts',
              navigatorKey: navigatorKey,
              initialRoute: '/',
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case '/':
                    return MaterialPageRoute(
                      builder: (context) => const Home(),
                    );
                  case '/WorkoutPage':
                    return MaterialPageRoute(builder: (context) {
                      return WorkoutPage(counterBox.getAt(0)!);
                    });
                  default:
                    assert(false, 'Page ${settings.name} not found');
                    return null;
                }
              },
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
                  child: AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle(
                      systemNavigationBarColor:
                          boolBox.getAt(0)! ? Colors.black : Colors.white,
                    ),
                    child: const HomePage(),
                  )));
        }));
  }

  static of(BuildContext? currentContext) {}
}
