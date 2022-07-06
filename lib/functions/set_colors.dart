import 'package:flutter/services.dart';
import 'package:blocklifts/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void setColors() {
  final Box<bool> boolBox = Hive.box<bool>('boolBox');
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
  // try integrating this lower in widget hierarchy. under materialapp
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}
