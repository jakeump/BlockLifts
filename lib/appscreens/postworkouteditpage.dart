import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/appscreens/postworkoutnotespage.dart';
import 'package:blocklifts/classes/providers/calendarprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class PostWorkoutEditPage extends StatefulWidget {
  final int index;
  final List<List<int>> copyRepsCompleted;

  const PostWorkoutEditPage(this.index, this.copyRepsCompleted, {Key? key})
      : super(key: key);
  @override
  _PostWorkoutEditState createState() => _PostWorkoutEditState();
}

class _PostWorkoutEditState extends State<PostWorkoutEditPage> {
  List<Widget> nums = [
    for (int i = 50; i < 700; i++) ListTile(title: Text(i.toString())),
  ];
  List<Widget> decs = [
    for (int i = 0; i < 10; i++) ListTile(title: Text(i.toString())),
  ];

  List<int> copySetsPlanned = [];
  List<int> copyRepsPlanned = [];
  List<double> copyWeights = [];

  double postTempBodyWeight = 0;
  TextEditingController dateinput = TextEditingController();
  String originalDate = "";
  String dateChange = "";
  String sortableDateChange = "";
  late DateTime tempDate;

  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    dateinput.text = indivWorkoutsBox.getAt(widget.index)!.date.substring(5);
    dateChange = indivWorkoutsBox.getAt(widget.index)!.date;
    originalDate = indivWorkoutsBox.getAt(widget.index)!.date;
    tempDate =
        DateTime.parse(indivWorkoutsBox.getAt(widget.index)!.sortableDate);
    postTempBodyWeight = indivWorkoutsBox.getAt(widget.index)!.bodyWeight;
    // yet again roundabout way of making a copy
    for (int i = 0;
        i < indivWorkoutsBox.getAt(widget.index)!.setsPlanned.length;
        i++) {
      copySetsPlanned.add(indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]);
    }
    for (int i = 0;
        i < indivWorkoutsBox.getAt(widget.index)!.repsPlanned.length;
        i++) {
      copyRepsPlanned.add(indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]);
    }
    for (int i = 0;
        i < indivWorkoutsBox.getAt(widget.index)!.weights.length;
        i++) {
      copyWeights.add(indivWorkoutsBox.getAt(widget.index)!.weights[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // handles back button
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: globals.backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 18,
              onPressed: () => _onBackPressed()),
          backgroundColor: globals.headerColor,
          title: Center(
              child: SizedBox(
                  height: 40,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: globals.circleColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextButton(
                              child: Text(dateinput.text, // workout date
                                  style: TextStyle(
                                    color: globals.textColor,
                                    fontSize: 16,
                                  )),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    helpText: "",
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    initialDate: tempDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors
                                                .red, // header background color
                                            onPrimary: Colors
                                                .white, // header text color
                                            onSurface: globals
                                                .textColor, // body text color
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              primary: Colors
                                                  .red, // button text color
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });
                                setState(() {
                                  if (tempDate != pickedDate!) {
                                    globals.changesMade = true;
                                  }
                                  tempDate = pickedDate;
                                  dateinput.text = DateFormat('d MMM yyyy')
                                      .format(pickedDate);
                                  dateChange = DateFormat('E, d MMM yyyy')
                                      .format(pickedDate);
                                  sortableDateChange =
                                      DateFormat('yyyyMMdd').format(pickedDate);
                                });
                              }))))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: globals.redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Save"),
              onPressed: () {
                final tempIndiv = Hive.box<IndivWorkout>('indivWorkoutsBox')
                    .getAt(widget.index);

                tempIndiv!.note = globals.postWorkoutTempNote;
                tempIndiv.bodyWeight = postTempBodyWeight;

                globals.postWorkoutTempNote = "";

                if (originalDate != dateChange) {
                  tempIndiv.date = dateChange;
                  tempIndiv.sortableDate = sortableDateChange;

                  List<IndivWorkout> copyIndivs = [];
                  // again, no deep copies. workaround
                  // sorts workouts by date on date change
                  // to ensure list page is ordered by date
                  for (int i = 0; i < indivWorkoutsBox.length; i++) {
                    copyIndivs.add(indivWorkoutsBox.getAt(i)!);
                  }
                  copyIndivs.sort((a, b) {
                    return a.sortableDate.compareTo(b.sortableDate);
                  });
                  indivWorkoutsBox.deleteAll(indivWorkoutsBox.keys);
                  for (int i = 0; i < copyIndivs.length; i++) {
                    indivWorkoutsBox.add(copyIndivs[i]);
                  }
                }
                globals.changesMade = false;
                tempIndiv.save();
                var calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
                calendarProvider.updateCalendar();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  for (int i = 0;
                      i <
                          indivWorkoutsBox
                              .getAt(widget.index)!
                              .repsCompleted
                              .length;
                      i++)
                    Column(children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 15),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  indivWorkoutsBox
                                      .getAt(widget.index)!
                                      .exercisesCompleted[i],
                                  style: const TextStyle(
                                    fontSize: 17,
                                  )),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                                padding: const EdgeInsets.only(right: 15),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                        onTap: () =>
                                            _weightsSetsReps(widget.index, i),
                                        child: Row(children: <Widget>[
                                          if (indivWorkoutsBox
                                                      .getAt(widget.index)!
                                                      .weights[i] %
                                                  1 ==
                                              0)
                                            Flexible(
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                        "${indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]}×${indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]} ${indivWorkoutsBox.getAt(widget.index)!.weights[i] ~/ 1}${globals.lbKg}",
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                        ))))
                                          else
                                            Flexible(
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                        "${indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]}×${indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]} ${indivWorkoutsBox.getAt(widget.index)!.weights[i].toString()}${globals.lbKg}",
                                                        style: const TextStyle(
                                                            fontSize: 17)))),
                                          SizedBox(
                                            width: 17,
                                            child: IconButton(
                                              onPressed: () => _weightsSetsReps(
                                                  widget.index, i),
                                              alignment: Alignment.centerLeft,
                                              padding: const EdgeInsets.all(0),
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              icon: const Icon(
                                                  Icons.arrow_right_sharp),
                                              color: globals.redColor,
                                              iconSize: 20,
                                            ),
                                          ),
                                        ]))))),
                      ]),
                      Container(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                            direction: Axis.horizontal,
                            spacing: (MediaQuery.of(context).size.width - 300) /
                                4.01,
                            runSpacing: 15,
                            children: <Widget>[
                              // one circle for each set, initialized with number of reps
                              for (int j = 0;
                                  j <
                                      indivWorkoutsBox
                                          .getAt(widget.index)!
                                          .setsPlanned[i];
                                  j++)
                                // circle, onTap decrement, loops back to rep number
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MaterialButton(
                                    elevation: 0,
                                    splashColor: Colors.transparent,
                                    animationDuration:
                                        const Duration(milliseconds: 0),
                                    shape: const CircleBorder(
                                        side: BorderSide(
                                            width: 1, style: BorderStyle.none)),
                                    child: indivWorkoutsBox
                                                .getAt(widget.index)!
                                                .repsCompleted[i][j] >
                                            indivWorkoutsBox
                                                .getAt(widget.index)!
                                                .repsPlanned[i]
                                        ? indivWorkoutsBox
                                                    .getAt(widget.index)!
                                                    .repsCompleted[i][j] <
                                                10
                                            ? FittedBox(
                                                child: Text(
                                                    indivWorkoutsBox
                                                        .getAt(widget.index)!
                                                        .repsPlanned[i]
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 18)))
                                            : FittedBox(
                                                child: Text(
                                                    indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i].toString(),
                                                    style: const TextStyle(fontSize: 12)))
                                        : indivWorkoutsBox.getAt(widget.index)!.repsCompleted[i][j] < 10
                                            ? FittedBox(child: Text(indivWorkoutsBox.getAt(widget.index)!.repsCompleted[i][j].toString(), style: const TextStyle(fontSize: 18)))
                                            : FittedBox(child: Text(indivWorkoutsBox.getAt(widget.index)!.repsCompleted[i][j].toString(), style: const TextStyle(fontSize: 12))),
                                    color: indivWorkoutsBox
                                                .getAt(widget.index)!
                                                .repsCompleted[i][j] >
                                            indivWorkoutsBox
                                                .getAt(widget.index)!
                                                .repsPlanned[i]
                                        ? globals.circleColor
                                        : globals.redColor,
                                    textColor: indivWorkoutsBox
                                                .getAt(widget.index)!
                                                .repsCompleted[i][j] >
                                            indivWorkoutsBox
                                                .getAt(widget.index)!
                                                .repsPlanned[i]
                                        ? globals.emptyCircleTextColor
                                        : Colors.white,
                                    onPressed: () {
                                      globals.changesMade = true;
                                      final tempIndiv = Hive.box<IndivWorkout>(
                                              'indivWorkoutsBox')
                                          .getAt(widget.index);
                                      // loops around
                                      if (tempIndiv!.repsCompleted[i][j] == 0) {
                                        setState(() =>
                                            tempIndiv.repsCompleted[i][j] =
                                                tempIndiv.repsPlanned[i] + 1);
                                      } else {
                                        setState(() =>
                                            tempIndiv.repsCompleted[i][j] -= 1);
                                      }
                                    },
                                  ),
                                ),
                            ]),
                      ),
                      const SizedBox(height: 10),
                    ]),
                  Container(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Expanded(
                                child: Center(
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Body Weight",
                                            style: TextStyle(
                                              fontSize: 17,
                                            ))))),
                            Expanded(
                                child: Center(
                                    child: GestureDetector(
                                        onTap: () {
                                          // sets initial scroll to weight
                                          final _intController =
                                              FixedExtentScrollController(
                                                  initialItem:
                                                      postTempBodyWeight ~/ 1 -
                                                          50);
                                          // annoying floating point precision: 100.6 - 100 = 0.599
                                          // the +0.05 is a way around it
                                          final _decController =
                                              FixedExtentScrollController(
                                                  initialItem: (postTempBodyWeight -
                                                          (postTempBodyWeight ~/
                                                              1) +
                                                          0.05) *
                                                      10 ~/
                                                      1);
                                          int scrollBodyWeightInt =
                                              postTempBodyWeight ~/ 1;
                                          int scrollBodyWeightDec =
                                              (postTempBodyWeight -
                                                      (postTempBodyWeight ~/
                                                          1)) *
                                                  10 ~/
                                                  1;
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  insetPadding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            const Text("Weight",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                )),
                                                            const SizedBox(
                                                                height: 30),
                                                            Flexible(
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                  SizedBox(
                                                                      height:
                                                                          120,
                                                                      width: 70,
                                                                      child:
                                                                          CupertinoPicker(
                                                                        scrollController:
                                                                            _intController,
                                                                        children:
                                                                            nums,
                                                                        looping:
                                                                            true,
                                                                        diameterRatio:
                                                                            1.25,
                                                                        selectionOverlay:
                                                                            Column(
                                                                                children: <Widget>[
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              )))),
                                                                              const SizedBox(height: 50),
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              ))))
                                                                            ]),
                                                                        itemExtent:
                                                                            75,
                                                                        onSelectedItemChanged:
                                                                            (index) =>
                                                                                {
                                                                          scrollBodyWeightInt =
                                                                              index + 50,
                                                                        },
                                                                      )),
                                                                  const SizedBox(
                                                                      width: 5),
                                                                  const SizedBox(
                                                                    height: 45,
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topCenter,
                                                                      child: Text(
                                                                          ".",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          120,
                                                                      width: 70,
                                                                      child:
                                                                          CupertinoPicker(
                                                                        scrollController:
                                                                            _decController,
                                                                        children:
                                                                            decs,
                                                                        looping:
                                                                            true,
                                                                        diameterRatio:
                                                                            1.25,
                                                                        selectionOverlay:
                                                                            Column(
                                                                                children: <Widget>[
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              )))),
                                                                              const SizedBox(height: 50),
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                      border: Border(
                                                                                          top: BorderSide(
                                                                                color: globals.textColor,
                                                                                width: 2,
                                                                              ))))
                                                                            ]),
                                                                        itemExtent:
                                                                            75,
                                                                        onSelectedItemChanged:
                                                                            (index) =>
                                                                                {
                                                                          scrollBodyWeightDec =
                                                                              index,
                                                                        },
                                                                      )),
                                                                  const SizedBox(
                                                                      width: 5),
                                                                  SizedBox(
                                                                    height: 40,
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topCenter,
                                                                      child: Text(
                                                                          globals
                                                                              .lbKg,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                ])),
                                                            const SizedBox(
                                                                height: 30),
                                                            Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          globals
                                                                              .redColor,
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                    ),
                                                                    child: const Text(
                                                                        "Cancel"),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          20),
                                                                  TextButton(
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      primary:
                                                                          globals
                                                                              .redColor,
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                    ),
                                                                    child:
                                                                        const Text(
                                                                            "OK"),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                        () => postTempBodyWeight =
                                                                            scrollBodyWeightInt +
                                                                                0.1 * scrollBodyWeightDec,
                                                                      );
                                                                      if (postTempBodyWeight !=
                                                                          indivWorkoutsBox
                                                                              .getAt(widget.index)!
                                                                              .bodyWeight) {
                                                                        globals.changesMade =
                                                                            true;
                                                                      }
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                  ),
                                                                ]),
                                                          ]))));
                                        },
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                "${postTempBodyWeight.toString()}${globals.lbKg}",
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  color: globals.redColor,
                                                  fontWeight: FontWeight.bold,
                                                )))))),
                          ])),
                  const SizedBox(height: 50),
                ])),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                  width: double.infinity,
                  color: globals.backColor,
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          PostWorkoutNotesPage(widget.index)));
                                },
                                child: const Text("Note"),
                                style: TextButton.styleFrom(
                                  primary: globals.redColor,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  alignment: Alignment.center,
                                )),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Workout',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: globals.textColor)),
                                      content: Text(
                                          'Are you sure you want to delete this workout?',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: globals.textColor)),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: globals.redColor),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            indivWorkoutsBox
                                                .deleteAt(widget.index);
                                            var calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
                                            calendarProvider.updateCalendar();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: globals.redColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text("Delete"),
                                style: TextButton.styleFrom(
                                  primary: globals.redColor,
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  alignment: Alignment.center,
                                )),
                          ),
                        ),
                      ]))
            ]),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (globals.changesMade) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Discard Changes',
              style: TextStyle(fontSize: 20, color: globals.textColor)),
          content: Text(
              'Going back will discard all the changes you\'ve made. Are you sure you want to proceed?',
              style: TextStyle(fontSize: 15, color: globals.textColor)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: globals.redColor),
              ),
            ),
            TextButton(
              onPressed: () {
                indivWorkoutsBox.getAt(widget.index)!.repsCompleted =
                    widget.copyRepsCompleted;
                indivWorkoutsBox.getAt(widget.index)!.setsPlanned =
                    copySetsPlanned;
                indivWorkoutsBox.getAt(widget.index)!.repsPlanned =
                    copyRepsPlanned;
                indivWorkoutsBox.getAt(widget.index)!.weights = copyWeights;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Discard',
                style: TextStyle(
                  fontSize: 16,
                  color: globals.redColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
    globals.changesMade = false;
    return true;
  }

  void _weightsSetsReps(int idx, int exIdx) {
    final _myController = TextEditingController();
    final _myController2 = TextEditingController();
    final _weightsController = TextEditingController();
    _myController.text =
        indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx].toString();
    _myController2.text =
        indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx].toString();

    indivWorkoutsBox.getAt(idx)!.weights[exIdx] % 1 == 0
        ? _weightsController.text =
            indivWorkoutsBox.getAt(idx)!.weights[exIdx].toInt().toString()
        : _weightsController.text =
            indivWorkoutsBox.getAt(idx)!.weights[exIdx].toString();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text("Edit Exercise",
                    style: TextStyle(
                      fontSize: 18,
                    )),
                const Text("Changes are only for this individual workout",
                    style: TextStyle(
                      fontSize: 14,
                    )),
                const SizedBox(height: 20),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)
                  ],
                  controller: _weightsController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    labelText: "Weight",
                    labelStyle:
                        TextStyle(fontSize: 20, color: globals.textColor),
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: globals.underlineColor,
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(height: 30),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(RegExp(r'[0-99]'), allow: true)
                  ],
                  controller: _myController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    labelText: "Sets",
                    labelStyle:
                        TextStyle(fontSize: 20, color: globals.textColor),
                    contentPadding: const EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: globals.underlineColor,
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(height: 30),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
                  ],
                  controller: _myController2,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: InputDecoration(
                    labelText: "Reps",
                    labelStyle:
                        TextStyle(fontSize: 20, color: globals.textColor),
                    contentPadding: const EdgeInsets.only(bottom: 0),
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
                            int oldReps =
                                indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx];
                            int oldSets =
                                indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx];
                            if (indivWorkoutsBox.getAt(idx)!.weights[exIdx] !=
                                double.parse(_weightsController.text)) {
                              globals.changesMade = true;
                            }
                            setState(() => {
                                  indivWorkoutsBox.getAt(idx)!.weights[exIdx] =
                                      double.parse(_weightsController.text),
                                  indivWorkoutsBox
                                          .getAt(idx)!
                                          .setsPlanned[exIdx] =
                                      int.parse(_myController.text),
                                  indivWorkoutsBox
                                          .getAt(idx)!
                                          .repsPlanned[exIdx] =
                                      int.parse(_myController2.text),
                                  if (oldSets !=
                                      indivWorkoutsBox
                                          .getAt(idx)!
                                          .setsPlanned[exIdx])
                                    {
                                      globals.changesMade = true,
                                      for (int i = 0;
                                          i <
                                              indivWorkoutsBox
                                                      .getAt(idx)!
                                                      .setsPlanned[exIdx] -
                                                  oldSets;
                                          i++)
                                        {
                                          indivWorkoutsBox
                                              .getAt(idx)!
                                              .repsCompleted[exIdx]
                                              .add(indivWorkoutsBox
                                                      .getAt(idx)!
                                                      .repsPlanned[exIdx] +
                                                  1),
                                        },
                                    },
                                  if (oldReps !=
                                      indivWorkoutsBox
                                          .getAt(idx)!
                                          .repsPlanned[exIdx])
                                    {
                                      globals.changesMade = true,
                                      indivWorkoutsBox
                                          .getAt(idx)!
                                          .repsCompleted[exIdx]
                                          .clear(),
                                      for (int j = 0;
                                          j <
                                              indivWorkoutsBox
                                                  .getAt(idx)!
                                                  .setsPlanned[exIdx];
                                          ++j)
                                        {
                                          indivWorkoutsBox
                                              .getAt(idx)!
                                              .repsCompleted[exIdx]
                                              .add(indivWorkoutsBox
                                                      .getAt(idx)!
                                                      .repsPlanned[exIdx] +
                                                  1),
                                        },
                                    }
                                });
                            Navigator.of(context).pop();
                          }),
                    ]),
              ]),
        ),
      ),
    );
  }
}
