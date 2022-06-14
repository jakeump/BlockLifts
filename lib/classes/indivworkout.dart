import 'package:hive_flutter/hive_flutter.dart';
part 'indivworkout.g.dart';

// used for the edit page, stores all relevant single-workout data
@HiveType(typeId: 2)
class IndivWorkout extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String date;
  @HiveField(2)
  String sortableDate;
  @HiveField(3)
  List<String> exercisesCompleted;
  @HiveField(4)
  List<double> weights;
  @HiveField(5)
  List<int> repsPlanned;
  @HiveField(6)
  List<int> setsPlanned;
  @HiveField(7)
  List<List<int>> repsCompleted;
  @HiveField(8)
  String note;
  @HiveField(9)
  double bodyWeight;

  IndivWorkout(
      this.name,
      this.date,
      this.sortableDate,
      this.exercisesCompleted,
      this.weights,
      this.repsPlanned,
      this.setsPlanned,
      this.repsCompleted,
      this.note,
      this.bodyWeight);
}
