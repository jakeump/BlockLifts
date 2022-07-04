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
import 'package:blocklifts/globals.dart' as globals;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
    platesString = platesToString();
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
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
              ),
              onPressed: (() {
                settingsProvider.toggleThemeSwitch();
                var themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.updateTheme();
              })),
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
                                              double.parse(_myController.text.isEmpty
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
                      child: Text(
                          defaultsBox.getAt(1)!.toInt().toString() + " sets",
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
                                              double.parse(_myController.text.isEmpty
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
                      child: Text(
                          defaultsBox.getAt(2)!.toInt().toString() + " reps",
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
                                        defaultsBox.putAt(2,
                                              double.parse(_myController.text.isEmpty
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
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
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
            onPressed: (() => settingsProvider.toggleAwakeSwitch()),
          ),
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
        ]),
      );
    });
  }

  Widget unitSelector() {
    int tempUnit = boolBox.getAt(7)! ? 0 : 1;
    return StatefulBuilder(builder: (context, _setState) {
      return Dialog(
          backgroundColor: globals.tileColor,
          insetPadding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text("Weight Unit", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  RadioListTile<int>(
                      title: const Text("lb", style: TextStyle(fontSize: 15)),
                      activeColor: globals.redColor,
                      dense: true,
                      value: 0,
                      groupValue: tempUnit,
                      onChanged: (value) {
                        _setState(() {
                          tempUnit = value!;
                        });
                      }),
                  RadioListTile<int>(
                      title: const Text("kg", style: TextStyle(fontSize: 15)),
                      activeColor: globals.redColor,
                      dense: true,
                      value: 1,
                      groupValue: tempUnit,
                      onChanged: (value) {
                        _setState(() {
                          tempUnit = value!;
                        });
                      }),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                            child: const Text("Cancel"),
                            style: TextButton.styleFrom(
                              primary: globals.redColor,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              alignment: Alignment.center,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                        const SizedBox(width: 20),
                        TextButton(
                            child: const Text("OK"),
                            style: TextButton.styleFrom(
                              primary: globals.redColor,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              alignment: Alignment.center,
                            ),
                            onPressed: () {
                              setState(() {
                                boolBox.putAt(7, tempUnit == 0 ? true : false);
                                globals.lbKg = tempUnit == 0 ? "lb" : "kg";
                              });
                            var progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                            progressProvider.updateProgress();
                            var homeProvider = Provider.of<HomeProvider>(context, listen: false);
                            homeProvider.updateHome();
                            var listProvider = Provider.of<ListProvider>(context, listen: false);
                            listProvider.updateList();
                            Navigator.of(context).pop();
                            }),
                      ]),
                ]),
          ));
    });
  }
}
