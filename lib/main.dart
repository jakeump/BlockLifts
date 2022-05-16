import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

List<Workout> allWorkouts = []; // global list of workouts
List<IndivWorkout> allIndivWorkouts = []; // global list of each indiv workout
List<double> bodyWeights = []; // global list of body weight
double tempBodyWeight = 100.5;

// should probably be an ordered set
List<Exercise> allExercises = []; // global list of exercises

var headerColor = Colors.black;
var backColor = Colors.black;
var widgetNavColor = const Color.fromARGB(134, 39, 39, 39);
var redColor = const Color.fromARGB(255, 172, 10, 10);
int counter = 0;

ValueNotifier<int> _counter = ValueNotifier<int>(0); // to update list page

Exercise customxyz = Exercise("Custom Exercise");
Workout defaultA = Workout("Stronglifts Default A");
Workout defaultB = Workout("Stronglifts Default B");
Exercise squat = Exercise("Squat");
Exercise benchPress = Exercise("Bench Press");
Exercise barbellRow = Exercise("Barbell Row");
Exercise overheadPress = Exercise("Overhead Press");
Exercise deadlift = Exercise("Deadlift");

class Workout {
  String name; // workout name (like "Workout A")
  List<Exercise> exercises = []; // List of workouts (bench, squat, curl, etc)
  Workout(this.name); // constructor for name

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

  List<String> exercisesCompleted = [];
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
  final int exIndex;
  const EditExercisePage(this.index, this.exIndex, {Key? key})
      : super(key: key);
  @override
  _EditExercisePageState createState() => _EditExercisePageState();
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
                              for (int k = 0;
                                  k < allWorkouts[i].exercises.length;
                                  ++k) {
                                for (int j = 0;
                                    j < allWorkouts[i].exercises[k].sets;
                                    j++) {
                                  // repsCompleted initialized with initial reps value
                                  allWorkouts[i].exercises[k].repsCompleted.add(
                                      allWorkouts[i].exercises[k].reps + 1);
                                }
                              }
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => WorkoutPage(i)))
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            child: Container(
                                height: 220,
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
                                        height: 20, color: Colors.transparent),
                                    SizedBox(
                                      height: 152,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(children: [
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
                                              const Divider(
                                                  height: 25,
                                                  color: Colors.transparent),
                                            ])
                                        ]),
                                      ),
                                    ),
                                  ],
                                ))),
                        const Divider(height: 5, color: Colors.transparent),
                      ]),
                    for (int i = 0; i < counter; i++)
                      Column(children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              if (allWorkouts[counter]
                                  .exercises[0]
                                  .repsCompleted
                                  .isEmpty) {
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
                              }
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => WorkoutPage(i)))
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            child: Container(
                                height: 220,
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
                                        height: 20, color: Colors.transparent),
                                    SizedBox(
                                      height: 152,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(children: [
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
                                              const Divider(
                                                  height: 25,
                                                  color: Colors.transparent),
                                            ])
                                        ]),
                                      ),
                                    ),
                                  ],
                                ))),
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
              if (allWorkouts[counter].exercises[0].repsCompleted.isEmpty) {
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
        backgroundColor: Colors.black,
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
                              // go to custom edit page
                            },
                            child: Container(
                                height: 220,
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
                                      child: Text(allIndivWorkouts[i].name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 17,
                                          )),
                                    ),
                                    const Divider(
                                        height: 20, color: Colors.transparent),
                                    SizedBox(
                                        height: 152,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(children: [
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
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17)))),
                                                ]),
                                                const Divider(
                                                    height: 25,
                                                    color: Colors.transparent),
                                              ])
                                          ]),
                                        ))
                                  ],
                                ))),
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
      backgroundColor: Colors.black,
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
    );
  }
}

class _EditState extends State<Edit> {
  final _myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: SizedBox(height: 40,
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
                                allWorkouts[idx].exercises[j].repsCompleted.add(
                                    allWorkouts[idx].exercises[j].reps + 1);
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
                repsCompleted
                    .add(allWorkouts[widget.index].exercises[i].repsCompleted);
              }

              allIndivWorkouts.add(IndivWorkout(name, date, exercisesCompleted,
                  weights, repsPlanned, setsPlanned, repsCompleted));

              bodyWeights.add(tempBodyWeight);

              _counter.value++;
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  EditExercisePage(
                                                      widget.index, i)))
                                          .then((value) {
                                        setState(() {});
                                      });
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
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditExercisePage(
                                                            widget.index, i)))
                                                .then((value) {
                                              setState(() {});
                                            });
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
                      builder: (context) => const NotesPage()));
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditWorkoutPage(widget.index)))
                      .then((value) { setState(() {});
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
    );
  }
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final _myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                int awIndex = widget.index;
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            EditExercisePage(awIndex, i)))
                                    .then((value) {
                                  setState(() {});
                                });
                              },
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (dynamic value) {
                                int awIndex = widget.index;
                                // edits
                                if (value == 'edit') {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              EditExercisePage(awIndex, i)))
                                      .then((value) {
                                    setState(() {});
                                  });
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
                                                                _myController
                                                                    .text = "";
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (context) => EditExercisePage(
                                                                            widget
                                                                                .index,
                                                                            allWorkouts[widget.index].exercises.length -
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Exercise already in workout"),
                                          duration: Duration(seconds: 2)),
                                    );
                                  } else {
                                    allWorkouts[widget.index]
                                        .exercises
                                        .add(selectVal!);
                                    setState(() => Navigator.of(context).pop());
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
                allWorkouts[widget.index].exercises[widget.exIndex].name,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            // displays no decimal points if it's not a decimal (casts to int)
            if (allWorkouts[widget.index].exercises[widget.exIndex].weight %
                        1 ==
                    0 &&
                ((allWorkouts[widget.index].exercises[widget.exIndex].weight -
                                allWorkouts[widget.index]
                                    .exercises[widget.exIndex]
                                    .barWeight) /
                            2) %
                        1 ==
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allWorkouts[widget.index].exercises[widget.exIndex].weight.toInt().toString()}lb (${((allWorkouts[widget.index].exercises[widget.exIndex].weight - allWorkouts[widget.index].exercises[widget.exIndex].barWeight) ~/ 2)}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            if (allWorkouts[widget.index].exercises[widget.exIndex].weight %
                        1 ==
                    0 &&
                ((allWorkouts[widget.index].exercises[widget.exIndex].weight -
                                allWorkouts[widget.index]
                                    .exercises[widget.exIndex]
                                    .barWeight) /
                            2) %
                        1 !=
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allWorkouts[widget.index].exercises[widget.exIndex].weight.toInt().toString()}lb (${((allWorkouts[widget.index].exercises[widget.exIndex].weight - allWorkouts[widget.index].exercises[widget.exIndex].barWeight) / 2).toString()}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            // if there are decimals
            if (allWorkouts[widget.index].exercises[widget.exIndex].weight %
                        1 !=
                    0 &&
                ((allWorkouts[widget.index].exercises[widget.exIndex].weight -
                                allWorkouts[widget.index]
                                    .exercises[widget.exIndex]
                                    .barWeight) /
                            2) %
                        1 ==
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allWorkouts[widget.index].exercises[widget.exIndex].weight.toString()}lb (${((allWorkouts[widget.index].exercises[widget.exIndex].weight - allWorkouts[widget.index].exercises[widget.exIndex].barWeight) ~/ 2)}/side)",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            if (allWorkouts[widget.index].exercises[widget.exIndex].weight %
                        1 !=
                    0 &&
                ((allWorkouts[widget.index].exercises[widget.exIndex].weight -
                                allWorkouts[widget.index]
                                    .exercises[widget.exIndex]
                                    .barWeight) /
                            2) %
                        2 !=
                    0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${allWorkouts[widget.index].exercises[widget.exIndex].weight.toString()}lb (${((allWorkouts[widget.index].exercises[widget.exIndex].weight - allWorkouts[widget.index].exercises[widget.exIndex].barWeight) / 2).toString()}/side)",
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
              if (allWorkouts[widget.index].exercises[widget.exIndex].weight %
                      1 ==
                  0) {
                setState(() => _myController.text = allWorkouts[widget.index]
                    .exercises[widget.exIndex]
                    .weight
                    .toInt()
                    .toString());
              }
              if (allWorkouts[widget.index].exercises[widget.exIndex].weight %
                      1 !=
                  0) {
                setState(() => _myController.text = allWorkouts[widget.index]
                    .exercises[widget.exIndex]
                    .weight
                    .toString());
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
                                    if (allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .weight %
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
                                    } else if (allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
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
                                        if (allWorkouts[widget.index]
                                                    .exercises[widget.exIndex]
                                                    .weight %
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
                                        if (allWorkouts[widget.index]
                                                    .exercises[widget.exIndex]
                                                    .weight %
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
                                setState(() => allWorkouts[widget.index]
                                    .exercises[widget.exIndex]
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
                      if (allWorkouts[widget.index]
                                  .exercises[widget.exIndex]
                                  .weight %
                              1 ==
                          0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allWorkouts[widget.index].exercises[widget.exIndex].weight.toInt().toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (allWorkouts[widget.index]
                                  .exercises[widget.exIndex]
                                  .weight %
                              1 !=
                          0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allWorkouts[widget.index].exercises[widget.exIndex].weight.toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ]))),
        // bar weight
        GestureDetector(
            onTap: () {
              if (allWorkouts[widget.index]
                          .exercises[widget.exIndex]
                          .barWeight %
                      1 ==
                  0) {
                setState(() => _myController.text = allWorkouts[widget.index]
                    .exercises[widget.exIndex]
                    .barWeight
                    .toInt()
                    .toString());
              }
              if (allWorkouts[widget.index]
                          .exercises[widget.exIndex]
                          .barWeight %
                      1 !=
                  0) {
                setState(() => _myController.text = allWorkouts[widget.index]
                    .exercises[widget.exIndex]
                    .barWeight
                    .toString());
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
                                    if (allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .barWeight %
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
                                    } else if (allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
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
                                        if (allWorkouts[widget.index]
                                                    .exercises[widget.exIndex]
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
                                        if (allWorkouts[widget.index]
                                                    .exercises[widget.exIndex]
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
                                setState(() => allWorkouts[widget.index]
                                        .exercises[widget.exIndex]
                                        .barWeight =
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
                      if (allWorkouts[widget.index]
                                  .exercises[widget.exIndex]
                                  .barWeight %
                              1 ==
                          0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allWorkouts[widget.index].exercises[widget.exIndex].barWeight.toInt().toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (allWorkouts[widget.index]
                                  .exercises[widget.exIndex]
                                  .barWeight %
                              1 !=
                          0)
                        Align(
                          alignment: const Alignment(-.91, 0),
                          child: Text(
                            "${allWorkouts[widget.index].exercises[widget.exIndex].barWeight.toString()}lb",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ]))),
        // sets x reps
        GestureDetector(
            onTap: () {
              setState(() => _myController.text = allWorkouts[widget.index]
                  .exercises[widget.exIndex]
                  .sets
                  .toString());
              setState(() => _myController2.text = allWorkouts[widget.index]
                  .exercises[widget.exIndex]
                  .reps
                  .toString());

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
                                  int oldReps = allWorkouts[widget.index]
                                      .exercises[widget.exIndex]
                                      .reps;
                                  int oldSets = allWorkouts[widget.index]
                                      .exercises[widget.exIndex]
                                      .reps;
                                  setState(() => {
                                        allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .sets =
                                            int.parse(_myController.text),
                                        allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .reps =
                                            int.parse(_myController2.text),
                                        if (oldSets !=
                                            allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .sets)
                                          {
                                            for (int i = 0;
                                                i <
                                                    allWorkouts[widget.index]
                                                            .exercises[
                                                                widget.exIndex]
                                                            .sets -
                                                        oldSets;
                                                i++)
                                              {
                                                allWorkouts[widget.index]
                                                    .exercises[widget.exIndex]
                                                    .repsCompleted
                                                    .add(allWorkouts[
                                                                widget.index]
                                                            .exercises[
                                                                widget.exIndex]
                                                            .reps +
                                                        1)
                                              },
                                          },
                                        if (oldReps !=
                                            allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .reps)
                                          {
                                            allWorkouts[widget.index]
                                                .exercises[widget.exIndex]
                                                .repsCompleted
                                                .clear(),
                                            for (int j = 0;
                                                j <
                                                    allWorkouts[widget.index]
                                                        .exercises[
                                                            widget.exIndex]
                                                        .sets;
                                                ++j)
                                              {
                                                allWorkouts[widget.index]
                                                    .exercises[widget.exIndex]
                                                    .repsCompleted
                                                    .add(allWorkouts[
                                                                widget.index]
                                                            .exercises[
                                                                widget.exIndex]
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
                          "${allWorkouts[widget.index].exercises[widget.exIndex].sets.toString()}x${allWorkouts[widget.index].exercises[widget.exIndex].reps.toString()}",
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
              setState(() => _myController.text =
                  allWorkouts[widget.index].exercises[widget.exIndex].name);
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
                                      setState(() => allWorkouts[widget.index]
                                          .exercises[widget.exIndex]
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
