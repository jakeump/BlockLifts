import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/appscreens/graphbuilderpage.dart';
import 'package:blocklifts/providers/progressprovider.dart';
import 'package:provider/provider.dart';
import 'package:blocklifts/globals.dart' as globals;

class GraphPage extends StatefulWidget {
  final int index;
  const GraphPage(this.index, {Key? key}) : super(key: key);
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  // widget.index of -1 means body weight
  late final Box<Exercise> exercisesBox;

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: globals.backColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 18,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: globals.headerColor,
          title: widget.index == -1
              ? const Text("Body Weight")
              : Text(exercisesBox.getAt(widget.index)!.name),
          titleTextStyle:
              TextStyle(fontSize: 22, color: globals.textColor),
          actions: <Widget>[
            if (widget.index != -1)
              IconButton(
                icon: exercisesBox.getAt(widget.index)!.bookmarked
                    ? const Icon(Icons.bookmark)
                    : const Icon(Icons.bookmark_border),
                color: exercisesBox.getAt(widget.index)!.bookmarked
                    ? Colors.orange
                    : globals.textColor,
                iconSize: 24,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  exercisesBox.getAt(widget.index)!.bookmarked =
                      !exercisesBox.getAt(widget.index)!.bookmarked;
                  exercisesBox.getAt(widget.index)!.save();
                  var progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                  progressProvider.updateProgress();
                  setState(() {});
                },
              ),
          ],
          bottom: TabBar(
            isScrollable: false,
            indicatorColor: globals.redColor,
            labelColor: globals.textColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                text: '1M',
              ),
              Tab(
                text: '3M',
              ),
              Tab(
                text: '6M',
              ),
              Tab(
                text: '1Y',
              ),
              Tab(
                text: '2Y',
              ),
              Tab(
                text: '∞',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GraphBuilderPage(widget.index, 1),
            GraphBuilderPage(widget.index, 3),
            GraphBuilderPage(widget.index, 6),
            GraphBuilderPage(widget.index, 12),
            GraphBuilderPage(widget.index, 24),
            GraphBuilderPage(widget.index, 25), // infinite
          ],
        ),
      ),
    );
  }
}
