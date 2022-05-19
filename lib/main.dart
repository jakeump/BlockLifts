import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

List<Workout> allWorkouts = []; // global list of workouts
List<IndivWorkout> allIndivWorkouts = []; // global list of each indiv workout
List<double> bodyWeights = []; // global list of body weight
List<String> notes = [];

String tempNote = "";
String postWorkoutTempNote = "";
double tempBodyWeight = 100.5;

// should probably be an ordered set
List<Exercise> allExercises = []; // global list of exercises

var headerColor = Colors.black;
var backColor = Colors.black;
var widgetNavColor = const Color.fromARGB(133, 65, 64, 64);
var redColor = Colors.red;
int counter = 0;

ValueNotifier<int> _counter = ValueNotifier<int>(0); // to update list page

Exercise customxyz = Exercise("Custom Exercise");
Workout defaultA = Workout("BlockLifts Default A");
Workout defaultB = Workout("BlockLifts Default B");
Exercise squat = Exercise("Squat");
Exercise benchPress = Exercise("Bench Press");
Exercise barbellRow = Exercise("Barbell Row");
Exercise overheadPress = Exercise("Overhead Press");
Exercise deadlift = Exercise("Deadlift");

class Workout {
  String name; // workout name (like "Workout A")
  List<Exercise> exercises = []; // List of workouts (bench, squat, curl, etc)
  Workout(this.name); // constructor for name

  bool isInitialized = false; // used to fill the reps completed only once

  // addWorkout function to add to the end of the list
  // public implementation so no underscore
  // not necessary, remove later
  void addWorkout(Exercise exercise) {
    exercises.add(exercise);
  }
}

class Exercise {
  // weight, bar weight, increments, sets x reps
  String name;
  double weight = 45;
  double barWeight = 45;
  double increment = 5;
  int sets = 5;
  int reps = 5;

  List<int> repsCompleted = [];

  int failed =
      0; // EACH TIME FAILED, ADD ONE TO EXERCISE. IF EXERCISE HAS X NUMBER OF FAILURES IN A ROW, DECREASE WEIGHT
  Exercise(this.name);
}

// used for the edit page, stores all relevant single-workout data
class IndivWorkout {
  String name;
  String date;
  List<String> exercisesCompleted;
  List<double> weights;
  List<int> repsPlanned;
  List<int> setsPlanned;
  List<List<int>> repsCompleted;

  IndivWorkout(this.name, this.date, this.exercisesCompleted, this.weights,
      this.repsPlanned, this.setsPlanned, this.repsCompleted);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    allExercises.clear(); // TEMPORARY, TO AVOID REFRESHING A TON
    // all temporary
    if (allWorkouts.contains(defaultA)) {
    } else {
      allExercises.add(customxyz);
      defaultA.addWorkout(squat);
      defaultA.addWorkout(benchPress);
      defaultA.addWorkout(barbellRow);
      defaultB.addWorkout(squat);
      defaultB.addWorkout(overheadPress);
      deadlift.sets = 1;
      deadlift.reps = 1;
      defaultB.addWorkout(deadlift);
      allWorkouts.add(defaultA);
      allWorkouts.add(defaultB);
      allExercises.add(squat);
      allExercises.add(benchPress);
      allExercises.add(barbellRow);
      allExercises.add(overheadPress);
      allExercises.add(deadlift);
    }
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
          fixedColor: const Color.fromARGB(255, 172, 10, 10),
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
        body: Container(
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(
            maxHeight: 690,
          ),
          child: Column(children: <Widget>[
            Flexible(
              child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    for (int i = counter; i < allWorkouts.length; i++)
                      Column(children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              if (allWorkouts[i].isInitialized == false) {
                                for (int k = 0;
                                    k < allWorkouts[i].exercises.length;
                                    ++k) {
                                  for (int j = 0;
                                      j < allWorkouts[i].exercises[k].sets;
                                      j++) {
                                    // repsCompleted initialized with initial reps value
                                    allWorkouts[i]
                                        .exercises[k]
                                        .repsCompleted
                                        .add(allWorkouts[i].exercises[k].reps +
                                            1);
                                  }
                                }
                                allWorkouts[i].isInitialized = true;
                              }
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => WorkoutPage(i)))
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            child: Flexible(
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
                                          child: Text(allWorkouts[i].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                              )),
                                        ),
                                        const Divider(
                                            height: 20,
                                            color: Colors.transparent),
                                        Column(children: [
                                          for (int j = 0;
                                              j <
                                                  allWorkouts[i]
                                                      .exercises
                                                      .length;
                                              j++)
                                            Column(children: <Widget>[
                                              Row(children: <Widget>[
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        allWorkouts[i]
                                                            .exercises[j]
                                                            .name,
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                        )),
                                                  ),
                                                ),
                                                if (allWorkouts[i]
                                                            .exercises[j]
                                                            .weight %
                                                        1 ==
                                                    0)
                                                  Flexible(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              "${allWorkouts[i].exercises[j].sets}x${allWorkouts[i].exercises[j].reps} ${allWorkouts[i].exercises[j].weight ~/ 1}lb",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 17,
                                                              ))))
                                                else
                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              "${allWorkouts[i].exercises[j].sets}x${allWorkouts[i].exercises[j].reps} ${allWorkouts[i].exercises[j].weight.toString()}lb",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          17)))),
                                              ]),
                                              Divider(
                                                  // larger divider if not at end of list
                                                  height: j !=
                                                          allWorkouts[i]
                                                                  .exercises
                                                                  .length -
                                                              1
                                                      ? 25
                                                      : 10,
                                                  color: Colors.transparent),
                                            ])
                                        ])
                                      ],
                                    )))),
                        const Divider(height: 5, color: Colors.transparent),
                      ]),
                    for (int i = 0; i < counter; i++)
                      Column(children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              // if statement prevents excessive adding to list
                              if (allWorkouts[i].isInitialized == false) {
                                for (int j = 0;
                                    j < allWorkouts[i].exercises.length;
                                    ++j) {
                                  for (int k = 0;
                                      k < allWorkouts[i].exercises[j].sets;
                                      k++) {
                                    // repsCompleted initialized with initial reps value
                                    allWorkouts[i]
                                        .exercises[j]
                                        .repsCompleted
                                        .add(allWorkouts[i].exercises[j].reps +
                                            1);
                                  }
                                }
                                allWorkouts[i].isInitialized = true;
                              }
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => WorkoutPage(i)))
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            child: Flexible(
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
                                          child: Text(allWorkouts[i].name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                              )),
                                        ),
                                        const Divider(
                                            height: 20,
                                            color: Colors.transparent),
                                        Column(children: [
                                          for (int j = 0;
                                              j <
                                                  allWorkouts[i]
                                                      .exercises
                                                      .length;
                                              j++)
                                            Column(children: <Widget>[
                                              Row(children: <Widget>[
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        allWorkouts[i]
                                                            .exercises[j]
                                                            .name,
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                        )),
                                                  ),
                                                ),
                                                if (allWorkouts[i]
                                                            .exercises[j]
                                                            .weight %
                                                        1 ==
                                                    0)
                                                  Flexible(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              "${allWorkouts[i].exercises[j].sets}x${allWorkouts[i].exercises[j].reps} ${allWorkouts[i].exercises[j].weight ~/ 1}lb",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 17,
                                                              ))))
                                                else
                                                  Expanded(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              "${allWorkouts[i].exercises[j].sets}x${allWorkouts[i].exercises[j].reps} ${allWorkouts[i].exercises[j].weight.toString()}lb",
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          17)))),
                                              ]),
                                              Divider(
                                                  // larger divider if not at end of list
                                                  height: j !=
                                                          allWorkouts[i]
                                                                  .exercises
                                                                  .length -
                                                              1
                                                      ? 25
                                                      : 10,
                                                  color: Colors.transparent),
                                            ])
                                        ]),
                                      ],
                                    )))),
                        const Divider(height: 5, color: Colors.transparent),
                      ]),
                  ]),
            ),
          ]),
        ),
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
              if (allWorkouts[counter].isInitialized == false) {
                // change from 0 to counter (index of first workout that's up)
                for (int i = 0;
                    i < allWorkouts[counter].exercises.length;
                    ++i) {
                  for (int j = 0;
                      j < allWorkouts[counter].exercises[i].sets;
                      j++) {
                    // repsCompleted initialized with initial reps value
                    allWorkouts[counter]
                        .exercises[i]
                        .repsCompleted
                        .add(allWorkouts[counter].exercises[i].reps + 1);
                  }
                }
                allWorkouts[counter].isInitialized = true;
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
    );
  }
}

class _ListState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        body: ValueListenableBuilder(
            valueListenable: _counter,
            builder: (context, value, child) {
              return ListView(
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    for (int i = allIndivWorkouts.length - 1; i >= 0; i--)
                      Column(children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              // workaround to fill (seems to be pass-by-reference, strangely again)
                              List<List<int>> copyRepsCompleted = [];

                              for (int j = 0;
                                  j < allIndivWorkouts[i].repsCompleted.length;
                                  j++) {
                                copyRepsCompleted.add([0]);
                                copyRepsCompleted[j].add(
                                    allIndivWorkouts[i].repsCompleted[j][0]);
                                copyRepsCompleted[j].removeAt(0);
                                for (int k = 1;
                                    k <
                                        allIndivWorkouts[i]
                                            .repsCompleted[j]
                                            .length;
                                    k++) {
                                  copyRepsCompleted[j].add(
                                      allIndivWorkouts[i].repsCompleted[j][k]);
                                }
                              }
                              postWorkoutTempNote = notes[i];
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
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(6),
                                      color: widgetNavColor,
                                    ),
                                    alignment: Alignment.topLeft,
                                    child: Column(children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(allIndivWorkouts[i].name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 17,
                                            )),
                                      ),
                                      const Divider(
                                          height: 20,
                                          color: Colors.transparent),
                                      Column(children: [
                                        for (int j = 0;
                                            j <
                                                allIndivWorkouts[i]
                                                    .exercisesCompleted
                                                    .length;
                                            j++)
                                          Column(children: <Widget>[
                                            Row(children: <Widget>[
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                      allIndivWorkouts[i]
                                                          .exercisesCompleted[j],
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      )),
                                                ),
                                              ),
                                              if (allIndivWorkouts[i]
                                                          .weights[j] %
                                                      1 ==
                                                  0)
                                                Flexible(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            "${allIndivWorkouts[i].setsPlanned[j]}x${allIndivWorkouts[i].repsPlanned[j]} ${allIndivWorkouts[i].weights[j] ~/ 1}lb",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 17,
                                                            ))))
                                              else
                                                Expanded(
                                                    child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                            "${allIndivWorkouts[i].setsPlanned[j]}x${allIndivWorkouts[i].repsPlanned[j]} ${allIndivWorkouts[i].weights[j].toString()}lb",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        17)))),
                                            ]),
                                            Divider(
                                                // larger divider if not at end of list
                                                height: j !=
                                                        allIndivWorkouts[i]
                                                                .exercisesCompleted
                                                                .length -
                                                            1
                                                    ? 25
                                                    : 10,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        body: ValueListenableBuilder(
            valueListenable: _counter,
            builder: (context, value, child) {
              return ListView(
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    for (int i = allIndivWorkouts.length - 1; i >= 0; i--)
                      if (notes[i] != "") // doesn't show empty notes
                        Column(children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                // workaround to fill (seems to be pass-by-reference, strangely again)
                                List<List<int>> copyRepsCompleted = [];

                                for (int j = 0;
                                    j <
                                        allIndivWorkouts[i]
                                            .repsCompleted
                                            .length;
                                    j++) {
                                  copyRepsCompleted.add([0]);
                                  copyRepsCompleted[j].add(
                                      allIndivWorkouts[i].repsCompleted[j][0]);
                                  copyRepsCompleted[j].removeAt(0);
                                  for (int k = 1;
                                      k <
                                          allIndivWorkouts[i]
                                              .repsCompleted[j]
                                              .length;
                                      k++) {
                                    copyRepsCompleted[j].add(allIndivWorkouts[i]
                                        .repsCompleted[j][k]);
                                  }
                                }
                                postWorkoutTempNote = notes[i];
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
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(6),
                                        color: widgetNavColor,
                                      ),
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                                allIndivWorkouts[i].name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                )),
                                          ),
                                          const Divider(
                                              height: 20,
                                              color: Colors.transparent),
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(notes[i],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ))),
                                          const SizedBox(height: 5),
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
        child: Column(
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // for every item of the List<Workout> class, display the reorder indicator
                  // the name, the exercises, and three dots on the right
                  scrollDirection: Axis.vertical,
                  buildDefaultDragHandles: false,
                  children: <Widget>[
                    for (int index = 0; index < allWorkouts.length; index++)
                      Container(
                        key: Key('$index'),
                        color: Colors.black, // custom color goes here
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 70,
                              height: 100,
                              padding: const EdgeInsets.all(8),
                              child: ReorderableDragStartListener(
                                index: index,
                                child:
                                    const Icon(Icons.drag_indicator_outlined),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                                width: 280,
                                height: 100,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          allWorkouts[index].name,
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
                                                    allWorkouts[index]
                                                        .exercises
                                                        .length;
                                                i++)
                                              // If not last exercise, print comma after
                                              if (i !=
                                                  allWorkouts[index]
                                                          .exercises
                                                          .length -
                                                      1)
                                                Text(
                                                  "${allWorkouts[index].exercises[i].name}, ",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                )
                                              else
                                                Text(
                                                  allWorkouts[index]
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
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            EditWorkoutPage(index)))
                                    .then((value) {
                                  setState(() {});
                                });
                              },
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
                                  setState(() => allWorkouts.removeAt(index));
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
                          ],
                        ),
                      ),
                  ],
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex = newIndex - 1;
                      }
                      final element = allWorkouts.removeAt(oldIndex);
                      allWorkouts.insert(newIndex, element);
                    });
                  },
                ),
              ),
            ),
            if (allWorkouts.isNotEmpty)
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
                    setState(() => allWorkouts.clear());
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
                                        allWorkouts
                                            .add(Workout(_myController.text));
                                        _myController.text = "";
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    EditWorkoutPage(
                                                        allWorkouts.length -
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

  @override
  Widget build(BuildContext context) {
    Workout? selectVal = allWorkouts[0];
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                        padding: const EdgeInsets.only(left: 15, right: 10),
                        child: DropdownButton(
                          underline: const SizedBox(),
                          isExpanded: false,
                          items: allWorkouts.map((Workout workout) {
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
                                    child: Text(allWorkouts[widget.index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                            ];
                          },
                          onChanged: (Workout? w) {
                            setState(() {
                              // index of selection
                              selectVal = w;
                              int idx = allWorkouts.indexOf(selectVal!);
                              // do nothing if same selection
                              if (idx == widget.index) {
                              } else {
                                for (int j = 0;
                                    j < allWorkouts[idx].exercises.length;
                                    ++j) {
                                  allWorkouts[idx]
                                      .exercises[j]
                                      .repsCompleted
                                      .clear();
                                  for (int k = 0;
                                      k < allWorkouts[idx].exercises[j].sets;
                                      k++) {
                                    // repsCompleted initialized with initial reps value
                                    allWorkouts[idx]
                                        .exercises[j]
                                        .repsCompleted
                                        .add(
                                            allWorkouts[idx].exercises[j].reps +
                                                1);
                                  }
                                }
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => WorkoutPage(idx)));
                              }
                            });
                          },
                        ))))),
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
              widget.index == allWorkouts.length - 1
                  ? counter = 0
                  : counter = widget.index +
                      1; // loops counter according to selected workout

              String name = allWorkouts[widget.index].name;
              String date = "date";
              List<String> exercisesCompleted = [];
              List<double> weights = [];
              List<int> repsPlanned = [];
              List<int> setsPlanned = [];
              List<List<int>> repsCompleted = [];
              for (int i = 0;
                  i < allWorkouts[widget.index].exercises.length;
                  i++) {
                exercisesCompleted
                    .add(allWorkouts[widget.index].exercises[i].name);
                weights.add(allWorkouts[widget.index].exercises[i].weight);
                repsPlanned.add(allWorkouts[widget.index].exercises[i].reps);
                setsPlanned.add(allWorkouts[widget.index].exercises[i].sets);

                // extremely weird error (appeared to be pass-by-reference
                // with the repsCompleted, despite that not being possible)
                // this is the roundabout solution I found
                repsCompleted.add([0]);
                repsCompleted[i].add(
                    allWorkouts[widget.index].exercises[i].repsCompleted[0]);
                repsCompleted[i].removeAt(0);
                for (int j = 1;
                    j <
                        allWorkouts[widget.index]
                            .exercises[i]
                            .repsCompleted
                            .length;
                    j++) {
                  repsCompleted[i].add(
                      allWorkouts[widget.index].exercises[i].repsCompleted[j]);
                }

                allWorkouts[widget.index].exercises[i].repsCompleted.clear();
              }

              allIndivWorkouts.add(IndivWorkout(name, date, exercisesCompleted,
                  weights, repsPlanned, setsPlanned, repsCompleted));

              notes.add(tempNote);
              tempNote = ""; // clears note for next workout

              bodyWeights.add(tempBodyWeight);

              _counter.value++;

              for (int i = 0; i < allWorkouts.length; i++) {
                allWorkouts[i].isInitialized = false;

                for (int j = 0; j < allWorkouts[i].exercises.length; j++) {
                  allWorkouts[i].exercises[j].repsCompleted.clear();
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
            maxHeight: 750,
          ),
          child: Column(children: <Widget>[
            Flexible(
                child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                  for (int i = 0;
                      i < allWorkouts[widget.index].exercises.length;
                      i++)
                    Column(children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "  ${allWorkouts[widget.index].exercises[i].name}",
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
                                            allWorkouts[widget.index]
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
                                      if (allWorkouts[widget.index]
                                                  .exercises[i]
                                                  .weight %
                                              1 ==
                                          0)
                                        Flexible(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    "${allWorkouts[widget.index].exercises[i].sets}x${allWorkouts[widget.index].exercises[i].reps} ${allWorkouts[widget.index].exercises[i].weight ~/ 1}lb",
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                    ))))
                                      else
                                        Expanded(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                    "${allWorkouts[widget.index].exercises[i].sets}x${allWorkouts[widget.index].exercises[i].reps} ${allWorkouts[widget.index].exercises[i].weight.toString()}lb",
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
                                                  allWorkouts[widget.index]
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
                                        allWorkouts[widget.index]
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
                                      child: allWorkouts[widget.index]
                                                  .exercises[i]
                                                  .repsCompleted[j] >
                                              allWorkouts[widget.index]
                                                  .exercises[i]
                                                  .reps
                                          ? Text(allWorkouts[widget.index]
                                              .exercises[i]
                                              .reps
                                              .toString())
                                          : Text(allWorkouts[widget.index]
                                              .exercises[i]
                                              .repsCompleted[j]
                                              .toString()),
                                      color: allWorkouts[widget.index]
                                                  .exercises[i]
                                                  .repsCompleted[j] >
                                              allWorkouts[widget.index]
                                                  .exercises[i]
                                                  .reps
                                          ? const Color.fromARGB(
                                              255, 41, 41, 41)
                                          : Colors.red,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // loops around
                                        if (allWorkouts[widget.index]
                                                .exercises[i]
                                                .repsCompleted[j] ==
                                            0) {
                                          setState(() =>
                                              allWorkouts[widget.index]
                                                      .exercises[i]
                                                      .repsCompleted[j] =
                                                  allWorkouts[widget.index]
                                                          .exercises[i]
                                                          .reps +
                                                      1);
                                        } else {
                                          setState(() =>
                                              allWorkouts[widget.index]
                                                  .exercises[i]
                                                  .repsCompleted[j] -= 1);
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
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                        Widget>[
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
                                        initialItem: tempBodyWeight ~/ 1 - 50);
                                // annoying floating point precision: 100.6 - 100 = 0.599
                                // the +0.05 is a way around it
                                final _decController =
                                    FixedExtentScrollController(
                                        initialItem: (tempBodyWeight -
                                                (tempBodyWeight ~/ 1) +
                                                0.05) *
                                            10 ~/
                                            1);
                                int scrollBodyWeightInt = tempBodyWeight ~/ 1;
                                int scrollBodyWeightDec =
                                    (tempBodyWeight - (tempBodyWeight ~/ 1)) *
                                        10 ~/
                                        1;
                                showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                        insetPadding: const EdgeInsets.all(10),
                                        child: Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Text("Weight",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                      )),
                                                  const SizedBox(height: 30),
                                                  Flexible(
                                                      child: Row(children: <
                                                          Widget>[
                                                    const SizedBox(width: 100),
                                                    SizedBox(
                                                        height: 120,
                                                        width: 70,
                                                        child: CupertinoPicker(
                                                          scrollController:
                                                              _intController,
                                                          children: nums,
                                                          looping: true,
                                                          diameterRatio: 1.25,
                                                          selectionOverlay:
                                                              Column(children: <
                                                                  Widget>[
                                                            Container(
                                                                decoration: const BoxDecoration(
                                                                    border: Border(
                                                                        top: BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 2,
                                                            )))),
                                                            const SizedBox(
                                                                height: 50),
                                                            Container(
                                                                decoration: const BoxDecoration(
                                                                    border: Border(
                                                                        top: BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 2,
                                                            ))))
                                                          ]),
                                                          itemExtent: 75,
                                                          onSelectedItemChanged:
                                                              (index) => {
                                                            scrollBodyWeightInt =
                                                                index + 50,
                                                          },
                                                        )),
                                                    const SizedBox(
                                                      width: 20,
                                                      height: 45,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Text(".",
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                            )),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: 120,
                                                        width: 70,
                                                        child: CupertinoPicker(
                                                          scrollController:
                                                              _decController,
                                                          children: decs,
                                                          looping: true,
                                                          diameterRatio: 1.25,
                                                          selectionOverlay:
                                                              Column(children: <
                                                                  Widget>[
                                                            Container(
                                                                decoration: const BoxDecoration(
                                                                    border: Border(
                                                                        top: BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 2,
                                                            )))),
                                                            const SizedBox(
                                                                height: 50),
                                                            Container(
                                                                decoration: const BoxDecoration(
                                                                    border: Border(
                                                                        top: BorderSide(
                                                              color:
                                                                  Colors.white,
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
                                                            Alignment.topCenter,
                                                        child: Text("lb",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                    ),
                                                  ])),
                                                  const SizedBox(height: 30),
                                                  Row(children: <Widget>[
                                                    const SizedBox(
                                                        width: 187.4),
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        primary: redColor,
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                      child:
                                                          const Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    const SizedBox(width: 20),
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        primary: redColor,
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        setState(
                                                          () => tempBodyWeight =
                                                              scrollBodyWeightInt +
                                                                  0.1 *
                                                                      scrollBodyWeightDec,
                                                        );
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ]),
                                                ]))));
                              },
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text("${tempBodyWeight.toString()}lb",
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
                          builder: (context) => const WorkoutNotesPage()));
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
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      alignment: Alignment.bottomCenter,
                    )),
              ),
            ),
          ])),
    );
  }
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final _myController = TextEditingController();

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
        title: Text(allWorkouts[widget.index].name),
        titleTextStyle: const TextStyle(fontSize: 22),
      ),
      body: Container(
        constraints: const BoxConstraints(
          maxHeight: 750,
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // for every item of the List<Workout> class, display the reorder indicator
                  // the name, the exercises, and three dots on the right
                  scrollDirection: Axis.vertical,
                  buildDefaultDragHandles: false,
                  children: <Widget>[
                    for (int i = 0;
                        i < allWorkouts[widget.index].exercises.length;
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
                                child:
                                    const Icon(Icons.drag_indicator_outlined),
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
                                          allWorkouts[widget.index]
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
                                              "${allWorkouts[widget.index].exercises[i].sets.toString()} sets of ${allWorkouts[widget.index].exercises[i].reps.toString()} reps",
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
                                      allWorkouts[widget.index]
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
                                  for (int j = 0;
                                      j < allExercises.length;
                                      j++) {
                                    if (allExercises[j].name ==
                                        allWorkouts[widget.index]
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
                                  setState(() => allWorkouts[widget.index]
                                      .exercises
                                      .removeAt(i));
                                } else if (value == 'deleteAll') {
                                  setState(() {
                                    allExercises.remove(
                                        allWorkouts[widget.index].exercises[i]);
                                    for (int j = 0;
                                        j < allWorkouts.length;
                                        j++) {
                                      if (allWorkouts[j] ==
                                          allWorkouts[widget.index]) {
                                      } else if (allWorkouts[j]
                                          .exercises
                                          .contains(allWorkouts[widget.index]
                                              .exercises[i])) {
                                        allWorkouts[j].exercises.remove(
                                            allWorkouts[widget.index]
                                                .exercises[i]);
                                      }
                                    }
                                    allWorkouts[widget.index]
                                        .exercises
                                        .removeAt(i);
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
                      final element = allWorkouts[widget.index]
                          .exercises
                          .removeAt(oldIndex);
                      allWorkouts[widget.index]
                          .exercises
                          .insert(newIndex, element);
                    });
                  },
                ),
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
                  setState(() =>
                      _myController.text = allWorkouts[widget.index].name);
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
                                          setState(() =>
                                              allWorkouts[widget.index].name =
                                                  _myController.text);
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
            if (allWorkouts[widget.index].exercises.isNotEmpty)
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
                    setState(() => allWorkouts[widget.index].exercises.clear());
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
                                                                      allWorkouts[
                                                                              widget.index]
                                                                          .exercises
                                                                          .length;
                                                                  i++) {
                                                                if (_myController
                                                                        .text ==
                                                                    allWorkouts[widget
                                                                            .index]
                                                                        .exercises[
                                                                            i]
                                                                        .name) {
                                                                  duplicate =
                                                                      true;
                                                                }
                                                              }
                                                              if (duplicate ==
                                                                  false) {
                                                                allExercises.add(
                                                                    Exercise(
                                                                        _myController
                                                                            .text));
                                                                allWorkouts[widget
                                                                        .index]
                                                                    .exercises
                                                                    .add(allExercises[
                                                                        allExercises.length -
                                                                            1]);
                                                                if (allWorkouts[
                                                                            widget.index]
                                                                        .isInitialized ==
                                                                    false) {
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          allWorkouts[widget.index]
                                                                              .exercises
                                                                              .length;
                                                                      ++j) {
                                                                    for (int k =
                                                                            0;
                                                                        k < allWorkouts[widget.index].exercises[j].sets;
                                                                        k++) {
                                                                      // repsCompleted initialized with initial reps value
                                                                      allWorkouts[widget
                                                                              .index]
                                                                          .exercises[
                                                                              j]
                                                                          .repsCompleted
                                                                          .add(allWorkouts[widget.index].exercises[j].reps +
                                                                              1);
                                                                    }
                                                                  }
                                                                  allWorkouts[widget
                                                                          .index]
                                                                      .isInitialized = true;
                                                                } else {
                                                                  // adds to repsCompleted, initializes it
                                                                  for (int j =
                                                                          0;
                                                                      j <
                                                                          allWorkouts[widget.index]
                                                                              .exercises[allWorkouts[widget.index].exercises.length - 1]
                                                                              .sets;
                                                                      j++) {
                                                                    allWorkouts[widget
                                                                            .index]
                                                                        .exercises[
                                                                            allWorkouts[widget.index].exercises.length -
                                                                                1]
                                                                        .repsCompleted
                                                                        .add(allWorkouts[widget.index].exercises[allWorkouts[widget.index].exercises.length - 1].reps +
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
                                  } else if (allWorkouts[widget.index]
                                      .exercises
                                      .contains(selectVal)) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Exercise already in workout"),
                                          duration: Duration(seconds: 2)),
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    allWorkouts[widget.index]
                                        .exercises
                                        .add(selectVal!);

                                    if (allWorkouts[widget.index]
                                            .isInitialized ==
                                        false) {
                                      for (int j = 0;
                                          j <
                                              allWorkouts[widget.index]
                                                  .exercises
                                                  .length;
                                          ++j) {
                                        for (int k = 0;
                                            k <
                                                allWorkouts[widget.index]
                                                    .exercises[j]
                                                    .sets;
                                            k++) {
                                          // repsCompleted initialized with initial reps value
                                          allWorkouts[widget.index]
                                              .exercises[j]
                                              .repsCompleted
                                              .add(allWorkouts[widget.index]
                                                      .exercises[j]
                                                      .reps +
                                                  1);
                                        }
                                      }
                                      allWorkouts[widget.index].isInitialized =
                                          true;
                                    } else {
                                      // adds to repsCompleted, initializes it
                                      for (int j = 0;
                                          j <
                                              allWorkouts[widget.index]
                                                  .exercises[
                                                      allWorkouts[widget.index]
                                                              .exercises
                                                              .length -
                                                          1]
                                                  .sets;
                                          j++) {
                                        allWorkouts[widget.index]
                                            .exercises[allWorkouts[widget.index]
                                                    .exercises
                                                    .length -
                                                1]
                                            .repsCompleted
                                            .add(allWorkouts[widget.index]
                                                    .exercises[allWorkouts[
                                                                widget.index]
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
                                      setState(() => allExercises[widget.index]
                                          .name = _myController.text);
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

  @override
  void initState() {
    super.initState();
    postTempBodyWeight = bodyWeights[widget.index];
    // yet again roundabout way of making a copy
    for (int i = 0;
        i < allIndivWorkouts[widget.index].setsPlanned.length;
        i++) {
      copySetsPlanned.add(allIndivWorkouts[widget.index].setsPlanned[i]);
    }
    for (int i = 0;
        i < allIndivWorkouts[widget.index].repsPlanned.length;
        i++) {
      copyRepsPlanned.add(allIndivWorkouts[widget.index].repsPlanned[i]);
    }
    for (int i = 0; i < allIndivWorkouts[widget.index].weights.length; i++) {
      copyWeights.add(allIndivWorkouts[widget.index].weights[i]);
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
          title: Text("calendar"),
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
                /*String name = allWorkouts[widget.index].name;
              String date = "date";
              List<String> exercisesCompleted = [];
              List<double> weights = [];
              List<int> repsPlanned = [];
              List<int> setsPlanned = [];
              List<List<int>> repsCompleted = [];
              for (int i = 0;
                  i < allWorkouts[widget.index].exercises.length;
                  i++) {}
              */
                // save any weight, rep, set, name changes
                // don't need to save reps because going back reverts it
                // only change body weight on save

                bodyWeights[widget.index] = postTempBodyWeight;

                notes[widget.index] = postWorkoutTempNote;
                postWorkoutTempNote = "";

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
                        i < allIndivWorkouts[widget.index].repsCompleted.length;
                        i++)
                      Column(children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "  ${allIndivWorkouts[widget.index].exercisesCompleted[i]}",
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
                                        if (allIndivWorkouts[widget.index]
                                                    .weights[i] %
                                                1 ==
                                            0)
                                          Flexible(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${allIndivWorkouts[widget.index].setsPlanned[i]}x${allIndivWorkouts[widget.index].repsPlanned[i]} ${allIndivWorkouts[widget.index].weights[i] ~/ 1}lb",
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                      ))))
                                        else
                                          Expanded(
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "${allIndivWorkouts[widget.index].setsPlanned[i]}x${allIndivWorkouts[widget.index].repsPlanned[i]} ${allIndivWorkouts[widget.index].weights[i].toString()}lb",
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
                                          allIndivWorkouts[widget.index]
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
                                        child: allIndivWorkouts[widget.index]
                                                    .repsCompleted[i][j] >
                                                allIndivWorkouts[widget.index]
                                                    .repsPlanned[i]
                                            ? Text(
                                                allIndivWorkouts[widget.index]
                                                    .repsPlanned[i]
                                                    .toString())
                                            : Text(
                                                allIndivWorkouts[widget.index]
                                                    .repsCompleted[i][j]
                                                    .toString()),
                                        color: allIndivWorkouts[widget.index]
                                                    .repsCompleted[i][j] >
                                                allIndivWorkouts[widget.index]
                                                    .repsPlanned[i]
                                            ? const Color.fromARGB(
                                                255, 41, 41, 41)
                                            : Colors.red,
                                        textColor: Colors.white,
                                        onPressed: () {
                                          // loops around
                                          if (allIndivWorkouts[widget.index]
                                                  .repsCompleted[i][j] ==
                                              0) {
                                            setState(() => allIndivWorkouts[
                                                        widget.index]
                                                    .repsCompleted[i][j] =
                                                allIndivWorkouts[widget.index]
                                                        .repsPlanned[i] +
                                                    1);
                                          } else {
                                            setState(() =>
                                                allIndivWorkouts[widget.index]
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
                        notes.removeAt(widget.index);
                        allIndivWorkouts.removeAt(widget.index);
                        bodyWeights.removeAt(widget.index);
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
    allIndivWorkouts[widget.index].repsCompleted = widget.copyRepsCompleted;
    allIndivWorkouts[widget.index].setsPlanned = copySetsPlanned;
    allIndivWorkouts[widget.index].repsPlanned = copyRepsPlanned;
    allIndivWorkouts[widget.index].weights = copyWeights;
    Navigator.of(context).pop();
    return true;
  }

  void _weightsSetsReps(int idx, int exIdx) {
    final _myController = TextEditingController();
    final _myController2 = TextEditingController();
    final _weightsController = TextEditingController();
    _myController.text = allIndivWorkouts[idx].setsPlanned[exIdx].toString();
    _myController2.text = allIndivWorkouts[idx].repsPlanned[exIdx].toString();

    allIndivWorkouts[idx].weights[exIdx] % 1 == 0
        ? _weightsController.text =
            allIndivWorkouts[idx].weights[exIdx].toInt().toString()
        : _weightsController.text =
            allIndivWorkouts[idx].weights[exIdx].toString();

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
                        int oldReps = allIndivWorkouts[idx].repsPlanned[exIdx];
                        int oldSets = allIndivWorkouts[idx].setsPlanned[exIdx];
                        setState(() => {
                              allIndivWorkouts[idx].weights[exIdx] =
                                  double.parse(_weightsController.text),
                              allIndivWorkouts[idx].setsPlanned[exIdx] =
                                  int.parse(_myController.text),
                              allIndivWorkouts[idx].repsPlanned[exIdx] =
                                  int.parse(_myController2.text),
                              if (oldSets !=
                                  allIndivWorkouts[idx].setsPlanned[exIdx])
                                {
                                  for (int i = 0;
                                      i <
                                          allIndivWorkouts[idx]
                                                  .setsPlanned[exIdx] -
                                              oldSets;
                                      i++)
                                    {
                                      allIndivWorkouts[idx]
                                          .repsCompleted[exIdx]
                                          .add(allIndivWorkouts[idx]
                                                  .repsPlanned[exIdx] +
                                              1),
                                    },
                                },
                              if (oldReps !=
                                  allIndivWorkouts[idx].repsPlanned[exIdx])
                                {
                                  allIndivWorkouts[idx]
                                      .repsCompleted[exIdx]
                                      .clear(),
                                  for (int j = 0;
                                      j <
                                          allIndivWorkouts[idx]
                                              .setsPlanned[exIdx];
                                      ++j)
                                    {
                                      allIndivWorkouts[idx]
                                          .repsCompleted[exIdx]
                                          .add(allIndivWorkouts[idx]
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
