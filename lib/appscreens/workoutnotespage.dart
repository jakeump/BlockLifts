import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/globals.dart' as globals;


class WorkoutNotesPage extends StatefulWidget {
  const WorkoutNotesPage({Key? key}) : super(key: key);
  @override
  _WorkoutNotesState createState() => _WorkoutNotesState();
}

class _WorkoutNotesState extends State<WorkoutNotesPage> {
  late final Box<String> tempNoteBox;
  final _myController = TextEditingController();

  @override
  void initState() {
    tempNoteBox = Hive.box<String>('tempNoteBox');
    _myController.text = tempNoteBox.getAt(0)!; //default text
    super.initState();
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
          title: const Text("Note"),
          titleTextStyle: TextStyle(fontSize: 22, color: globals.textColor),
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              autofocus: true,
              maxLines: null,
              showCursor: true,
              enableInteractiveSelection: true,
              style: const TextStyle(
                fontSize: 18,
              ),
              focusNode: FocusNode(),
              controller: _myController,
              onChanged: (val) {
                tempNoteBox.putAt(0, _myController.text);
              },
            )));
  }
}
