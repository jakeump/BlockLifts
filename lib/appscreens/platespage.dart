import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/plate.dart';
import 'package:blocklifts/globals.dart' as globals;

class PlatesPage extends StatefulWidget {
  const PlatesPage({Key? key}) : super(key: key);
  @override
  PlatesState createState() => PlatesState();
}

class PlatesState extends State<PlatesPage> {
  late final Box<Plate> platesBox;
  late final Box<bool> boolBox;

  List<int> nums = [for (int i = 0; i < 51; i++) i * 2];

  @override
  void initState() {
    super.initState();
    platesBox = Hive.box<Plate>('platesBox');
    boolBox = Hive.box<bool>('boolBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: globals.backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: globals.headerColor,
          title: const Text("Plates"),
          titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
        ),
        body: ValueListenableBuilder(
            valueListenable: globals.plateCounter,
            builder: (context, value, child) {
              return ListView(children: <Widget>[
                for (int i = 0; i < platesBox.length; i++)
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
                                  child: platesBox.getAt(i)!.weight % 1 == 0
                                      ? Text(
                                          "${platesBox.getAt(i)!.weight.toInt().toString()}${globals.lbKg}",
                                          style: TextStyle(
                                              color: globals.textColor))
                                      : Text(
                                          "${platesBox.getAt(i)!.weight.toString()}${globals.lbKg}",
                                          style: TextStyle(
                                              color: globals.textColor))),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "${platesBox.getAt(i)!.number} plates",
                                    style: TextStyle(color: globals.greyColor)),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => plateSelector(i));
                      }),
              ]);
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: SizedBox(
            width: 100,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                fixedSize: const Size.fromHeight(50),
                primary: Colors.white,
                backgroundColor: globals.redColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
              onPressed: () {
                showDialog(context: context, builder: (context) => addPlate());
              },
              child: const Text("Add"),
            )));
  }

  Widget plateSelector(int i) {
    int tempNumber = platesBox.getAt(i)!.number;
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          insetPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: Column(children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: platesBox.getAt(i)!.weight % 1 == 0
                      ? Text(
                          "${platesBox.getAt(i)!.weight.toInt().toString()}${globals.lbKg} Plates",
                          style: const TextStyle(fontSize: 18))
                      : Text(
                          "${platesBox.getAt(i)!.weight.toString()}${globals.lbKg} Plates",
                          style: const TextStyle(fontSize: 18)),
                ),
              ),
              Flexible(
                  child: ListView(children: <Widget>[
                for (var j in nums)
                  RadioListTile<int>(
                      title: Text(j.toString(),
                          style: const TextStyle(fontSize: 15)),
                      activeColor: globals.redColor,
                      dense: true,
                      value: j,
                      groupValue: tempNumber,
                      onChanged: (value) {
                        setState(() {
                          tempNumber = value!;
                        });
                      }),
              ])),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                primary: globals.redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              onPressed: () {
                                platesBox.deleteAt(i);
                                globals.plateCounter.value++;
                                Navigator.of(context).pop();
                              },
                              child: const Text("Delete")),
                        )),
                    const Expanded(child: Text("")),
                    Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
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
                        )),
                    Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                primary: globals.redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              onPressed: () {
                                final tempPlate =
                                    Hive.box<Plate>('platesBox').getAt(i)!;
                                tempPlate.number = tempNumber;
                                tempPlate.save();
                                globals.plateCounter.value++;
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK")),
                        )),
                  ]),
            ]),
          ));
    });
  }

  Widget addPlate() {
    final myController = TextEditingController();
    myController.text = "10";
    Box<Plate> platesBox = Hive.box<Plate>('platesBox');

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Add New Plate",
                  style: TextStyle(
                    fontSize: 18,
                  )),
              const Text("Plate weight",
                  style: TextStyle(
                    fontSize: 14,
                  )),
              const SizedBox(height: 10),
              TextField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
                ],
                controller: myController,
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
              const SizedBox(height: 40),
              Row(
                children: <Widget>[
                  Expanded(
                      child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      onPressed: () {
                        // subtracts 5lb/2.5kg from text box
                        setState(() {
                          double tempText = double.parse(myController.text);
                          if (boolBox.getAt(7)!) {
                            if (tempText <= 5) {
                              tempText = 0;
                            } else {
                              tempText -= 5;
                            }
                          } else {
                            if (tempText <= 2.5) {
                              tempText = 0;
                            } else {
                              tempText -= 2.5;
                            }
                          }
                          tempText % 1 == 0
                              ? myController.text = tempText.toInt().toString()
                              : myController.text = tempText.toString();
                          myController.selection = TextSelection.collapsed(
                              offset: myController.text.length);
                        });
                      },
                      child: boolBox.getAt(7)!
                          ? const Text("-5lb")
                          : const Text("-2.5kg"),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      onPressed: () {
                        // adds 5lb/2.5kg to text box
                        setState(() {
                          double tempText = double.parse(myController.text);
                          if (boolBox.getAt(7)!) {
                            tempText += 5;
                          } else {
                            tempText += 2.5;
                          }
                          tempText % 1 == 0
                              ? myController.text = tempText.toInt().toString()
                              : myController.text = tempText.toString();
                          myController.selection = TextSelection.collapsed(
                              offset: myController.text.length);
                        });
                      },
                      child: boolBox.getAt(7)!
                          ? const Text("+5lb")
                          : const Text("+2.5kg"),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: globals.redColor,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
                        fontSize: 16, fontWeight: FontWeight.bold),
                    alignment: Alignment.center,
                  ),
                  child: const Text("OK"),
                  onPressed: () {
                    // can't add to middle of hive box, so copy box, insert,
                    // clear box, and fill box
                    final List<Plate> platesList = platesBox.values.toList();
                    double weight = double.parse(myController.text);
                    int i = 0;
                    if (platesBox.isEmpty) {
                      platesBox.add(Plate(weight, 2));
                    } else {
                      while (i < platesBox.length &&
                          weight < platesBox.getAt(i)!.weight) {
                        i++;
                      }
                      if (i == platesBox.length) {
                        if (platesBox.getAt(i - 1)!.weight == weight) {
                          final tempPlate =
                              Hive.box<Plate>('platesBox').getAt(i - 1)!;
                          tempPlate.number += 2;
                          tempPlate.save();
                        } else {
                          platesList.add(Plate(weight, 2));
                        }
                      } else {
                        if (platesBox.getAt(i)!.weight == weight) {
                          final tempPlate =
                              Hive.box<Plate>('platesBox').getAt(i)!;
                          tempPlate.number += 2;
                          tempPlate.save();
                        } else {
                          platesList.insert(i, Plate(weight, 2));
                        }
                      }

                      platesBox.deleteAll(platesBox.keys);

                      for (var plate in platesList) {
                        platesBox.add(plate);
                      }
                    }
                    globals.plateCounter.value++;
                    Navigator.of(context).pop();
                  },
                ),
              ]),
            ]),
      ),
    );
  }
}
