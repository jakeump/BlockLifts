import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/workout.dart';
import 'package:blocklifts/appscreens/editworkoutpage.dart';
import 'package:blocklifts/globals.dart' as globals;

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);
  @override
  EditState createState() => EditState();
}

class EditState extends State<Edit> {
  final _myController = TextEditingController();
  late final Box<Workout> workoutsBox;
  late final Box<int> counterBox;

  @override
  void initState() {
    super.initState();
    counterBox = Hive.box<int>('counterBox');
    workoutsBox = Hive.box<Workout>('workoutsBox');
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
        title: const Text("Program"),
        titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 150,
        ),
        child: Column(children: <Widget>[
          Flexible(
            child: ReorderableListView(
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
                      color: globals.backColor, // custom color goes here
                      child: ListTile(
                          leading: SizedBox(
                              width: 40,
                              child: Center(
                                  child: ReorderableDragStartListener(
                                index: index,
                                child: Icon(Icons.drag_indicator_outlined,
                                    color: globals.greyColor),
                              ))),
                          title: Column(
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
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: globals.greyColor),
                                        )
                                      else
                                        Text(
                                          workoutsBox
                                              .getAt(index)!
                                              .exercises[i]
                                              .name,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: globals.greyColor),
                                        ),
                                  ])),
                            ],
                          ),
                          trailing: PopupMenuButton(
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
                                  value: 'edit',
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Delete"),
                                ),
                              ];
                            },
                          )),
                    ),
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
          const Divider(height: 20, color: Colors.transparent),
          if (workoutsBox.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    alignment: Alignment.centerLeft),
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text("Delete All Workouts",
                      style: TextStyle(color: globals.textColor)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: globals.tileColor,
                      title: Text('Delete All Workouts',
                          style: TextStyle(
                              fontSize: 20, color: globals.textColor)),
                      content: Text(
                          'Are you sure you want to delete all workouts?',
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
                              counterBox.putAt(0, 0);
                              counterBox.putAt(1, 0);
                              workoutsBox.deleteAll(workoutsBox.keys);
                              workoutsBox.clear();
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
        ]),
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
                                textCapitalization: TextCapitalization.words,
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
                                          bool duplicate = false;
                                          for (var i in workoutsBox.values) {
                                            if (i.name == _myController.text) {
                                              duplicate = true;
                                            }
                                          }
                                          if (duplicate == false) {
                                            workoutsBox.add(
                                                Workout(_myController.text));
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
                                          } else {
                                            _myController.text = "";
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Workout already exists"),
                                              duration: Duration(seconds: 2),
                                            ));
                                            Navigator.of(context).pop();
                                          }
                                        }),
                                  ]),
                            ]))));
          },
          child: const Text("Add Workout", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
