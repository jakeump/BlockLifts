import 'package:flutter/material.dart';
import 'package:blocklifts/globals.dart' as globals;

class PostWorkoutNotesPage extends StatefulWidget {
  final int index;
  const PostWorkoutNotesPage(this.index, {Key? key}) : super(key: key);
  @override
  _PostWorkoutNotesState createState() => _PostWorkoutNotesState();
}

class _PostWorkoutNotesState extends State<PostWorkoutNotesPage> {
  final _myController = TextEditingController();

  @override
  void initState() {
    _myController.text = globals.postWorkoutTempNote; //default text
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
                globals.changesMade = true;
                globals.postWorkoutTempNote = _myController.text;
              },
            )));
  }
}
