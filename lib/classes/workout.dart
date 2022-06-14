import 'package:hive_flutter/hive_flutter.dart';
import 'package:blocklifts/classes/exercise.dart';
part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  String name; // workout name (like "Workout A")
  @HiveField(1)
  List<Exercise> exercises = []; // List of workouts (bench, squat, curl, etc)
  @HiveField(2)
  bool isInitialized = false; // used to fill the reps completed only once

  Workout(this.name); // constructor for name
}
