import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:shared_preferences/shared_preferences.dart';

part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await pathprovider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);

  Hive
    ..registerAdapter(ExerciseAdapter())
    ..registerAdapter(WorkoutAdapter())
    ..registerAdapter(IndivWorkoutAdapter());

  await Hive.openBox<Exercise>('exercisesBox');
  await Hive.openBox<Workout>('workoutsBox');
  await Hive.openBox<IndivWorkout>('indivWorkoutsBox');
  await Hive.openBox<double>('bodyWeightsBox');
  await Hive.openBox<String>('notesBox');

  Box<Exercise> exercisesBox = Hive.box<Exercise>('exercisesBox');

  // on first time opening app, sets to default state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? resetToDefault = prefs.getBool('resetToDefault');

/* TO UPDATE BOX VALUES: final tempWorkout =
      Hive.box<Workout>('workoutsBox')
          .getAt(widget.index);
  tempWorkout?.name =
      _myController.text;
  tempWorkout?.save(); */

  if (resetToDefault != null && !resetToDefault) {
    allExercises = exercisesBox.values.toList();
    allExercises.insert(0, customxyz);
    _setTempBodyWeight();
  } else {
    defaultState();
  }

  runApp(const MyApp());
}

// stored
// sort by date
List<Exercise> allExercises = []; // global list of exercises

String tempNote = "";
String postWorkoutTempNote = "";

double tempBodyWeight = _setTempBodyWeight();

Timer? timer;
Duration duration = const Duration();
bool showTimer = false;

var headerColor = Colors.black;
var backColor = Colors.black;
var widgetNavColor = const Color.fromARGB(133, 65, 64, 64);
var redColor = Colors.red;

int counter = 0; // going to need to store counter

ValueNotifier<int> _counter = ValueNotifier<int>(0); // to update list page

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  String name; // workout name (like "Workout A")
  @HiveField(1)
  List<Exercise> exercises = []; // List of workouts (bench, squat, curl, etc)
  @HiveField(2)
  bool isInitialized = false; // used to fill the reps completed only once

  Workout(this.name); // constructor for name
}

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  // weight, bar weight, increments, sets x reps
  @HiveField(0)
  String name;
  @HiveField(1)
  double weight = 45;
  @HiveField(2)
  double barWeight = 45;
  @HiveField(3)
  double increment = 5;
  @HiveField(4)
  int sets = 5;
  @HiveField(5)
  int reps = 5;
  @HiveField(6)
  List<int> repsCompleted = [];
  @HiveField(7)
  int failed =
      0; // EACH TIME FAILED, ADD ONE TO EXERCISE. IF EXERCISE HAS X NUMBER OF FAILURES IN A ROW, DECREASE WEIGHT
  Exercise(this.name);
}

// used for the edit page, stores all relevant single-workout data
@HiveType(typeId: 2)
class IndivWorkout extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String date;
  @HiveField(2)
  List<String> exercisesCompleted;
  @HiveField(3)
  List<double> weights;
  @HiveField(4)
  List<int> repsPlanned;
  @HiveField(5)
  List<int> setsPlanned;
  @HiveField(6)
  List<List<int>> repsCompleted;

  IndivWorkout(this.name, this.date, this.exercisesCompleted, this.weights,
      this.repsPlanned, this.setsPlanned, this.repsCompleted);
}

Exercise customxyz = Exercise("Custom Exercise");

void defaultState() async {
  allExercises.clear();
  showTimer = false;

  Workout defaultA = Workout("BlockLifts A");
  Workout defaultB = Workout("BlockLifts B");
  Exercise squat = Exercise("Squat");
  Exercise benchPress = Exercise("Bench Press");
  Exercise barbellRow = Exercise("Barbell Row");
  Exercise overheadPress = Exercise("Overhead Press");
  Exercise deadlift = Exercise("Deadlift");
  deadlift.sets = 1;
  deadlift.reps = 1;

  defaultA.exercises.add(squat);
  defaultB.exercises.add(squat);
  defaultA.exercises.add(benchPress);
  defaultA.exercises.add(barbellRow);
  defaultB.exercises.add(overheadPress);
  defaultB.exercises.add(deadlift);

  Box<Exercise> exercisesBox = Hive.box<Exercise>('exercisesBox');
  exercisesBox.deleteAll(exercisesBox.keys);
  exercisesBox.add(squat);
  exercisesBox.add(benchPress);
  exercisesBox.add(barbellRow);
  exercisesBox.add(overheadPress);
  exercisesBox.add(deadlift);

  Box<Workout> workoutsBox = Hive.box<Workout>('workoutsBox');
  workoutsBox.deleteAll(workoutsBox.keys);
  workoutsBox.add(defaultA);
  workoutsBox.add(defaultB);

  Box<IndivWorkout> indivWorkoutsBox =
      Hive.box<IndivWorkout>('indivWorkoutsBox');
  indivWorkoutsBox.deleteAll(indivWorkoutsBox.keys);

  Box<double> bodyWeightsBox = Hive.box<double>('bodyWeightsBox');
  bodyWeightsBox.deleteAll(bodyWeightsBox.keys);
  _setTempBodyWeight();

  Box<String> notesBox = Hive.box<String>('notesBox');
  notesBox.deleteAll(notesBox.keys);

  allExercises = exercisesBox.values.toList();
  allExercises.insert(0, customxyz);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('resetToDefault', false);
}

double _setTempBodyWeight() {
  Box<double> bodyWeightsBox = Hive.box<double>('bodyWeightsBox');
  bodyWeightsBox.isEmpty
      ? tempBodyWeight = 150
      : tempBodyWeight = bodyWeightsBox.getAt(bodyWeightsBox.length - 1)!;
  return tempBodyWeight;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlockLifts',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.white.withOpacity(.5),
          cursorColor: Colors.white.withOpacity(.5),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
  // creating State Object of MyWidget
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
  // creating State Object of MyWidget
}

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);
  @override
  _HistoryState createState() => _HistoryState();
  // creating State Object of MyWidget
}

class Progress extends StatefulWidget {
  const Progress({Key? key}) : super(key: key);
  @override
  _ProgressState createState() => _ProgressState();
  // creating State Object of MyWidget
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
  // creating State Object of MyWidget
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);
  @override
  _ListState createState() => _ListState();
  // creating State Object of MyWidget
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  _CalendarState createState() => _CalendarState();
  // creating State Object of MyWidget
}

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);
  @override
  _NotesState createState() => _NotesState();
  // creating State Object of MyWidget
}

class WorkoutNotesPage extends StatefulWidget {
  const WorkoutNotesPage({Key? key}) : super(key: key);
  @override
  _WorkoutNotesState createState() => _WorkoutNotesState();
  // creating State Object of MyWidget
}

class PostWorkoutNotesPage extends StatefulWidget {
  final int index;
  const PostWorkoutNotesPage(this.index, {Key? key}) : super(key: key);
  @override
  _PostWorkoutNotesState createState() => _PostWorkoutNotesState();
  // creating State Object of MyWidget
}

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);
  @override
  _EditState createState() => _EditState();
  // creating State Object of MyWidget
}

class WorkoutPage extends StatefulWidget {
  final int index;
  const WorkoutPage(this.index, {Key? key}) : super(key: key);
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
  // creating State Object of MyWidget
}

class EditWorkoutPage extends StatefulWidget {
  final int index;
  const EditWorkoutPage(this.index, {Key? key}) : super(key: key);
  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
  // creating State Object of MyWidget
}

class EditExercisePage extends StatefulWidget {
  final int index;

  const EditExercisePage(this.index, {Key? key}) : super(key: key);
  @override
  _EditExercisePageState createState() => _EditExercisePageState();
  // creating State Object of MyWidget
}

class PostWorkoutEditPage extends StatefulWidget {
  final int index;
  final List<List<int>> copyRepsCompleted;

  const PostWorkoutEditPage(this.index, this.copyRepsCompleted, {Key? key})
      : super(key: key);
  @override
  _PostWorkoutEditState createState() => _PostWorkoutEditState();
  // creating State Object of MyWidget
}

class _HomePageState extends State<HomePage> {
  // home page
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = const <Widget>[
      Home(),
      History(),
      Progress(),
      Settings(),
    ];
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: widgetNavColor,
          fixedColor: redColor,
          selectedFontSize: 15,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: "History",
              icon: Icon(Icons.calendar_month),
            ),
            BottomNavigationBarItem(
              label: "Progress",
              icon: Icon(Icons.stacked_line_chart_outlined),
            ),
            BottomNavigationBarItem(
              label: "Settings",
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class _HomeState extends State<Home> {
  late final Box<Workout> workoutsBox;

  @override
  void initState() {
    super.initState();
    workoutsBox = Hive.box<Workout>('workoutsBox');
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  void addTime(Timer? timer) {
    const addSeconds = 1;
    final seconds = duration.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      duration = Duration(seconds: seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: headerColor,
          title: const Text("BlockLifts"),
          titleTextStyle: const TextStyle(fontSize: 22),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Edit"),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => const Edit()))
                    .then((value) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
            valueListenable: _counter,
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(
                  maxHeight: 690,
                ),
                child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      for (int i = counter; i < workoutsBox.length; i++)
                        buildTile(i),
                      for (int i = 0; i < counter; i++) buildTile(i),
                    ]),
              );
            }),
        floatingActionButton: SizedBox(
          width: 150,
          height: 50,
          child: OutlinedButton(
            child: const Text("Start Workout"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
              // if statement prevents excessive adding to list
              if (workoutsBox.getAt(counter)!.isInitialized == false) {
                // change from 0 to counter (index of first workout that's up)
                for (int i = 0;
                    i < workoutsBox.getAt(counter)!.exercises.length;
                    ++i) {
                  for (int j = 0;
                      j < workoutsBox.getAt(counter)!.exercises[i].sets;
                      j++) {
                    // repsCompleted initialized with initial reps value
                    workoutsBox
                        .getAt(counter)!
                        .exercises[i]
                        .repsCompleted
                        .add(workoutsBox.getAt(counter)!.exercises[i].reps + 1);
                  }
                }
                workoutsBox.getAt(counter)!.isInitialized = true;
              }
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => WorkoutPage(counter)))
                  .then((value) {
                setState(() {});
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildTile(int i) {
    return Column(children: <Widget>[
      GestureDetector(
          onTap: () {
            // if statement prevents excessive adding to list
            if (workoutsBox.getAt(i)!.isInitialized == false) {
              for (int j = 0; j < workoutsBox.getAt(i)!.exercises.length; ++j) {
                for (int k = 0;
                    k < workoutsBox.getAt(i)!.exercises[j].sets;
                    k++) {
                  // repsCompleted initialized with initial reps value
                  workoutsBox
                      .getAt(i)!
                      .exercises[j]
                      .repsCompleted
                      .add(workoutsBox.getAt(i)!.exercises[j].reps + 1);
                }
              }
              workoutsBox.getAt(i)!.isInitialized = true;
            }
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WorkoutPage(i)))
                .then((value) {
              setState(() {});
            });
          },
          child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: i == counter
                    ? Border.all(color: Colors.red)
                    : Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
                color: widgetNavColor,
              ),
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(workoutsBox.getAt(i)!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                        )),
                  ),
                  const Divider(height: 20, color: Colors.transparent),
                  Column(children: [
                    for (int j = 0;
                        j < workoutsBox.getAt(i)!.exercises.length;
                        j++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text(workoutsBox.getAt(i)!.exercises[j].name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                      )),
                            ),
                          ),
                          if (workoutsBox.getAt(i)!.exercises[j].weight % 1 ==
                              0)
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${workoutsBox.getAt(i)!.exercises[j].sets}x${workoutsBox.getAt(i)!.exercises[j].reps} ${workoutsBox.getAt(i)!.exercises[j].weight ~/ 1}lb",
                                        style: const TextStyle(
                                          fontSize: 17,
                                        ))))
                          else
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "${workoutsBox.getAt(i)!.exercises[j].sets}x${workoutsBox.getAt(i)!.exercises[j].reps} ${workoutsBox.getAt(i)!.exercises[j].weight.toString()}lb",
                                        style: const TextStyle(fontSize: 17)))),
                        ]),
                        Divider(
                            // larger divider if not at end of list
                            height:
                                j != workoutsBox.getAt(i)!.exercises.length - 1
                                    ? 25
                                    : 10,
                            color: Colors.transparent),
                      ])
                  ]),
                ],
              ))),
      const Divider(height: 5, color: Colors.transparent),
    ]);
  }
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: headerColor,
            title: const Text("History"),
            titleTextStyle: const TextStyle(fontSize: 22),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 172, 10, 10),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  text: 'List',
                ),
                Tab(
                  text: 'Calendar',
                ),
                Tab(
                  text: 'Notes',
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ListPage(),
              CalendarPage(),
              NotesPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: headerColor,
        title: const Text("Progress"),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: Container(
        alignment: Alignment.center,
        child: const Text('Here is the progress page!'),
      ),
    );
  }
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: headerColor,
        title: const Text("Settings"),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: Container(
        alignment: Alignment.center,
        child:
            const Text('Here you will be able to toggle light and dark mode'),
      ),
      floatingActionButton: SizedBox(
        width: 150,
        height: 50,
        child: OutlinedButton(
            child: const Text("Reset to Defaults"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
              setState(() {
                defaultState();
                _counter.value++;
              });
            }),
      ),
    );
  }
}

class _ListState extends State<ListPage> {
  late final Box<String> notesBox;
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    notesBox = Hive.box<String>('notesBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        body: ValueListenableBuilder(
            valueListenable: _counter,
            builder: (context, value, child) {
              return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    for (int i = indivWorkoutsBox.length - 1; i >= 0; i--)
                      Column(children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              // workaround to fill (seems to be pass-by-reference, strangely again)
                              List<List<int>> copyRepsCompleted = [];

                              for (int j = 0;
                                  j <
                                      indivWorkoutsBox
                                          .getAt(i)!
                                          .repsCompleted
                                          .length;
                                  j++) {
                                copyRepsCompleted.add([0]);
                                copyRepsCompleted[j].add(indivWorkoutsBox
                                    .getAt(i)!
                                    .repsCompleted[j][0]);
                                copyRepsCompleted[j].removeAt(0);
                                for (int k = 1;
                                    k <
                                        indivWorkoutsBox
                                            .getAt(i)!
                                            .repsCompleted[j]
                                            .length;
                                    k++) {
                                  copyRepsCompleted[j].add(indivWorkoutsBox
                                      .getAt(i)!
                                      .repsCompleted[j][k]);
                                }
                              }
                              postWorkoutTempNote = notesBox.getAt(i)!;
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => PostWorkoutEditPage(
                                          i, copyRepsCompleted)))
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            child: Flexible(
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(6),
                                      color: widgetNavColor,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Column(children: [
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                indivWorkoutsBox.getAt(i)!.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                )),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                indivWorkoutsBox.getAt(i)!.date,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                )),
                                          ),
                                        ),
                                      ]),
                                      const Divider(
                                          height: 15,
                                          color: Colors.transparent),
                                      Column(children: [
                                        for (int j = 0;
                                            j <
                                                indivWorkoutsBox
                                                    .getAt(i)!
                                                    .exercisesCompleted
                                                    .length;
                                            j++)
                                          Column(children: <Widget>[
                                            Row(children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      indivWorkoutsBox
                                                          .getAt(i)!
                                                          .exercisesCompleted[j],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 4,
                                                  child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                            for (int k = 0;
                                                                k <
                                                                    indivWorkoutsBox.getAt(i)!.setsPlanned[
                                                                        j];
                                                                k++)
                                                              if (k == 5 &&
                                                                  indivWorkoutsBox.getAt(i)!.weights[j] %
                                                                          1 ==
                                                                      0)
                                                                Text(
                                                                    "... ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ))
                                                              else if (k == 5 &&
                                                                  indivWorkoutsBox.getAt(i)!.weights[j] %
                                                                          1 !=
                                                                      0)
                                                                Text(
                                                                    "... ${indivWorkoutsBox.getAt(i)!.weights[j]}lb",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ))
                                                              else if (k > 5)
                                                                const SizedBox(
                                                                    width: 0)
                                                              else if (k == indivWorkoutsBox.getAt(i)!.setsPlanned[j] - 1 &&
                                                                  indivWorkoutsBox.getAt(i)!.weights[j] %
                                                                          1 ==
                                                                      0)
                                                                indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
                                                                        indivWorkoutsBox.getAt(i)!.repsPlanned[j] +
                                                                            1
                                                                    ? Text(
                                                                        "0 ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ))
                                                                    : Text(
                                                                        "${indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]} ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ))
                                                              else if (k == indivWorkoutsBox.getAt(i)!.setsPlanned[j] - 1 &&
                                                                  indivWorkoutsBox.getAt(i)!.weights[j] %
                                                                          1 !=
                                                                      0)
                                                                indivWorkoutsBox
                                                                            .getAt(i)!
                                                                            .repsCompleted[j][k] ==
                                                                        indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1
                                                                    ? Text("0 ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ))
                                                                    : Text("${indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]} ${indivWorkoutsBox.getAt(i)!.weights[j] ~/ 1}lb",
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ))
                                                              else
                                                                indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] == indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1
                                                                    ? const Text("0/",
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ))
                                                                    : Text("${indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]}/",
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ))
                                                          ])))
                                            ]),
                                            Divider(
                                                // larger divider if not at end of list
                                                height: j !=
                                                        indivWorkoutsBox
                                                                .getAt(i)!
                                                                .exercisesCompleted
                                                                .length -
                                                            1
                                                    ? 15
                                                    : 0,
                                                color: Colors.transparent),
                                          ])
                                      ]),
                                    ])))),
                        const Divider(height: 5, color: Colors.transparent),
                      ])
                  ]);
            }));
  }
}

class _CalendarState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      body: Container(
        alignment: Alignment.center,
        child: const Text('Here is the calendar page'),
      ),
    );
  }
}

class _NotesState extends State<NotesPage> {
  late final Box<String> notesBox;
  late final Box<IndivWorkout> indivWorkoutsBox;

  @override
  void initState() {
    super.initState();
    notesBox = Hive.box<String>('notesBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        body: ValueListenableBuilder(
            valueListenable: _counter,
            builder: (context, value, child) {
              return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    for (int i = indivWorkoutsBox.length - 1; i >= 0; i--)
                      if (notesBox.getAt(i) != "") // doesn't show empty notes
                        Column(children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                // workaround to fill (seems to be pass-by-reference, strangely again)
                                List<List<int>> copyRepsCompleted = [];

                                for (int j = 0;
                                    j <
                                        indivWorkoutsBox
                                            .getAt(i)!
                                            .repsCompleted
                                            .length;
                                    j++) {
                                  copyRepsCompleted.add([0]);
                                  copyRepsCompleted[j].add(indivWorkoutsBox
                                      .getAt(i)!
                                      .repsCompleted[j][0]);
                                  copyRepsCompleted[j].removeAt(0);
                                  for (int k = 1;
                                      k <
                                          indivWorkoutsBox
                                              .getAt(i)!
                                              .repsCompleted[j]
                                              .length;
                                      k++) {
                                    copyRepsCompleted[j].add(indivWorkoutsBox
                                        .getAt(i)!
                                        .repsCompleted[j][k]);
                                  }
                                }
                                postWorkoutTempNote = notesBox.getAt(i)!;
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            PostWorkoutEditPage(
                                                i, copyRepsCompleted)))
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                              child: Flexible(
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(6),
                                        color: widgetNavColor,
                                      ),
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        children: [
                                          Row(children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    indivWorkoutsBox
                                                        .getAt(i)!
                                                        .name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    indivWorkoutsBox
                                                        .getAt(i)!
                                                        .date,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    )),
                                              ),
                                            ),
                                          ]),
                                          const Divider(
                                              height: 15,
                                              color: Colors.transparent),
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(notesBox.getAt(i)!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ))),
                                        ],
                                      )))),
                          const Divider(height: 5, color: Colors.transparent),
                        ])
                  ]);
            }));
  }
}

class _WorkoutNotesState extends State<WorkoutNotesPage> {
  final _myController = TextEditingController();

  @override
  void initState() {
    _myController.text = tempNote; //default text
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: const Text("Note"),
          titleTextStyle: const TextStyle(fontSize: 22),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              autofocus: true,
              maxLines: null,
              cursorColor: Colors.white,
              showCursor: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                fontSize: 18,
              ),
              focusNode: FocusNode(),
              controller: _myController,
              onChanged: (val) {
                tempNote = _myController.text;
              },
            )));
  }
}

class _PostWorkoutNotesState extends State<PostWorkoutNotesPage> {
  final _myController = TextEditingController();

  @override
  void initState() {
    _myController.text = postWorkoutTempNote; //default text
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          title: const Text("Note"),
          titleTextStyle: const TextStyle(fontSize: 22),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              autofocus: true,
              maxLines: null,
              cursorColor: Colors.white,
              showCursor: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                fontSize: 18,
              ),
              focusNode: FocusNode(),
              controller: _myController,
              onChanged: (val) {
                postWorkoutTempNote = _myController.text;
              },
            )));
  }
}

class _EditState extends State<Edit> {
  final _myController = TextEditingController();
  late final Box<Workout> workoutsBox;

  @override
  void initState() {
    super.initState();
    workoutsBox = Hive.box<Workout>('workoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: const Text("Program"),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: Container(
        constraints: const BoxConstraints(
          maxHeight: 750,
        ),
        child: Column(children: <Widget>[
          Flexible(
            child: ReorderableListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              // for every item of the List<Workout> class, display the reorder indicator
              // the name, the exercises, and three dots on the right
              scrollDirection: Axis.vertical,
              buildDefaultDragHandles: false,
              children: <Widget>[
                for (int index = 0; index < workoutsBox.length; index++)
                  GestureDetector(
                    key: Key('$index'),
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 80,
                        ),
                        color: Colors.black, // custom color goes here
                        child: Row(children: <Widget>[
                          Container(
                            width: 70,
                            padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                            child: ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_indicator_outlined),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                              width: 280,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      workoutsBox.getAt(index)!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                      softWrap: false,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Prints out names of each exercise in the workout
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(children: [
                                        for (int i = 0;
                                            i <
                                                workoutsBox
                                                    .getAt(index)!
                                                    .exercises
                                                    .length;
                                            i++)
                                          // If not last exercise, print comma after
                                          if (i !=
                                              workoutsBox
                                                      .getAt(index)!
                                                      .exercises
                                                      .length -
                                                  1)
                                            Text(
                                              "${workoutsBox.getAt(index)!.exercises[i].name}, ",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            )
                                          else
                                            Text(
                                              workoutsBox
                                                  .getAt(index)!
                                                  .exercises[i]
                                                  .name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                      ])),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (dynamic value) {
                              // edits
                              if (value == 'edit') {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            EditWorkoutPage(index)))
                                    .then((value) {
                                  setState(() {});
                                });
                              }
                              // deletes
                              else if (value == 'delete') {
                                setState(() {
                                  workoutsBox.deleteAt(index);
                                });
                              }
                            },
                            itemBuilder: (BuildContext bc) {
                              return const [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  value: 'delete',
                                ),
                              ];
                            },
                          ),
                        ])),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => EditWorkoutPage(index)))
                          .then((value) {
                        setState(() {});
                      });
                    },
                  ),
              ],
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  final List<Workout> tempList = workoutsBox.values.toList();

                  final oldItem = tempList[oldIndex];
                  final newItem = tempList[newIndex];

                  tempList[oldIndex] = newItem;
                  tempList[newIndex] = oldItem;

                  // interesting dynamic with Box. Traditional putAt
                  // method doesn't work. need to completely refill
                  workoutsBox.deleteAll(workoutsBox.keys);
                  for (var i in tempList) {
                    workoutsBox.add(i);
                  }
                });
              },
            ),
          ),
          if (workoutsBox.isNotEmpty)
            SizedBox(
              height: 55,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    alignment: const Alignment(-.42, 0)),
                child: const Text("Delete All Workouts"),
                onPressed: () {
                  setState(() {
                    counter = 0;
                    workoutsBox.deleteAll(workoutsBox.keys);
                    workoutsBox.clear();
                  });
                },
              ),
            ),
        ]),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(.93, 1), // custom alignment
        child: SizedBox(
          width: 150,
          height: 50,
          child: OutlinedButton(
            child: const Text("Add Workout"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
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
                                const Text("Workout Name",
                                    style: TextStyle(
                                      fontSize: 18,
                                    )),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _myController,
                                  autofocus: true,
                                  keyboardType: TextInputType.text,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                Divider(
                                  color: Colors.white.withOpacity(.7),
                                  height: 2,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 30),
                                Row(children: <Widget>[
                                  const SizedBox(width: 187.4),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: redColor,
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
                                        primary: redColor,
                                        textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        alignment: Alignment.center,
                                      ),
                                      child: const Text("OK"),
                                      onPressed: () {
                                        workoutsBox
                                            .add(Workout(_myController.text));
                                        _myController.text = "";
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    EditWorkoutPage(
                                                        workoutsBox.length -
                                                            1)))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      }),
                                ]),
                              ]))));
            },
          ),
        ),
      ),
    );
  }
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Widget> nums = [
    for (int i = 50; i < 700; i++) ListTile(title: Text(i.toString())),
  ];
  List<Widget> decs = [
    for (int i = 0; i < 10; i++) ListTile(title: Text(i.toString())),
  ];

  late final Box<Workout> workoutsBox;
  late final Box<IndivWorkout> indivWorkoutsBox;
  late final Box<double> bodyWeightsBox;
  late final Box<String> notesBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    bodyWeightsBox = Hive.box<double>('bodyWeightsBox');
    notesBox = Hive.box<String>('notesBox');
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  @override
  Widget build(BuildContext context) {
    Box<Workout> workoutsBox = Hive.box<Workout>('workoutsBox');
    Workout? selectVal = workoutsBox.getAt(0);
    return Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: headerColor,
          /*title: Center(
              child: SizedBox(
                  height: 40,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 41, 41, 41),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 10),
                          child: DropdownButton(
                            underline: const SizedBox(),
                            isExpanded: false,
                            items: workoutsBox.map((Workout workout) {
                              return DropdownMenuItem<Workout>(
                                  value: workout, child: Text(workout.name));
                            }).toList(),
                            value: selectVal,
                            selectedItemBuilder: (context) {
                              return [
                                SizedBox(
                                    width: 200,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          workoutsBox[widget.index].name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                              ];
                            },
                            onChanged: (Workout? w) {
                              setState(() {
                                // index of selection
                                selectVal = w;
                                int idx = workoutsBox.indexOf(selectVal!);
                                // do nothing if same selection
                                if (idx == widget.index) {
                                } else {
                                  for (int j = 0;
                                      j < workoutsBox[idx].exercises.length;
                                      ++j) {
                                    workoutsBox[idx]
                                        .exercises[j]
                                        .repsCompleted
                                        .clear();
                                    for (int k = 0;
                                        k < workoutsBox[idx].exercises[j].sets;
                                        k++) {
                                      // repsCompleted initialized with initial reps value
                                      workoutsBox[idx]
                                          .exercises[j]
                                          .repsCompleted
                                          .add(workoutsBox[idx]
                                                  .exercises[j]
                                                  .reps +
                                              1);
                                    }
                                  }
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => WorkoutPage(idx)));
                                }
                              });
                            },
                          ))))),*/
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Finish"),
              onPressed: () {
                widget.index == workoutsBox.length - 1
                    ? counter = 0
                    : counter = widget.index +
                        1; // loops counter according to selected workout
                showTimer = false;
                timer?.cancel();

                String name = workoutsBox.getAt(widget.index)!.name;
                var now = DateTime.now();
                String date = DateFormat('E, d MMM yyyy').format(now);
                List<String> exercisesCompleted = [];
                List<double> weights = [];
                List<int> repsPlanned = [];
                List<int> setsPlanned = [];
                List<List<int>> repsCompleted = [];
                for (int i = 0;
                    i < workoutsBox.getAt(widget.index)!.exercises.length;
                    i++) {
                  exercisesCompleted
                      .add(workoutsBox.getAt(widget.index)!.exercises[i].name);
                  weights.add(
                      workoutsBox.getAt(widget.index)!.exercises[i].weight);
                  repsPlanned
                      .add(workoutsBox.getAt(widget.index)!.exercises[i].reps);
                  setsPlanned
                      .add(workoutsBox.getAt(widget.index)!.exercises[i].sets);

                  // extremely weird error (appeared to be pass-by-reference
                  // with the repsCompleted, despite that not being possible)
                  // this is the roundabout solution I found
                  repsCompleted.add([0]);
                  repsCompleted[i].add(workoutsBox
                      .getAt(widget.index)!
                      .exercises[i]
                      .repsCompleted[0]);
                  repsCompleted[i].removeAt(0);
                  for (int j = 1;
                      j <
                          workoutsBox
                              .getAt(widget.index)!
                              .exercises[i]
                              .repsCompleted
                              .length;
                      j++) {
                    repsCompleted[i].add(workoutsBox
                        .getAt(widget.index)!
                        .exercises[i]
                        .repsCompleted[j]);
                  }

                  workoutsBox
                      .getAt(widget.index)!
                      .exercises[i]
                      .repsCompleted
                      .clear();
                }

                indivWorkoutsBox.add(IndivWorkout(
                    name,
                    date,
                    exercisesCompleted,
                    weights,
                    repsPlanned,
                    setsPlanned,
                    repsCompleted));

                notesBox.add(tempNote);
                tempNote = ""; // clears note for next workout

                bodyWeightsBox.add(tempBodyWeight);

                _counter.value++;

                // probably won't work, need to use hive box method
                for (int i = 0; i < workoutsBox.length; i++) {
                  workoutsBox.getAt(i)!.isInitialized = false;

                  for (int j = 0;
                      j < workoutsBox.getAt(i)!.exercises.length;
                      j++) {
                    workoutsBox.getAt(i)!.exercises[j].repsCompleted.clear();
                  }
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(
              maxHeight: 700,
            ),
            child: Column(children: <Widget>[
              Flexible(
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                    for (int i = 0;
                        i < workoutsBox.getAt(widget.index)!.exercises.length;
                        i++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "  ${workoutsBox.getAt(widget.index)!.exercises[i].name}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                  )),
                            ),
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        for (int j = 0;
                                            j < allExercises.length;
                                            j++) {
                                          if (allExercises[j].name ==
                                              workoutsBox
                                                  .getAt(widget.index)!
                                                  .exercises[i]
                                                  .name) {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditExercisePage(j)))
                                                .then((value) {
                                              setState(() {});
                                            });
                                          }
                                        }
                                      },
                                      child: Row(children: <Widget>[
                                        if (workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[i]
                                                    .weight %
                                                1 ==
                                            0)
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${workoutsBox.getAt(widget.index)!.exercises[i].sets}x${workoutsBox.getAt(widget.index)!.exercises[i].reps} ${workoutsBox.getAt(widget.index)!.exercises[i].weight ~/ 1}lb",
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      ))))
                                        else
                                          Expanded(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${workoutsBox.getAt(widget.index)!.exercises[i].sets}x${workoutsBox.getAt(widget.index)!.exercises[i].reps} ${workoutsBox.getAt(widget.index)!.exercises[i].weight.toString()}lb",
                                                      style: const TextStyle(
                                                          fontSize: 17)))),
                                        SizedBox(
                                          width: 17,
                                          child: IconButton(
                                            onPressed: () {
                                              for (int j = 0;
                                                  j < allExercises.length;
                                                  j++) {
                                                if (allExercises[j].name ==
                                                    workoutsBox
                                                        .getAt(widget.index)!
                                                        .exercises[i]
                                                        .name) {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditExercisePage(
                                                                  j)))
                                                      .then((value) {
                                                    setState(() {});
                                                  });
                                                }
                                              }
                                            },
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.all(0),
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: const Icon(
                                                Icons.arrow_right_sharp),
                                            color: redColor,
                                            iconSize: 20,
                                          ),
                                        ),
                                      ])))),
                        ]),
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  // one circle for each set, initialized with number of reps
                                  for (int j = 0;
                                      j <
                                          workoutsBox
                                              .getAt(widget.index)!
                                              .exercises[i]
                                              .sets;
                                      j++)
                                    // circle, onTap decrement, loops back to rep number
                                    SizedBox(
                                      width: 82,
                                      height: 50,
                                      child: MaterialButton(
                                        shape: const CircleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                style: BorderStyle.none)),
                                        child: workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[i]
                                                    .repsCompleted[j] >
                                                workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[i]
                                                    .reps
                                            ? Text(workoutsBox
                                                .getAt(widget.index)!
                                                .exercises[i]
                                                .reps
                                                .toString())
                                            : Text(workoutsBox
                                                .getAt(widget.index)!
                                                .exercises[i]
                                                .repsCompleted[j]
                                                .toString()),
                                        color: workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[i]
                                                    .repsCompleted[j] >
                                                workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[i]
                                                    .reps
                                            ? const Color.fromARGB(
                                                255, 41, 41, 41)
                                            : Colors.red,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          // loops around
                                          if (workoutsBox
                                                  .getAt(widget.index)!
                                                  .exercises[i]
                                                  .repsCompleted[j] ==
                                              0) {
                                            setState(() {
                                              showTimer = false;
                                              workoutsBox
                                                      .getAt(widget.index)!
                                                      .exercises[i]
                                                      .repsCompleted[j] =
                                                  workoutsBox
                                                          .getAt(widget.index)!
                                                          .exercises[i]
                                                          .reps +
                                                      1;
                                            });
                                          } else {
                                            // starts timer
                                            setState(() {
                                              showTimer = true;
                                              startTimer(timer);
                                              workoutsBox
                                                  .getAt(widget.index)!
                                                  .exercises[i]
                                                  .repsCompleted[j] -= 1;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                ]),
                              ]),
                        ),
                        const SizedBox(height: 10),
                      ]),
                  ])),
              Container(
                  padding: const EdgeInsets.all(20),
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
                                                  tempBodyWeight ~/ 1 - 50);
                                      // annoying floating point precision: 100.6 - 100 = 0.599
                                      // the +0.05 is a way around it
                                      final _decController =
                                          FixedExtentScrollController(
                                              initialItem: (tempBodyWeight -
                                                      (tempBodyWeight ~/ 1) +
                                                      0.05) *
                                                  10 ~/
                                                  1);
                                      int scrollBodyWeightInt =
                                          tempBodyWeight ~/ 1;
                                      int scrollBodyWeightDec =
                                          (tempBodyWeight -
                                                  (tempBodyWeight ~/ 1)) *
                                              10 ~/
                                              1;
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text("Weight",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                            )),
                                                        const SizedBox(
                                                            height: 30),
                                                        Flexible(
                                                            child:
                                                                Row(children: <
                                                                    Widget>[
                                                          const SizedBox(
                                                              width: 100),
                                                          SizedBox(
                                                              height: 120,
                                                              width: 70,
                                                              child:
                                                                  CupertinoPicker(
                                                                scrollController:
                                                                    _intController,
                                                                children: nums,
                                                                looping: true,
                                                                diameterRatio:
                                                                    1.25,
                                                                selectionOverlay:
                                                                    Column(children: <
                                                                        Widget>[
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  )))),
                                                                  const SizedBox(
                                                                      height:
                                                                          50),
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  ))))
                                                                ]),
                                                                itemExtent: 75,
                                                                onSelectedItemChanged:
                                                                    (index) => {
                                                                  scrollBodyWeightInt =
                                                                      index +
                                                                          50,
                                                                },
                                                              )),
                                                          const SizedBox(
                                                            width: 20,
                                                            height: 45,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Text(".",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  )),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: 120,
                                                              width: 70,
                                                              child:
                                                                  CupertinoPicker(
                                                                scrollController:
                                                                    _decController,
                                                                children: decs,
                                                                looping: true,
                                                                diameterRatio:
                                                                    1.25,
                                                                selectionOverlay:
                                                                    Column(children: <
                                                                        Widget>[
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  )))),
                                                                  const SizedBox(
                                                                      height:
                                                                          50),
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  ))))
                                                                ]),
                                                                itemExtent: 75,
                                                                onSelectedItemChanged:
                                                                    (index) => {
                                                                  scrollBodyWeightDec =
                                                                      index,
                                                                },
                                                              )),
                                                          const SizedBox(
                                                            width: 20,
                                                            height: 40,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Text("lb",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  )),
                                                            ),
                                                          ),
                                                        ])),
                                                        const SizedBox(
                                                            height: 30),
                                                        Row(children: <Widget>[
                                                          const SizedBox(
                                                              width: 187.4),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "Cancel"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              setState(
                                                                () => tempBodyWeight =
                                                                    scrollBodyWeightInt +
                                                                        0.1 *
                                                                            scrollBodyWeightDec,
                                                              );
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
                                            "${tempBodyWeight.toString()}lb",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: redColor,
                                              fontWeight: FontWeight.bold,
                                            )))))),
                      ])),
            ])),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          showTimer
              ? Container(
                  width: double.infinity,
                  height: 100,
                  padding: const EdgeInsets.only(left: 25),
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          height: 80,
                          width: double.infinity,
                          child: Row(children: <Widget>[
                            Flexible(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                  buildTime(),
                                ])),
                            Flexible(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("Rest please"),
                                    IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () =>
                                            setState(() => showTimer = false)),
                                  ]),
                            ),
                          ]),
                          decoration: BoxDecoration(
                            color: widgetNavColor,
                          ))))
              : Container(),
          Container(
              padding: const EdgeInsets.only(left: 25),
              child: Row(children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const WorkoutNotesPage()));
                        },
                        child: const Text("Note"),
                        style: TextButton.styleFrom(
                          primary: redColor,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          alignment: Alignment.bottomCenter,
                        )),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      EditWorkoutPage(widget.index)))
                              .then((value) {
                            setState(() {});
                          });
                        },
                        child: const Text("Edit"),
                        style: TextButton.styleFrom(
                          primary: redColor,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          alignment: Alignment.bottomCenter,
                        )),
                  ),
                ),
              ])),
        ]));
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(minutes, 20),
      const SizedBox(
          width: 4,
          child: Text(":",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ))),
      buildTimeCard(seconds, 5),
    ]);
  }

  void startTimer(Timer? timer) {
    timer?.cancel();
    duration = const Duration(seconds: 0);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => {addTime(timer)});
  }

  // the time is incremented in _homeState
  // however, this is used for setState, so the time actually updates and shows
  void addTime(Timer? timer) {
    const addSeconds = 0;
    if (!mounted) return;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  Widget buildTimeCard(String time, double inset) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: inset),
        child: Text(
          time,
          style: const TextStyle(color: Colors.white, fontSize: 30),
        ),
      );
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final _myController = TextEditingController();
  late final Box<Exercise> exercisesBox;
  late final Box<Workout> workoutsBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: Text(workoutsBox.getAt(widget.index)!.name),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: Container(
        constraints: const BoxConstraints(
          maxHeight: 750,
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ReorderableListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                // for every item of the List<Workout> class, display the reorder indicator
                // the name, the exercises, and three dots on the right
                scrollDirection: Axis.vertical,
                buildDefaultDragHandles: false,
                children: <Widget>[
                  for (int i = 0;
                      i < workoutsBox.getAt(widget.index)!.exercises.length;
                      i++)
                    Container(
                      key: Key('$i'),
                      color: Colors.black, // custom color goes here
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            height: 80,
                            child: ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_indicator_outlined),
                            ),
                          ),
                          GestureDetector(
                            child: SizedBox(
                              width: 280,
                              height: 60,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        workoutsBox
                                            .getAt(widget.index)!
                                            .exercises[i]
                                            .name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Prints out names of each exercise in the workout
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${workoutsBox.getAt(widget.index)!.exercises[i].sets.toString()} sets of ${workoutsBox.getAt(widget.index)!.exercises[i].reps.toString()} reps",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            softWrap: false,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              for (int j = 0; j < allExercises.length; j++) {
                                if (allExercises[j].name ==
                                    workoutsBox
                                        .getAt(widget.index)!
                                        .exercises[i]
                                        .name) {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              EditExercisePage(j)))
                                      .then((value) {
                                    setState(() {});
                                  });
                                }
                              }
                            },
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (dynamic value) {
                              // edits
                              if (value == 'edit') {
                                for (int j = 0; j < allExercises.length; j++) {
                                  if (allExercises[j].name ==
                                      workoutsBox
                                          .getAt(widget.index)!
                                          .exercises[i]
                                          .name) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                EditExercisePage(j)))
                                        .then((value) {
                                      setState(() {});
                                    });
                                  }
                                }
                              }
                              // deletes
                              else if (value == 'delete') {
                                setState(() {
                                  final tempWorkout =
                                      Hive.box<Workout>('workoutsBox')
                                          .getAt(widget.index);
                                  tempWorkout?.exercises.removeAt(i);
                                  tempWorkout?.save();
                                });
                              } else if (value == 'deleteAll') {
                                setState(() {
                                  for (int k = 0;
                                      k < allExercises.length;
                                      k++) {
                                    if (allExercises[k].name ==
                                        workoutsBox
                                            .getAt(widget.index)!
                                            .exercises[i]
                                            .name) {
                                      exercisesBox.deleteAt(k - 1);
                                      allExercises.removeAt(k);
                                    }
                                  }
                                  for (int j = 0; j < workoutsBox.length; j++) {
                                    if (workoutsBox.getAt(j)! ==
                                        workoutsBox.getAt(widget.index)!) {
                                    } else {
                                      for (int k = 0;
                                          k <
                                              workoutsBox
                                                  .getAt(j)!
                                                  .exercises
                                                  .length;
                                          k++) {
                                        if (workoutsBox
                                                .getAt(j)!
                                                .exercises[k]
                                                .name ==
                                            workoutsBox
                                                .getAt(widget.index)!
                                                .exercises[i]
                                                .name) {
                                          final tempWorkout =
                                              Hive.box<Workout>('workoutsBox')
                                                  .getAt(j);
                                          tempWorkout?.exercises.removeAt(i);
                                          tempWorkout?.save();
                                        }
                                      }
                                    }
                                  }
                                  final tempWorkout =
                                      Hive.box<Workout>('workoutsBox')
                                          .getAt(widget.index);
                                  tempWorkout?.exercises.removeAt(i);
                                  tempWorkout?.save();
                                });
                              }
                            },
                            itemBuilder: (BuildContext bc) {
                              return const [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  value: 'delete',
                                ),
                                PopupMenuItem(
                                  child: Text("Delete From All Workouts"),
                                  value: 'deleteAll',
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                ],
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex = newIndex - 1;
                    }
                    final tempWorkout =
                        Hive.box<Workout>('workoutsBox').getAt(widget.index);

                    final element = tempWorkout?.exercises.removeAt(oldIndex);
                    tempWorkout!.exercises.insert(newIndex, element!);
                    tempWorkout.save();
                  });
                },
              ),
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    alignment: const Alignment(-.32, 0)),
                child: const Text("Change Workout Name"),
                onPressed: () {
                  setState(() => _myController.text =
                      workoutsBox.getAt(widget.index)!.name);
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
                                    const Text("Workout Name",
                                        style: TextStyle(
                                          fontSize: 18,
                                        )),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _myController,
                                      autofocus: true,
                                      keyboardType: TextInputType.text,
                                      textAlignVertical:
                                          TextAlignVertical.bottom,
                                      decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(bottom: 10),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.white.withOpacity(.7),
                                      height: 2,
                                      thickness: 2,
                                    ),
                                    const SizedBox(height: 40),
                                    Row(children: <Widget>[
                                      const SizedBox(width: 187.4),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: redColor,
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
                                          primary: redColor,
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          alignment: Alignment.center,
                                        ),
                                        child: const Text("OK"),
                                        onPressed: () {
                                          setState(() {
                                            final tempWorkout =
                                                Hive.box<Workout>('workoutsBox')
                                                    .getAt(widget.index);
                                            tempWorkout?.name =
                                                _myController.text;
                                            tempWorkout?.save();
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ]),
                                  ]),
                            ),
                          ));
                },
              ),
            ),
            if (workoutsBox.getAt(widget.index)!.exercises.isNotEmpty)
              SizedBox(
                height: 55,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      alignment: const Alignment(-.42, 0)),
                  child: const Text("Delete All Exercises"),
                  onPressed: () {
                    // add confirmation "would you like to delete all exercises?""
                    setState(() {
                      final tempWorkout =
                          Hive.box<Workout>('workoutsBox').getAt(widget.index);
                      tempWorkout?.exercises.clear();
                      tempWorkout?.save();
                      workoutsBox.getAt(widget.index)!.exercises.clear();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(.93, 1), // custom alignment
        child: SizedBox(
          width: 150,
          height: 50,
          child: OutlinedButton(
            child: const Text("Add Exercise"),
            style: OutlinedButton.styleFrom(
              primary: Colors.white,
              backgroundColor: redColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
            ),
            onPressed: () {
              Exercise? selectVal = customxyz;
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
                          const Text("Add Exercise",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const SizedBox(height: 10),

                          // dropdown list with "custom" at top
                          DropdownButton(
                              isExpanded: true,
                              items: allExercises.map((Exercise exercise) {
                                return DropdownMenuItem<Exercise>(
                                    value: exercise,
                                    child: Text(exercise.name));
                              }).toList(),
                              value: selectVal,
                              selectedItemBuilder: (context) {
                                return [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(selectVal!.name))
                                ];
                              },
                              onChanged: (Exercise? e) {
                                setState(() => selectVal = e);
                              }),
                          const SizedBox(height: 30),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
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
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("OK"),
                              onPressed: () {
                                _myController.text = "";
                                setState(() {
                                  if (selectVal == customxyz) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                            insetPadding:
                                                const EdgeInsets.all(10),
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      const Text(
                                                          "Exercise Name",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      TextField(
                                                        controller:
                                                            _myController,
                                                        autofocus: true,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .bottom,
                                                        decoration:
                                                            const InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  bottom: 10),
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                      Divider(
                                                        color: Colors.white
                                                            .withOpacity(.7),
                                                        height: 2,
                                                        thickness: 2,
                                                      ),
                                                      const SizedBox(
                                                          height: 30),
                                                      Row(children: <Widget>[
                                                        const SizedBox(
                                                            width: 187.4),
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            primary: redColor,
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                          child: const Text(
                                                              "Cancel"),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            width: 20),
                                                        TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              bool duplicate =
                                                                  false;
                                                              // check that it's not in all exercises and it's not in current workout
                                                              for (int i = 0;
                                                                  i <
                                                                      allExercises
                                                                          .length;
                                                                  i++) {
                                                                if (_myController
                                                                        .text ==
                                                                    allExercises[
                                                                            i]
                                                                        .name) {
                                                                  duplicate =
                                                                      true;
                                                                }
                                                              }
                                                              for (int i = 0;
                                                                  i <
                                                                      workoutsBox
                                                                          .getAt(
                                                                              widget.index)!
                                                                          .exercises
                                                                          .length;
                                                                  i++) {
                                                                if (_myController
                                                                        .text ==
                                                                    workoutsBox
                                                                        .getAt(widget
                                                                            .index)!
                                                                        .exercises[
                                                                            i]
                                                                        .name) {
                                                                  duplicate =
                                                                      true;
                                                                }
                                                              }
                                                              if (duplicate ==
                                                                  false) {
                                                                // Adds to Hive local storage
                                                                exercisesBox.add(
                                                                    Exercise(
                                                                        _myController
                                                                            .text));

                                                                allExercises.add(
                                                                    Exercise(
                                                                        _myController
                                                                            .text));

                                                                final tempWorkout = Hive.box<
                                                                            Workout>(
                                                                        'workoutsBox')
                                                                    .getAt(widget
                                                                        .index);
                                                                tempWorkout
                                                                    ?.exercises
                                                                    .add(allExercises[
                                                                        allExercises.length -
                                                                            1]);
                                                                tempWorkout
                                                                    ?.save();

                                                                /*workoutsBox[widget
                                                                        .index]
                                                                    .exercises
                                                                    .add(allExercises[
                                                                        allExercises.length -
                                                                            1]);*/

                                                                if (workoutsBox
                                                                        .getAt(widget
                                                                            .index)!
                                                                        .isInitialized ==
                                                                    false) {
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .exercises
                                                                              .length;
                                                                      ++j) {
                                                                    for (int k =
                                                                            0;
                                                                        k < workoutsBox.getAt(widget.index)!.exercises[j].sets;
                                                                        k++) {
                                                                      // repsCompleted initialized with initial reps value
                                                                      workoutsBox
                                                                          .getAt(widget
                                                                              .index)!
                                                                          .exercises[
                                                                              j]
                                                                          .repsCompleted
                                                                          .add(workoutsBox.getAt(widget.index)!.exercises[j].reps +
                                                                              1);
                                                                    }
                                                                  }
                                                                  workoutsBox
                                                                      .getAt(widget
                                                                          .index)!
                                                                      .isInitialized = true;
                                                                } else {
                                                                  // adds to repsCompleted, initializes it
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1]
                                                                              .sets;
                                                                      j++) {
                                                                    workoutsBox
                                                                        .getAt(widget
                                                                            .index)!
                                                                        .exercises[
                                                                            workoutsBox.getAt(widget.index)!.exercises.length -
                                                                                1]
                                                                        .repsCompleted
                                                                        .add(workoutsBox.getAt(widget.index)!.exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1].reps +
                                                                            1);
                                                                  }
                                                                  setState(() =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop());
                                                                }
                                                                _myController
                                                                    .text = "";
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            EditExercisePage(allExercises.length -
                                                                                1)))
                                                                    .then(
                                                                        (value) {
                                                                  setState(
                                                                      () {});
                                                                });
                                                              } else if (duplicate ==
                                                                  true) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          "Exercise already exists or is in current workout"),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              2)),
                                                                );
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }),
                                                      ]),
                                                    ]))));
                                  } else {
                                    bool duplicate = false;
                                    for (int i = 0;
                                        i <
                                            workoutsBox
                                                .getAt(widget.index)!
                                                .exercises
                                                .length;
                                        i++) {
                                      if (workoutsBox
                                              .getAt(widget.index)!
                                              .exercises[i]
                                              .name ==
                                          selectVal!.name) {
                                        duplicate = true;
                                      }
                                    }
                                    if (duplicate == true) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Exercise already in workout"),
                                              duration: Duration(seconds: 2)));
                                    } else {
                                      final tempWorkout =
                                          Hive.box<Workout>('workoutsBox')
                                              .getAt(widget.index);
                                      tempWorkout?.exercises.add(selectVal!);

                                      tempWorkout?.save();

                                      /*workoutsBox[widget.index]
                                          .exercises
                                          .add(selectVal!);*/

                                      if (workoutsBox
                                              .getAt(widget.index)!
                                              .isInitialized ==
                                          false) {
                                        for (int j = 0;
                                            j <
                                                workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises
                                                    .length;
                                            ++j) {
                                          for (int k = 0;
                                              k <
                                                  workoutsBox
                                                      .getAt(widget.index)!
                                                      .exercises[j]
                                                      .sets;
                                              k++) {
                                            // repsCompleted initialized with initial reps value
                                            workoutsBox
                                                .getAt(widget.index)!
                                                .exercises[j]
                                                .repsCompleted
                                                .add(workoutsBox
                                                        .getAt(widget.index)!
                                                        .exercises[j]
                                                        .reps +
                                                    1);
                                          }
                                        }
                                        workoutsBox
                                            .getAt(widget.index)!
                                            .isInitialized = true;
                                      } else {
                                        // adds to repsCompleted, initializes it
                                        for (int j = 0;
                                            j <
                                                workoutsBox
                                                    .getAt(widget.index)!
                                                    .exercises[workoutsBox
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises
                                                            .length -
                                                        1]
                                                    .sets;
                                            j++) {
                                          workoutsBox
                                              .getAt(widget.index)!
                                              .exercises[workoutsBox
                                                      .getAt(widget.index)!
                                                      .exercises
                                                      .length -
                                                  1]
                                              .repsCompleted
                                              .add(workoutsBox
                                                      .getAt(widget.index)!
                                                      .exercises[workoutsBox
                                                              .getAt(
                                                                  widget.index)!
                                                              .exercises
                                                              .length -
                                                          1]
                                                      .reps +
                                                  1);
                                        }
                                        setState(
                                            () => Navigator.of(context).pop());
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                          ]),
                        ]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditExercisePageState extends State<EditExercisePage> {
  final _myController = TextEditingController();
  final _myController2 = TextEditingController();

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: headerColor,
        title: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                allExercises[widget.index].name,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            // displays no decimal points if it's not a decimal (casts to int)
            if (allExercises[widget.index].weight % 1 == 0 &&
                ((allExercises[widget.index].weight -
                                allExercises[widget.index].barWeight) /
                            2) %
                        1 ==
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allExercises[widget.index].weight.toInt().toString()}lb (${(((allExercises[widget.index].weight) - allExercises[widget.index].barWeight) ~/ 2)}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            if (allExercises[widget.index].weight % 1 == 0 &&
                ((allExercises[widget.index].weight -
                                allExercises[widget.index].barWeight) /
                            2) %
                        1 !=
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allExercises[widget.index].weight.toInt().toString()}lb (${(((allExercises[widget.index].weight) - allExercises[widget.index].barWeight) / 2).toString()}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            // if there are decimals
            if (allExercises[widget.index].weight % 1 != 0 &&
                ((allExercises[widget.index].weight -
                                allExercises[widget.index].barWeight) /
                            2) %
                        1 ==
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allExercises[widget.index].weight.toString()}lb (${(((allExercises[widget.index].weight) - allExercises[widget.index].barWeight) ~/ 2)}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            if (allExercises[widget.index].weight % 1 != 0 &&
                ((allExercises[widget.index].weight -
                                allExercises[widget.index].barWeight) /
                            2) %
                        2 !=
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allExercises[widget.index].weight.toString()}lb (${((allExercises[widget.index].weight - allExercises[widget.index].barWeight) / 2).toString()}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: Column(children: <Widget>[
        GestureDetector(
            onTap: () {
              if (allExercises[widget.index].weight % 1 == 0) {
                setState(() => _myController.text =
                    allExercises[widget.index].weight.toInt().toString());
              }
              if (allExercises[widget.index].weight % 1 != 0) {
                setState(() => _myController.text =
                    allExercises[widget.index].weight.toString());
              }
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
                          const Text("Exercise Weight",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const Text("Includes weight of bar",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          const SizedBox(height: 10),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-9.]'),
                                  allow: true)
                            ],
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
                            color: Colors.white.withOpacity(.7),
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 170,
                                height: 50,
                                child: OutlinedButton(
                                  child: const Text("-5lb"),
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // subtracts 5lb from text box
                                    if (allExercises[widget.index].weight % 1 ==
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toInt().toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    } else if (allExercises[widget.index]
                                                .weight %
                                            1 !=
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 170,
                                  height: 50,
                                  child: OutlinedButton(
                                      child: const Text("+5lb"),
                                      style: OutlinedButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                      ),
                                      onPressed: () {
                                        // adds 5lb to text box
                                        if (allExercises[widget.index].weight %
                                                1 ==
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toInt().toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                        if (allExercises[widget.index].weight %
                                                1 !=
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                      }))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
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
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("OK"),
                              onPressed: () {
                                setState(() => allExercises[widget.index]
                                    .weight = double.parse(_myController.text));
                                Navigator.of(context).pop();
                              },
                            ),
                          ]),
                        ]),
                  ),
                ),
              );
            },
            child: Container(
                color: Colors.black,
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment(-.88, 0),
                        child: Text(
                          "Exercise Weight",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      // if no decimals needed
                      if (allExercises[widget.index].weight % 1 == 0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allExercises[widget.index].weight.toInt().toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (allExercises[widget.index].weight % 1 != 0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allExercises[widget.index].weight.toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ]))),
        // bar weight
        GestureDetector(
            onTap: () {
              if (allExercises[widget.index].barWeight % 1 == 0) {
                setState(() => _myController.text =
                    allExercises[widget.index].barWeight.toInt().toString());
              }
              if (allExercises[widget.index].barWeight % 1 != 0) {
                setState(() => _myController.text =
                    allExercises[widget.index].barWeight.toString());
              }
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
                          const Text("Bar Weight",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const Text("Weight of the bar (LB)",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          const SizedBox(height: 10),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-9.]'),
                                  allow: true)
                            ],
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
                            color: Colors.white.withOpacity(.7),
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 170,
                                height: 50,
                                child: OutlinedButton(
                                  child: const Text("-5lb"),
                                  style: OutlinedButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                  ),
                                  onPressed: () {
                                    // subtracts 5lb from text box
                                    if (allExercises[widget.index].barWeight %
                                            1 ==
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toInt().toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    } else if (allExercises[widget.index]
                                                .barWeight %
                                            1 !=
                                        0) {
                                      setState(() {
                                        double tempText =
                                            double.parse(_myController.text);
                                        if (tempText <= 5) {
                                          _myController.text = "0";
                                        } else {
                                          tempText -= 5;
                                          _myController.text =
                                              tempText.toString();
                                        }
                                        _myController.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _myController.text.length);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 170,
                                  height: 50,
                                  child: OutlinedButton(
                                      child: const Text("+5lb"),
                                      style: OutlinedButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.black,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                      ),
                                      onPressed: () {
                                        // adds 5lb to text box
                                        if (allExercises[widget.index]
                                                    .barWeight %
                                                1 ==
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toInt().toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                        if (allExercises[widget.index]
                                                    .barWeight %
                                                1 !=
                                            0) {
                                          setState(() {
                                            double tempText = double.parse(
                                                _myController.text);
                                            tempText += 5;
                                            _myController.text =
                                                tempText.toString();
                                            _myController.selection =
                                                TextSelection.collapsed(
                                                    offset: _myController
                                                        .text.length);
                                          });
                                        }
                                      }))
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
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
                                primary: redColor,
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                alignment: Alignment.center,
                              ),
                              child: const Text("OK"),
                              onPressed: () {
                                setState(() =>
                                    allExercises[widget.index].barWeight =
                                        double.parse(_myController.text));
                                Navigator.of(context).pop();
                              },
                            ),
                          ]),
                        ]),
                  ),
                ),
              );
            },
            child: Container(
                color: Colors.black,
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment(-.88, 0),
                        child: Text(
                          "Bar Weight",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      // if no decimals needed
                      if (allExercises[widget.index].barWeight % 1 == 0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allExercises[widget.index].barWeight.toInt().toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (allExercises[widget.index].barWeight % 1 != 0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allExercises[widget.index].barWeight.toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ]))),
        // sets x reps
        GestureDetector(
            onTap: () {
              setState(() => _myController.text =
                  allExercises[widget.index].sets.toString());
              setState(() => _myController2.text =
                  allExercises[widget.index].reps.toString());

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
                          const Text("Sets x Reps",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          const Text(
                              "Number of sets and reps for this exercise",
                              style: TextStyle(
                                fontSize: 14,
                              )),
                          const SizedBox(height: 20),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-99]'),
                                  allow: true)
                            ],
                            controller: _myController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: const InputDecoration(
                              labelText: "Sets",
                              labelStyle:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              contentPadding: EdgeInsets.only(bottom: 0),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.7),
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                  allow: true)
                            ],
                            controller: _myController2,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: const InputDecoration(
                              labelText: "Reps",
                              labelStyle:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              contentPadding: EdgeInsets.only(bottom: 0),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(.7),
                            height: 2,
                            thickness: 2,
                          ),
                          const SizedBox(height: 20),
                          Row(children: <Widget>[
                            const SizedBox(width: 187.4),
                            TextButton(
                              style: TextButton.styleFrom(
                                primary: redColor,
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
                                  primary: redColor,
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  alignment: Alignment.center,
                                ),
                                child: const Text("OK"),
                                onPressed: () {
                                  int oldReps = allExercises[widget.index].reps;
                                  int oldSets = allExercises[widget.index].sets;
                                  setState(() => {
                                        allExercises[widget.index].sets =
                                            int.parse(_myController.text),
                                        allExercises[widget.index].reps =
                                            int.parse(_myController2.text),
                                        if (oldSets !=
                                            allExercises[widget.index].sets)
                                          {
                                            for (int i = 0;
                                                i <
                                                    allExercises[widget.index]
                                                            .sets -
                                                        oldSets;
                                                i++)
                                              {
                                                allExercises[widget.index]
                                                    .repsCompleted
                                                    .add(allExercises[
                                                                widget.index]
                                                            .reps +
                                                        1)
                                              },
                                          },
                                        if (oldReps !=
                                            allExercises[widget.index].reps)
                                          {
                                            allExercises[widget.index]
                                                .repsCompleted
                                                .clear(),
                                            for (int j = 0;
                                                j <
                                                    allExercises[widget.index]
                                                        .sets;
                                                ++j)
                                              {
                                                allExercises[widget.index]
                                                    .repsCompleted
                                                    .add(allExercises[
                                                                widget.index]
                                                            .reps +
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
            },
            child: Container(
                color: Colors.black,
                height: 80,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment(-.88, 0),
                        child: Text(
                          "Sets x Reps",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-.91, 0),
                        child: Text(
                          "${allExercises[widget.index].sets.toString()}x${allExercises[widget.index].reps.toString()}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]))),
        const SizedBox(height: 5),
        SizedBox(
          height: 55,
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
                alignment: const Alignment(-.9, 0)),
            child: const Text("Change Exercise Name"),
            onPressed: () {
              setState(
                  () => _myController.text = allExercises[widget.index].name);
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
                                const Text("Exercise Name",
                                    style: TextStyle(
                                      fontSize: 18,
                                    )),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _myController,
                                  autofocus: true,
                                  keyboardType: TextInputType.text,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(bottom: 10),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                Divider(
                                  color: Colors.white.withOpacity(.7),
                                  height: 2,
                                  thickness: 2,
                                ),
                                const SizedBox(height: 40),
                                Row(children: <Widget>[
                                  const SizedBox(width: 187.4),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: redColor,
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
                                      primary: redColor,
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      alignment: Alignment.center,
                                    ),
                                    child: const Text("OK"),
                                    onPressed: () {
                                      setState(() {
                                        /*final tempEx =
                                          Hive.box<Exercise>('exercisesBox')
                                            .getAt(widget.index);
                                        tempEx.name = _myController.text;
                                        tempEx.save();*/

                                        allExercises[widget.index].name =
                                            _myController.text;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ]),
                              ]),
                        ),
                      ));
            },
          ),
        ),
      ]),
    );
  }
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
  String dateChange = "";

  late final Box<IndivWorkout> indivWorkoutsBox;
  late final Box<double> bodyWeightsBox;
  late final Box<String> notesBox;

  @override
  void initState() {
    super.initState();
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    bodyWeightsBox = Hive.box<double>('bodyWeightsBox');
    notesBox = Hive.box<String>('notesBox');
    dateinput.text = indivWorkoutsBox.getAt(widget.index)!.date.substring(5);
    dateChange = indivWorkoutsBox.getAt(widget.index)!.date;
    postTempBodyWeight = bodyWeightsBox.getAt(widget.index)!;
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
    for (int i = 0; i < indivWorkoutsBox.getAt(widget.index)!.weights.length; i++) {
      copyWeights.add(indivWorkoutsBox.getAt(widget.index)!.weights[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // handles back button
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: backColor,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 18,
              onPressed: () => _onBackPressed()),
          backgroundColor: headerColor,
          title: Center(
              child: SizedBox(
                  height: 40,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 41, 41, 41),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextButton(
                              child: Text(dateinput.text, // workout date
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  )),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime
                                        .now(), // change to date of workout
                                    firstDate: DateTime(
                                        2000), // change to date of first workout
                                    lastDate: DateTime.now());

                                setState(() {
                                  dateinput.text = DateFormat('d MMM yyyy')
                                      .format(pickedDate!);
                                  dateChange = DateFormat('E, d MMM yyyy')
                                      .format(pickedDate);
                                });
                              }))))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: redColor,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                alignment: Alignment.center,
              ),
              child: const Text("Save"),
              onPressed: () {
                /*String name = workoutsBox[widget.index].name;
              String date = "date";
              List<String> exercisesCompleted = [];
              List<double> weights = [];
              List<int> repsPlanned = [];
              List<int> setsPlanned = [];
              List<List<int>> repsCompleted = [];
              for (int i = 0;
                  i < workoutsBox[widget.index].exercises.length;
                  i++) {}
              */
                // save any weight, rep, set, name changes
                // don't need to save reps because going back reverts it
                // only change body weight on save

                bodyWeightsBox.putAt(widget.index, postTempBodyWeight);

                notesBox.putAt(widget.index, postWorkoutTempNote);

                postWorkoutTempNote = "";
                indivWorkoutsBox.getAt(widget.index)!.date = dateChange;

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Container(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(
              maxHeight: 750,
            ),
            child: Column(children: <Widget>[
              Flexible(
                  child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                    for (int i = 0;
                        i < indivWorkoutsBox.getAt(widget.index)!.repsCompleted.length;
                        i++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "  ${indivWorkoutsBox.getAt(widget.index)!.exercisesCompleted[i]}",
                                  style: const TextStyle(
                                    fontSize: 17,
                                  )),
                            ),
                          ),
                          Expanded(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                      onTap: () =>
                                          _weightsSetsReps(widget.index, i),
                                      child: Row(children: <Widget>[
                                        if (indivWorkoutsBox.getAt(widget.index)!
                                                    .weights[i] %
                                                1 ==
                                            0)
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${indivWorkoutsBox.getAt(widget.index)!.
                                                        setsPlanned[i]}x${indivWorkoutsBox.getAt(widget.index)!.
                                                        repsPlanned[i]} ${indivWorkoutsBox.getAt(widget.index)!.
                                                        weights[i] ~/ 1}lb",
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      ))))
                                        else
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${indivWorkoutsBox.getAt(widget.index)!.setsPlanned[i]}x${
                                                        indivWorkoutsBox.getAt(widget.index)!.repsPlanned[i]} ${
                                                          indivWorkoutsBox.getAt(widget.index)!.weights[i].toString()}lb",
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
                                            highlightColor: Colors.transparent,
                                            icon: const Icon(
                                                Icons.arrow_right_sharp),
                                            color: redColor,
                                            iconSize: 20,
                                          ),
                                        ),
                                      ])))),
                        ]),
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  // one circle for each set, initialized with number of reps
                                  for (int j = 0;
                                      j <
                                          indivWorkoutsBox.getAt(widget.index)!
                                              .setsPlanned[i];
                                      j++)
                                    // circle, onTap decrement, loops back to rep number
                                    SizedBox(
                                      width: 82,
                                      height: 50,
                                      child: MaterialButton(
                                        shape: const CircleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                style: BorderStyle.none)),
                                        child: indivWorkoutsBox.getAt(widget.index)!
                                                    .repsCompleted[i][j] >
                                                indivWorkoutsBox.getAt(widget.index)!
                                                    .repsPlanned[i]
                                            ? Text(
                                                indivWorkoutsBox.getAt(widget.index)!
                                                    .repsPlanned[i]
                                                    .toString())
                                            : Text(
                                                indivWorkoutsBox.getAt(widget.index)!
                                                    .repsCompleted[i][j]
                                                    .toString()),
                                        color: indivWorkoutsBox.getAt(widget.index)!
                                                    .repsCompleted[i][j] >
                                                indivWorkoutsBox.getAt(widget.index)!
                                                    .repsPlanned[i]
                                            ? const Color.fromARGB(
                                                255, 41, 41, 41)
                                            : Colors.red,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          // loops around
                                          if (indivWorkoutsBox.getAt(widget.index)!
                                                  .repsCompleted[i][j] ==
                                              0) {
                                            setState(() => indivWorkoutsBox.getAt(widget.index)!
                                                    .repsCompleted[i][j] =
                                                indivWorkoutsBox.getAt(widget.index)!
                                                        .repsPlanned[i] +
                                                    1);
                                          } else {
                                            setState(() =>
                                                indivWorkoutsBox.getAt(widget.index)!
                                                    .repsCompleted[i][j] -= 1);
                                          }
                                        },
                                      ),
                                    ),
                                ]),
                              ]),
                        ),
                        const SizedBox(height: 10),
                      ]),
                  ])),
              Container(
                  padding: const EdgeInsets.all(20),
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
                                                  postTempBodyWeight ~/ 1 - 50);
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
                                                  (postTempBodyWeight ~/ 1)) *
                                              10 ~/
                                              1;
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text("Weight",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                            )),
                                                        const SizedBox(
                                                            height: 30),
                                                        Flexible(
                                                            child:
                                                                Row(children: <
                                                                    Widget>[
                                                          const SizedBox(
                                                              width: 100),
                                                          SizedBox(
                                                              height: 120,
                                                              width: 70,
                                                              child:
                                                                  CupertinoPicker(
                                                                scrollController:
                                                                    _intController,
                                                                children: nums,
                                                                looping: true,
                                                                diameterRatio:
                                                                    1.25,
                                                                selectionOverlay:
                                                                    Column(children: <
                                                                        Widget>[
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  )))),
                                                                  const SizedBox(
                                                                      height:
                                                                          50),
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  ))))
                                                                ]),
                                                                itemExtent: 75,
                                                                onSelectedItemChanged:
                                                                    (index) => {
                                                                  scrollBodyWeightInt =
                                                                      index +
                                                                          50,
                                                                },
                                                              )),
                                                          const SizedBox(
                                                            width: 20,
                                                            height: 45,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Text(".",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  )),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: 120,
                                                              width: 70,
                                                              child:
                                                                  CupertinoPicker(
                                                                scrollController:
                                                                    _decController,
                                                                children: decs,
                                                                looping: true,
                                                                diameterRatio:
                                                                    1.25,
                                                                selectionOverlay:
                                                                    Column(children: <
                                                                        Widget>[
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  )))),
                                                                  const SizedBox(
                                                                      height:
                                                                          50),
                                                                  Container(
                                                                      decoration: const BoxDecoration(
                                                                          border: Border(
                                                                              top: BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  ))))
                                                                ]),
                                                                itemExtent: 75,
                                                                onSelectedItemChanged:
                                                                    (index) => {
                                                                  scrollBodyWeightDec =
                                                                      index,
                                                                },
                                                              )),
                                                          const SizedBox(
                                                            width: 20,
                                                            height: 40,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Text("lb",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  )),
                                                            ),
                                                          ),
                                                        ])),
                                                        const SizedBox(
                                                            height: 30),
                                                        Row(children: <Widget>[
                                                          const SizedBox(
                                                              width: 187.4),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "Cancel"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              primary: redColor,
                                                              textStyle: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                            ),
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              setState(
                                                                () => postTempBodyWeight =
                                                                    scrollBodyWeightInt +
                                                                        0.1 *
                                                                            scrollBodyWeightDec,
                                                              );
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
                                            "${postTempBodyWeight.toString()}lb",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: redColor,
                                              fontWeight: FontWeight.bold,
                                            )))))),
                      ])),
            ])),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Container(
            padding: const EdgeInsets.only(left: 25),
            child: Row(children: <Widget>[
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
                        primary: redColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        alignment: Alignment.bottomCenter,
                      )),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () {
                        indivWorkoutsBox.deleteAt(widget.index);
                        bodyWeightsBox.deleteAt(widget.index);
                        notesBox.deleteAt(widget.index);
                        indivWorkoutsBox.deleteAt(widget.index);
                        bodyWeightsBox.deleteAt(widget.index);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Delete"),
                      style: TextButton.styleFrom(
                        primary: redColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        alignment: Alignment.bottomCenter,
                      )),
                ),
              ),
            ])),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    // reverts to old reps completed, sets planned, reps planned, weights
    indivWorkoutsBox.getAt(widget.index)!.repsCompleted = widget.copyRepsCompleted;
    indivWorkoutsBox.getAt(widget.index)!.setsPlanned = copySetsPlanned;
    indivWorkoutsBox.getAt(widget.index)!.repsPlanned = copyRepsPlanned;
    indivWorkoutsBox.getAt(widget.index)!.weights = copyWeights;
    Navigator.of(context).pop();
    return true;
  }

  void _weightsSetsReps(int idx, int exIdx) {
    final _myController = TextEditingController();
    final _myController2 = TextEditingController();
    final _weightsController = TextEditingController();
    _myController.text = indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx].toString();
    _myController2.text = indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx].toString();

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
                  decoration: const InputDecoration(
                    labelText: "Weight",
                    labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                    contentPadding: EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(.7),
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
                  decoration: const InputDecoration(
                    labelText: "Sets",
                    labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                    contentPadding: EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(.7),
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
                  decoration: const InputDecoration(
                    labelText: "Reps",
                    labelStyle: TextStyle(fontSize: 20, color: Colors.white),
                    contentPadding: EdgeInsets.only(bottom: 0),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(.7),
                  height: 2,
                  thickness: 2,
                ),
                const SizedBox(height: 20),
                Row(children: <Widget>[
                  const SizedBox(width: 187.4),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: redColor,
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
                        primary: redColor,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        alignment: Alignment.center,
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        int oldReps = indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx];
                        int oldSets = indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx];
                        setState(() => {
                              indivWorkoutsBox.getAt(idx)!.weights[exIdx] =
                                  double.parse(_weightsController.text),
                              indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx] =
                                  int.parse(_myController.text),
                              indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx] =
                                  int.parse(_myController2.text),
                              if (oldSets !=
                                  indivWorkoutsBox.getAt(idx)!.setsPlanned[exIdx])
                                {
                                  for (int i = 0;
                                      i <
                                          indivWorkoutsBox.getAt(idx)!
                                                  .setsPlanned[exIdx] -
                                              oldSets;
                                      i++)
                                    {
                                      indivWorkoutsBox.getAt(idx)!
                                          .repsCompleted[exIdx]
                                          .add(indivWorkoutsBox.getAt(idx)!
                                                  .repsPlanned[exIdx] +
                                              1),
                                    },
                                },
                              if (oldReps !=
                                  indivWorkoutsBox.getAt(idx)!.repsPlanned[exIdx])
                                {
                                  indivWorkoutsBox.getAt(idx)!
                                      .repsCompleted[exIdx]
                                      .clear(),
                                  for (int j = 0;
                                      j <
                                          indivWorkoutsBox.getAt(idx)!
                                              .setsPlanned[exIdx];
                                      ++j)
                                    {
                                      indivWorkoutsBox.getAt(idx)!
                                          .repsCompleted[exIdx]
                                          .add(indivWorkoutsBox.getAt(idx)!
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
