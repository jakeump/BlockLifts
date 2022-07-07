import 'package:hive_flutter/hive_flutter.dart';
part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  // weight, bar weight, increments, sets x reps
  @HiveField(0)
  String name;
  @HiveField(1)
  double weight = 45;
  @HiveField(2)
  double barWeight;
  @HiveField(3)
  double increment;
  @HiveField(4)
  int sets;
  @HiveField(5)
  int reps;
  @HiveField(6)
  List<int> repsCompleted = [];
  @HiveField(7)
  int failed = 0;
  @HiveField(8)
  bool overload;
  @HiveField(9)
  bool deload;
  @HiveField(10)
  int incrementFrequency;
  @HiveField(11)
  int success = 0;
  @HiveField(12)
  int deloadFrequency;
  @HiveField(13)
  int deloadPercent;
  @HiveField(14)
  String note = "";
  @HiveField(15)
  bool bookmarked = false;

  // sets, reps, barWeight are optional parameters
  Exercise(
      this.name,
      this.barWeight,
      this.sets,
      this.reps,
      this.overload,
      this.incrementFrequency,
      this.increment,
      this.deload,
      this.deloadPercent,
      this.deloadFrequency
  );
}
