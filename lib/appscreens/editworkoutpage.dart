import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/incrementssettings.dart';
import 'package:blocklifts/appscreens/editexercisepage.dart';
import 'package:blocklifts/providers/progressprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class EditWorkoutPage extends StatefulWidget {
  final int index;
  const EditWorkoutPage(this.index, {Key? key}) : super(key: key);
  @override
  EditWorkoutPageState createState() => EditWorkoutPageState();
}

class EditWorkoutPageState extends State<EditWorkoutPage> {
  final _myController = TextEditingController();
  late final Box<Exercise> exercisesBox;
  late List<Exercise> exercisesList;
  late List<Exercise> copyExercisesList;
  late final Box<Workout> workoutsBox;
  late final Box<double> defaultsBox;
  late final Box<IncrementsSettings> incrementsSettingsBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
    defaultsBox = Hive.box<double>('defaultsBox');
    incrementsSettingsBox =
        Hive.box<IncrementsSettings>('incrementsSettingsBox');
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
        title: Text(workoutsBox.getAt(widget.index)!.name),
        titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 150,
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ReorderableListView(
                shrinkWrap: true,
                // for every item of the List<Workout> class, display the reorder indicator
                // the name, the exercises, and three dots on the right
                scrollDirection: Axis.vertical,
                buildDefaultDragHandles: false,
                children: <Widget>[
                  for (int i = 0;
                      i < workoutsBox.getAt(widget.index)!.exercises.length;
                      i++)
                    GestureDetector(
                      key: Key('$i'),
                      child: Container(
                          color: globals.backColor, // custom color goes here
                          child: ListTile(
                            leading: SizedBox(
                                width: 40,
                                child: Center(
                                    child: ReorderableDragStartListener(
                                  index: i,
                                  child: Icon(Icons.drag_indicator_outlined,
                                      color: globals.greyColor),
                                ))),
                            title: GestureDetector(
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
                                          "${workoutsBox.getAt(widget.index)!.exercises[i].sets.toString()} ${workoutsBox.getAt(widget.index)!.exercises[i].sets == 1 ? "set" : "sets"} of ${workoutsBox.getAt(widget.index)!.exercises[i].reps.toString()} ${workoutsBox.getAt(widget.index)!.exercises[i].reps == 1 ? "rep" : "reps"}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: globals.greyColor),
                                          softWrap: false,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              onTap: () {
                                for (int j = 0; j < exercisesBox.length; j++) {
                                  if (exercisesBox.getAt(j)!.name ==
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
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (dynamic value) {
                                // edits
                                if (value == 'edit') {
                                  for (int j = 0;
                                      j < exercisesBox.length;
                                      j++) {
                                    if (exercisesBox.getAt(j)!.name ==
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
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: globals.tileColor,
                                      title: Text('Delete From All Workouts',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: globals.textColor)),
                                      content: Text(
                                          'This will remove the exercise from all workouts and clear its statistics. It will not be visible on the progress page. Are you sure you want to delete?',
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
                                            setState(() {
                                              for (int k = 0;
                                                  k < exercisesBox.length;
                                                  k++) {
                                                if (exercisesBox
                                                        .getAt(k)!
                                                        .name ==
                                                    workoutsBox
                                                        .getAt(widget.index)!
                                                        .exercises[i]
                                                        .name) {
                                                  exercisesBox.deleteAt(k);
                                                }
                                              }
                                              for (int j = 0;
                                                  j < workoutsBox.length;
                                                  j++) {
                                                if (workoutsBox.getAt(j)! ==
                                                    workoutsBox
                                                        .getAt(widget.index)!) {
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
                                                            .getAt(
                                                                widget.index)!
                                                            .exercises[i]
                                                            .name) {
                                                      final tempWorkout =
                                                          Hive.box<Workout>(
                                                                  'workoutsBox')
                                                              .getAt(j);
                                                      tempWorkout?.exercises
                                                          .removeAt(i);
                                                      tempWorkout?.save();
                                                    }
                                                  }
                                                }
                                              }
                                              final tempWorkout =
                                                  Hive.box<Workout>(
                                                          'workoutsBox')
                                                      .getAt(widget.index);
                                              tempWorkout?.exercises
                                                  .removeAt(i);
                                              tempWorkout?.save();
                                            });
                                            var progressProvider =
                                                Provider.of<ProgressProvider>(
                                                    context,
                                                    listen: false);
                                            progressProvider.updateProgress();
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
                                }
                              },
                              itemBuilder: (BuildContext bc) {
                                return const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text("Edit"),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text("Delete"),
                                  ),
                                  PopupMenuItem(
                                    value: 'deleteAll',
                                    child: Text("Delete From All Workouts"),
                                  ),
                                ];
                              },
                            ),
                          )),
                      onTap: () {
                        for (int j = 0; j < exercisesBox.length; j++) {
                          if (exercisesBox.getAt(j)!.name ==
                              workoutsBox
                                  .getAt(widget.index)!
                                  .exercises[i]
                                  .name) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => EditExercisePage(j)))
                                .then((value) {
                              setState(() {});
                            });
                          }
                        }
                      },
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
                      Divider(
              height: 10,
              thickness: 1,
              color: globals.dividerColor,
              indent: 10,
              endIndent: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    alignment: Alignment.centerLeft),
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text("Change Workout Name",
                      style: TextStyle(color: globals.textColor)),
                ),
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
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(bottom: 10),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                final tempWorkout =
                                                    Hive.box<Workout>(
                                                            'workoutsBox')
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
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                      alignment: Alignment.centerLeft),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("Delete All Exercises",
                        style: TextStyle(color: globals.textColor)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: globals.tileColor,
                        title: Text('Delete All Exercises',
                            style: TextStyle(
                                fontSize: 20, color: globals.textColor)),
                        content: Text(
                            'Are you sure you want to delete all exercises in this workout?',
                            style: TextStyle(
                                fontSize: 15, color: globals.textColor)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 16, color: globals.redColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                final tempWorkout =
                                    Hive.box<Workout>('workoutsBox')
                                        .getAt(widget.index);
                                tempWorkout?.exercises.clear();
                                tempWorkout?.save();
                                workoutsBox
                                    .getAt(widget.index)!
                                    .exercises
                                    .clear();
                              });
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
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            fixedSize: const Size.fromHeight(50),
            primary: Colors.white,
            backgroundColor: globals.redColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
          onPressed: () {
            exercisesList = exercisesBox.values.toList();
            exercisesList.removeAt(0);
            copyExercisesList = exercisesBox.values.toList();
            copyExercisesList.removeAt(0);
            copyExercisesList.sort((a, b) {
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });
            // removes if already in workout
            for (var ex in exercisesList) {
              for (int i = 0;
                  i < workoutsBox.getAt(widget.index)!.exercises.length;
                  i++) {
                if (ex.name ==
                    workoutsBox.getAt(widget.index)!.exercises[i].name) {
                  copyExercisesList.remove(ex);
                }
              }
            }
            copyExercisesList.insert(0, globals.customxyz);

            Exercise? selectVal = globals.customxyz;
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
                            items: copyExercisesList.map((Exercise exercise) {
                              return DropdownMenuItem<Exercise>(
                                  value: exercise, child: Text(exercise.name));
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
                                  _myController.text = "";
                                  setState(() {
                                    if (selectVal == globals.customxyz) {
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
                                                              TextInputType
                                                                  .text,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .bottom,
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .words,
                                                          decoration:
                                                              const InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    bottom: 10),
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: globals
                                                              .underlineColor,
                                                          height: 2,
                                                          thickness: 2,
                                                        ),
                                                        const SizedBox(
                                                            height: 30),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                              TextButton(
                                                                style: TextButton
                                                                    .styleFrom(
                                                                  primary: globals
                                                                      .redColor,
                                                                  textStyle: const TextStyle(
                                                                      fontSize:
                                                                          16,
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
                                                                    primary: globals
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
                                                                    bool
                                                                        duplicate =
                                                                        false;
                                                                    // check that it's not in all exercises and it's not in current workout
                                                                    for (int i =
                                                                            0;
                                                                        i < exercisesBox.length;
                                                                        i++) {
                                                                      if (_myController
                                                                              .text ==
                                                                          exercisesBox
                                                                              .getAt(i)!
                                                                              .name) {
                                                                        duplicate =
                                                                            true;
                                                                      }
                                                                    }
                                                                    for (int i =
                                                                            0;
                                                                        i < workoutsBox.getAt(widget.index)!.exercises.length;
                                                                        i++) {
                                                                      if (_myController
                                                                              .text ==
                                                                          workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .exercises[i]
                                                                              .name) {
                                                                        duplicate =
                                                                            true;
                                                                      }
                                                                    }
                                                                    if (duplicate ==
                                                                        false) {
                                                                      Exercise newEx = Exercise(
                                                                          _myController
                                                                              .text,
                                                                          defaultsBox.getAt(
                                                                              0)!,
                                                                          defaultsBox
                                                                              .getAt(
                                                                                  1)!
                                                                              .toInt(),
                                                                          defaultsBox
                                                                              .getAt(
                                                                                  2)!
                                                                              .toInt(),
                                                                          incrementsSettingsBox
                                                                              .getAt(
                                                                                  0)!
                                                                              .overload,
                                                                          incrementsSettingsBox
                                                                              .getAt(
                                                                                  0)!
                                                                              .incrementFrequency,
                                                                          incrementsSettingsBox
                                                                              .getAt(
                                                                                  0)!
                                                                              .increment,
                                                                          incrementsSettingsBox
                                                                              .getAt(
                                                                                  0)!
                                                                              .deload,
                                                                          incrementsSettingsBox
                                                                              .getAt(
                                                                                  0)!
                                                                              .deloadPercent,
                                                                          incrementsSettingsBox
                                                                              .getAt(0)!
                                                                              .deloadFrequency);
                                                                      newEx.weight =
                                                                          defaultsBox
                                                                              .getAt(0)!;
                                                                      // Adds to Hive local storage
                                                                      exercisesBox
                                                                          .add(
                                                                              newEx);

                                                                      final tempWorkout = Hive.box<Workout>(
                                                                              'workoutsBox')
                                                                          .getAt(
                                                                              widget.index);
                                                                      tempWorkout
                                                                          ?.exercises
                                                                          .add(
                                                                              newEx);
                                                                      tempWorkout
                                                                          ?.save();
                                                                      var progressProvider = Provider.of<
                                                                              ProgressProvider>(
                                                                          context,
                                                                          listen:
                                                                              false);
                                                                      progressProvider
                                                                          .updateProgress();

                                                                      if (workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .isInitialized ==
                                                                          false) {
                                                                        for (int j =
                                                                                0;
                                                                            j < workoutsBox.getAt(widget.index)!.exercises.length;
                                                                            ++j) {
                                                                          for (int k = 0;
                                                                              k < workoutsBox.getAt(widget.index)!.exercises[j].sets;
                                                                              k++) {
                                                                            // repsCompleted initialized with initial reps value
                                                                            workoutsBox.getAt(widget.index)!.exercises[j].repsCompleted.add(workoutsBox.getAt(widget.index)!.exercises[j].reps +
                                                                                1);
                                                                          }
                                                                        }
                                                                        workoutsBox
                                                                            .getAt(widget.index)!
                                                                            .isInitialized = true;
                                                                      } else {
                                                                        // adds to repsCompleted, initializes it
                                                                        for (int j =
                                                                                0;
                                                                            j < workoutsBox.getAt(widget.index)!.exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1].sets;
                                                                            j++) {
                                                                          workoutsBox
                                                                              .getAt(widget.index)!
                                                                              .exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1]
                                                                              .repsCompleted
                                                                              .add(workoutsBox.getAt(widget.index)!.exercises[workoutsBox.getAt(widget.index)!.exercises.length - 1].reps + 1);
                                                                        }
                                                                        setState(() =>
                                                                            Navigator.of(context).pop());
                                                                      }
                                                                      _myController
                                                                          .text = "";
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      Navigator.of(
                                                                              context)
                                                                          .push(MaterialPageRoute(
                                                                              builder: (context) => EditExercisePage(exercisesBox.length -
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
                                                                            content:
                                                                                Text("Exercise already exists"),
                                                                            duration: Duration(seconds: 2)),
                                                                      );
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    }
                                                                  }),
                                                            ]),
                                                      ]))));
                                    } else {
                                      final tempWorkout =
                                          Hive.box<Workout>('workoutsBox')
                                              .getAt(widget.index);
                                      tempWorkout?.exercises.add(selectVal!);

                                      tempWorkout?.save();

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
                                  });
                                },
                              ),
                            ]),
                      ]),
                ),
              ),
            );
          },
          child: const Text("Add Exercise", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
