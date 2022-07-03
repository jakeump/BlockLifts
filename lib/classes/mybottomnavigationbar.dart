import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/classes/providers/themeprovider.dart';
import 'package:blocklifts/classes/providers/bottomnavigationbarprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class MyBottomNavigationBar extends StatelessWidget {
  @override
  const MyBottomNavigationBar({
    Key? key,
    required this.onTapped,
  }) : super(key: key);
  final Function(int) onTapped;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return BottomNavigationBar(
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: globals.tileColor,
        selectedItemColor: globals.redColor,
        unselectedItemColor: globals.navIconColor,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: onTapped,
        currentIndex:
            Provider.of<BottomNavigationBarProvider>(context).currentIndex,
      );
    });
  }
}
