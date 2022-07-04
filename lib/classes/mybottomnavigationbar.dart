import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/globals.dart' as globals;

class MyBottomNavigationBar extends StatelessWidget {
  @override
  const MyBottomNavigationBar({
    Key? key,
    required this.onTapped,
    required this.currentIndex,
  }) : super(key: key);
  final Function(int) onTapped;
  final int currentIndex;

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
        currentIndex: currentIndex,
      );
    });
  }
}
