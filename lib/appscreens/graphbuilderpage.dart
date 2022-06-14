import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:blocklifts/classes/exercise.dart';
import 'package:blocklifts/classes/indivworkout.dart';
import 'package:blocklifts/classes/mydata.dart';
import 'package:intl/intl.dart';
import 'package:blocklifts/globals.dart' as globals;

class GraphBuilderPage extends StatefulWidget {
  final int exIndex;
  final int duration;
  const GraphBuilderPage(this.exIndex, this.duration, {Key? key})
      : super(key: key);
  @override
  _GraphBuilderState createState() => _GraphBuilderState();
}

class _GraphBuilderState extends State<GraphBuilderPage> {
  // widget.exIndex of -1 means body weight
  late final Box<Exercise> exercisesBox;
  late final Box<IndivWorkout> indivWorkoutsBox;
  late List<MyData> _data;
  double date = 0;
  double graphWeight = 0;
  String graphDate = "";
  String completeString = "";
  double minWeight = 0;
  double maxWeight = 0;

  List<MyData> _generateData() {
    final List<MyData> data = <MyData>[];
    DateTime now = DateTime.now();
    late final DateTime start;
    int dateRange = 0;

    if (widget.duration == 1) {
      start = now.subtract(const Duration(days: 30));
    } else if (widget.duration == 3) {
      start = now.subtract(const Duration(days: 90));
    } else if (widget.duration == 6) {
      start = now.subtract(const Duration(days: 180));
    } else if (widget.duration == 12) {
      start = now.subtract(const Duration(days: 365));
    } else if (widget.duration == 24) {
      start = now.subtract(const Duration(days: 730));
    } else if (widget.duration == 25) {
      start = DateTime(1900);
    }
    // this is the starting date that we compare workout dates to
    // if workout date >= dateRange, it's in range and added to the graph
    dateRange = int.parse(DateFormat('yyyyMMdd').format(start));

    for (int i = 0; i < indivWorkoutsBox.length; ++i) {
      if (int.parse(indivWorkoutsBox.getAt(i)!.sortableDate) >= dateRange) {
        String tempDate = indivWorkoutsBox.getAt(i)!.sortableDate;
        date = DateTime.parse(tempDate).millisecondsSinceEpoch.toDouble();
        DateTime dateToFormat =
            DateTime.fromMillisecondsSinceEpoch(date.toInt());
        if (widget.exIndex == -1) {
          data.add(MyData(
              xval: date,
              weight: indivWorkoutsBox.getAt(i)!.bodyWeight,
              completionString: ""));
          graphWeight = indivWorkoutsBox.getAt(i)!.bodyWeight;
          graphDate = DateFormat('d MMM yyyy').format(dateToFormat);
          if (indivWorkoutsBox.getAt(i)!.bodyWeight > maxWeight ||
              maxWeight == 0) {
            maxWeight = indivWorkoutsBox.getAt(i)!.bodyWeight;
          }
          if (indivWorkoutsBox.getAt(i)!.bodyWeight < minWeight ||
              minWeight == 0) {
            minWeight = indivWorkoutsBox.getAt(i)!.bodyWeight;
          }
        } else {
          for (int j = 0;
              j < indivWorkoutsBox.getAt(i)!.exercisesCompleted.length;
              j++) {
            if (indivWorkoutsBox.getAt(i)!.exercisesCompleted[j] ==
                exercisesBox.getAt(widget.exIndex)!.name) {
              bool skipped = true;
              // checks to see if exercise was skipped
              for (int k = 0;
                  k < indivWorkoutsBox.getAt(i)!.repsCompleted[j].length;
                  k++) {
                if (indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1 !=
                    indivWorkoutsBox.getAt(i)!.repsCompleted[j][k]) {
                  skipped = false;
                }
              }
              if (!skipped) {
                data.add(MyData(
                    xval: date,
                    weight: indivWorkoutsBox.getAt(i)!.weights[j],
                    completionString: completionString(i, j)));
                graphWeight = indivWorkoutsBox.getAt(i)!.weights[j];
                graphDate = DateFormat('d MMM yyyy').format(dateToFormat);
                completeString = completionString(i, j);
                if (indivWorkoutsBox.getAt(i)!.weights[j] > maxWeight ||
                    maxWeight == 0) {
                  maxWeight = indivWorkoutsBox.getAt(i)!.weights[j];
                }
                if (indivWorkoutsBox.getAt(i)!.weights[j] < minWeight ||
                    minWeight == 0) {
                  minWeight = indivWorkoutsBox.getAt(i)!.weights[j];
                }
              }
            }
          }
        }
      }
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    exercisesBox = Hive.box<Exercise>('exercisesBox');
    indivWorkoutsBox = Hive.box<IndivWorkout>('indivWorkoutsBox');
    _data = _generateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.backColor,
      body: _data.isNotEmpty
          ? Column(
              children: <Widget>[
                ValueListenableBuilder(
                    valueListenable: globals.graphCounter,
                    builder: (context, value, child) {
                      return Container(
                          padding: const EdgeInsets.only(left: 25, top: 25),
                          child: Column(children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: graphWeight % 1 == 0
                                  ? Text(
                                      "${graphWeight.toInt().toString()}${globals.lbKg}",
                                      style: const TextStyle(fontSize: 18))
                                  : Text(
                                      "${graphWeight.toString()}${globals.lbKg}",
                                      style: const TextStyle(fontSize: 18)),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(graphDate,
                                  style: TextStyle(
                                      fontSize: 14, color: globals.greyColor)),
                            ),
                            widget.exIndex != -1
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(completeString,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: globals.greyColor)),
                                  )
                                : const SizedBox(),
                          ]));
                    }),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: _graph(),
                      padding: const EdgeInsets.all(25),
                      height: MediaQuery.of(context).size.height * 0.3,
                    ))
              ],
            )
          : Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.only(top: 100),
                child: widget.duration == 25
                    ? const Text("No workouts logged")
                    : widget.duration == 24
                        ? const Text("No workouts logged in the last two years")
                        : widget.duration == 12
                            ? const Text("No workouts logged in the last year")
                            : widget.duration == 1
                                ? const Text(
                                    "No workouts logged in the last month")
                                : Text(
                                    "No workouts logged in the last ${widget.duration} months"),
              ),
            ),
    );
  }

  Widget _graph() {
    final spots = _data
        .asMap()
        .entries
        .map((element) => FlSpot(
              element.value.xval,
              element.value.weight,
            ))
        .toList();

    return LineChart(
      LineChartData(
        borderData: FlBorderData(
          show: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: Colors.orange,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: const Alignment(0, -1),
                end: const Alignment(0, 1),
                colors: [
                  Colors.orange.withOpacity(0.2),
                  Colors.orange.withOpacity(0.01)
                ],
              ),
            ),
            dotData: FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.orange,
                  strokeWidth: 0,
                );
              },
            ),
          ),
        ],
        minX: _data.length == 1 ? date - 1 : _data.first.xval,
        maxX: _data.length == 1 ? date + 1 : _data.last.xval,
        minY: minWeight * 0.994,
        maxY: maxWeight * 1.006,
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: rightTitleWidgets,
              reservedSize: 45,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: globals.greyColor,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        lineTouchData: LineTouchData(
            enabled: true,
            touchSpotThreshold: 10000, // snaps to nearest point
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
              globals.graphCounter.value++;
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map(
                  (LineBarSpot touchedSpot) {
                    graphWeight = _data[touchedSpot.spotIndex].weight;
                    int dateInt = _data[touchedSpot.spotIndex].xval.toInt();
                    DateTime tempDate =
                        DateTime.fromMillisecondsSinceEpoch(dateInt);
                    graphDate = DateFormat('d MMM yyyy').format(tempDate);
                    completeString =
                        _data[touchedSpot.spotIndex].completionString;
                  },
                ).toList();
              },
            ),
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> indicators) {
              return indicators.map(
                (int index) {
                  final line = FlLine(
                    color: Colors.orange,
                    strokeWidth: 1,
                  );
                  return TouchedSpotIndicatorData(
                    line,
                    FlDotData(show: false),
                  );
                },
              ).toList();
            },
            getTouchLineEnd: (_, __) => double.infinity),
      ),
    );
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: globals.greyColor,
      fontSize: 9,
    );
    Widget text;
    if (value < maxWeight * 1.006 && value > minWeight * 0.994) {
      value % 1 == 0
          ? text = Text(value.toInt().toString(), style: style)
          : text = Text(value.toStringAsFixed(2), style: style);
    } else {
      text = const Text("");
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: text,
    );
  }

  String completionString(int i, int j) {
    String output = "";
    int successCounter = 0;

    for (int k = 0; k < indivWorkoutsBox.getAt(i)!.setsPlanned[j]; k++) {
      if (indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
          indivWorkoutsBox.getAt(i)!.repsPlanned[j] + 1) {
        output += "0";
      } else {
        if (indivWorkoutsBox.getAt(i)!.repsCompleted[j][k] ==
            indivWorkoutsBox.getAt(i)!.repsPlanned[j]) {
          successCounter++;
        }
        output += indivWorkoutsBox.getAt(i)!.repsCompleted[j][k].toString();
      }

      if (k != indivWorkoutsBox.getAt(i)!.setsPlanned[j] - 1) {
        output += "/";
      } else {
        if (indivWorkoutsBox.getAt(i)!.setsPlanned[j] == 1) {
          output = "";
          output += "1";
          output += "×";
          output += indivWorkoutsBox.getAt(i)!.repsCompleted[j][k].toString();
        } else if (successCounter ==
            indivWorkoutsBox.getAt(i)!.setsPlanned[j]) {
          output = "";
          output += indivWorkoutsBox.getAt(i)!.setsPlanned[j].toString();
          output += "×";
          output += indivWorkoutsBox.getAt(i)!.repsPlanned[j].toString();
        }
      }
    }
    return output;
  }
}
