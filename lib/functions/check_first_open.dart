import 'package:shared_preferences/shared_preferences.dart';
import 'package:blocklifts/functions/default_state.dart';

Future<void> checkFirstOpen() async {
  // on first time opening app, sets to default state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? resetToDefault = prefs.getBool('resetToDefault');

  // if first time opening app
  if (resetToDefault == null || resetToDefault) {
    defaultState();
  }
}