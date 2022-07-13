import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/plate.dart';
import 'package:blocklifts/functions/default_state.dart';
import 'package:blocklifts/appscreens/timerpage.dart';
import 'package:blocklifts/appscreens/platespage.dart';
import 'package:blocklifts/providers/settingsprovider.dart';
import 'package:blocklifts/providers/themeprovider.dart';
import 'package:blocklifts/providers/progressprovider.dart';
import 'package:blocklifts/providers/homeprovider.dart';
import 'package:blocklifts/providers/listprovider.dart';
import 'package:provider/provider.dart';
import 'package:application_icon/application_icon.dart';
import 'package:blocklifts/globals.dart' as globals;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  late final Box<bool> boolBox;
  late final Box<Plate> platesBox;
  late final Box<double> defaultsBox;
  String platesString = "";
  final _myController = TextEditingController();

  String platesToString() {
    String output = '';
    for (int i = 0; i < platesBox.length; ++i) {
      output += platesBox.getAt(i)!.number.toString();
      output += '×';
      platesBox.getAt(i)!.weight % 1 == 0
          ? output += platesBox.getAt(i)!.weight.toInt().toString()
          : output += platesBox.getAt(i)!.weight.toString();
      i == platesBox.length - 1 ? output += globals.lbKg : output += ' ⋅ ';
    }
    return output;
  }

  @override
  void initState() {
    super.initState();
    boolBox = Hive.box<bool>('boolBox');
    platesBox = Hive.box<Plate>('platesBox');
    defaultsBox = Hive.box<double>('defaultsBox');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
      platesString = platesToString();
      return Scaffold(
        backgroundColor: globals.backColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: globals.headerColor,
          title: const Text("Settings"),
          titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
        ),
        body: ListView(children: <Widget>[
          TextButton(
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  textStyle: const TextStyle(fontSize: 16)),
              onPressed: (() {
                settingsProvider.toggleThemeSwitch();
                var themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.updateTheme();
              }),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Dark Mode",
                          style: TextStyle(color: globals.textColor)),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        inactiveThumbColor: globals.greyColor,
                        inactiveTrackColor:
                            const Color.fromARGB(255, 207, 207, 207),
                        activeColor: globals.activeSwitchColor,
                        activeTrackColor: globals.greyColor,
                        value: boolBox.getAt(0)!,
                        onChanged: ((bool value) {
                          settingsProvider.toggleThemeSwitch();
                          var themeProvider = Provider.of<ThemeProvider>(
                              context,
                              listen: false);
                          themeProvider.updateTheme();
                        }),
                      ),
                    ),
                  ),
                ]),
              )),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Timer",
                          style: TextStyle(color: globals.textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: boolBox.getAt(1)! == true
                          ? Text("On",
                              style: TextStyle(color: globals.greyColor))
                          : Text("Off",
                              style: TextStyle(color: globals.greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => const TimerPage()))
                  .then((value) {
                setState(() {});
              });
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Weight Unit",
                          style: TextStyle(color: globals.textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: boolBox.getAt(7)! == true
                          ? Text("lb",
                              style: TextStyle(color: globals.greyColor))
                          : Text("kg",
                              style: TextStyle(color: globals.greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              showDialog(
                  context: context, builder: (context) => unitSelector());
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Plates",
                          style: TextStyle(color: globals.textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(platesString,
                          style: TextStyle(color: globals.greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => const PlatesPage()))
                  .then((value) {
                setState(() {});
              });
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Default Bar Weight",
                      style: TextStyle(color: globals.textColor)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: defaultsBox.getAt(0)! % 1 == 0
                      ? Text(
                          defaultsBox.getAt(0)!.toInt().toString() +
                              globals.lbKg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: globals.greyColor))
                      : Text(defaultsBox.getAt(0)!.toString() + globals.lbKg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: globals.greyColor)),
                ),
              ]),
            ),
            onPressed: () {
              defaultsBox.getAt(0)! % 1 == 0
                  ? _myController.text =
                      defaultsBox.getAt(0)!.toInt().toString()
                  : _myController.text = defaultsBox.getAt(0)!.toString();
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                        insetPadding: const EdgeInsets.all(10),
                        child: Container(
                          color: globals.tileColor,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Default Bar Weight",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: globals.textColor))),
                                const SizedBox(height: 20),
                                TextField(
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter(
                                        RegExp(r'[0-9.]'),
                                        allow: true)
                                  ],
                                  style: TextStyle(color: globals.textColor),
                                  controller: _myController,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                Divider(
                                  color: globals.underlineColor,
                                  height: 2,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("OK"),
                                        onPressed: () {
                                          setState(() {
                                            defaultsBox.putAt(
                                                0,
                                                double.parse(
                                                    _myController.text.isEmpty
                                                        ? "0"
                                                        : _myController.text));
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ]),
                              ]),
                        ),
                      ));
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Default Sets",
                          style: TextStyle(color: globals.textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("${defaultsBox.getAt(1)!.toInt()} sets",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: globals.greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              _myController.text = defaultsBox.getAt(1)!.toInt().toString();
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                        insetPadding: const EdgeInsets.all(10),
                        child: Container(
                          color: globals.tileColor,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Default Sets",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: globals.textColor))),
                                const SizedBox(height: 20),
                                TextField(
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter(
                                        RegExp(r'[0-99]'),
                                        allow: true)
                                  ],
                                  style: TextStyle(color: globals.textColor),
                                  controller: _myController,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                Divider(
                                  color: globals.underlineColor,
                                  height: 2,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: globals.redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("OK"),
                                        onPressed: () {
                                          setState(() {
                                            defaultsBox.putAt(
                                                1,
                                                double.parse(
                                                    _myController.text.isEmpty
                                                        ? "0"
                                                        : _myController.text));
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ]),
                              ]),
                        ),
                      ));
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Default Reps",
                          style: TextStyle(color: globals.textColor)),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("${defaultsBox.getAt(2)!.toInt()} reps",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: globals.greyColor)),
                    ),
                  ]),
                ),
              ]),
            ),
            onPressed: () {
              _myController.text = defaultsBox.getAt(2)!.toInt().toString();
              showDialog(
                context: context,
                builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(10),
                    child: Container(
                      color: globals.tileColor,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Default Reps",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: globals.textColor))),
                            const SizedBox(height: 20),
                            TextField(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter(RegExp(r'[0-99]'),
                                    allow: true)
                              ],
                              style: TextStyle(color: globals.textColor),
                              controller: _myController,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 10),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                            Divider(
                              color: globals.underlineColor,
                              height: 2,
                              thickness: 2,
                            ),
                            const SizedBox(height: 20),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: globals.redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: globals.redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("OK"),
                                    onPressed: () {
                                      setState(() {
                                        defaultsBox.putAt(
                                            2,
                                            double.parse(
                                                _myController.text.isEmpty
                                                    ? "0"
                                                    : _myController.text));
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ]),
                          ]),
                    )),
              );
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16)),
            onPressed: (() => settingsProvider.toggleAwakeSwitch()),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Keep Screen Awake",
                        style: TextStyle(color: globals.textColor)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      inactiveThumbColor: globals.greyColor,
                      inactiveTrackColor:
                          const Color.fromARGB(255, 207, 207, 207),
                      activeColor: globals.activeSwitchColor,
                      activeTrackColor: globals.greyColor,
                      value: boolBox.getAt(6)!,
                      onChanged: ((bool value) {
                        settingsProvider.toggleAwakeSwitch();
                      }),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Divider(
              height: 10,
              thickness: 1,
              color: globals.dividerColor,
              indent: 10,
              endIndent: 10),
          Theme(
            data: ThemeData(
              brightness:
                  boolBox.getAt(0)! ? Brightness.dark : Brightness.light,
            ),
            child: AboutListTile(
              applicationIcon:
                  const SizedBox(width: 50, height: 50, child: AppIconImage()),
              applicationVersion: "Version 1.0.0",
              aboutBoxChildren: [
                GestureDetector(
                    child: const Text("GitHub",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue)),
                    onTap: () => launchUrl(
                          Uri.parse('https://github.com/jakeump/BlockLifts'),
                          mode: LaunchMode.externalApplication,
                        )),
                const SizedBox(height: 10),
                GestureDetector(
                    child: const Text("Submit Issue on GitHub",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue)),
                    onTap: () => launchUrl(
                        Uri.parse(
                            'https://github.com/jakeump/BlockLifts/issues/new'),
                        mode: LaunchMode.externalApplication)),
                const SizedBox(height: 10),
                GestureDetector(
                    child: const Text("Issue/Suggestion Google Form",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue)),
                    onTap: () => launchUrl(
                        Uri.parse('https://forms.gle/x3BoENMd7Ejbqiu1A'),
                        mode: LaunchMode.externalApplication)),
              ],
              child: Text("About BlockLifts",
                  style: TextStyle(color: globals.textColor)),
            ),
          ),
          Divider(
              height: 10,
              thickness: 1,
              color: globals.dividerColor,
              indent: 10,
              endIndent: 10),
          TextButton(
              style: TextButton.styleFrom(
                  primary: globals.redColor,
                  textStyle: const TextStyle(fontSize: 16)),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Reset",
                        style: TextStyle(color: globals.redColor))),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: globals.tileColor,
                    title: Text('Reset All Data',
                        style:
                            TextStyle(fontSize: 20, color: globals.textColor)),
                    content: Text(
                        'This will permanently erase all data from this device, including your workouts and settings. The app will return to defaults.',
                        style:
                            TextStyle(fontSize: 15, color: globals.textColor)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 16, color: globals.redColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          defaultState();
                          settingsProvider.updatePage();
                          var themeProvider = Provider.of<ThemeProvider>(
                              context,
                              listen: false);
                          themeProvider.updateTheme();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 16,
                            color: globals.redColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
        ]),
      );
    });
  }

  Widget unitSelector() {
    int tempUnit = boolBox.getAt(7)! ? 0 : 1;
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          backgroundColor: globals.tileColor,
          insetPadding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Weight Unit",
                      style: TextStyle(fontSize: 18, color: globals.textColor)),
                  const SizedBox(height: 20),
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: globals.textColor,
                    ),
                    child: RadioListTile<int>(
                        title: Text("lb",
                            style: TextStyle(
                                fontSize: 15, color: globals.textColor)),
                        activeColor: globals.redColor,
                        dense: true,
                        value: 0,
                        groupValue: tempUnit,
                        onChanged: (value) {
                          setState(() {
                            tempUnit = value!;
                          });
                        }),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: globals.textColor,
                    ),
                    child: RadioListTile<int>(
                        title: Text("kg",
                            style: TextStyle(
                                fontSize: 15, color: globals.textColor)),
                        activeColor: globals.redColor,
                        dense: true,
                        value: 1,
                        groupValue: tempUnit,
                        onChanged: (value) {
                          setState(() {
                            tempUnit = value!;
                          });
                        }),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: <
                      Widget>[
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: globals.redColor,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel")),
                    const SizedBox(width: 20),
                    TextButton(
                        style: TextButton.styleFrom(
                          primary: globals.redColor,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          boolBox.putAt(7, tempUnit == 0 ? true : false);
                          globals.lbKg = tempUnit == 0 ? "lb" : "kg";
                          var settingsProvider = Provider.of<SettingsProvider>(
                              context,
                              listen: false);
                          settingsProvider.updatePage();
                          var progressProvider = Provider.of<ProgressProvider>(
                              context,
                              listen: false);
                          progressProvider.updateProgress();
                          var homeProvider =
                              Provider.of<HomeProvider>(context, listen: false);
                          homeProvider.updateHome();
                          var listProvider =
                              Provider.of<ListProvider>(context, listen: false);
                          listProvider.updateList();
                          Navigator.of(context).pop();
                        },
                        child: const Text("OK")),
                  ]),
                ]),
          ));
    });
  }
}
