// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 1;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      fields[0] as String,
    )
      ..exercises = (fields[1] as List).cast<Exercise>()
      ..isInitialized = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises)
      ..writeByte(2)
      ..write(obj.isInitialized);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimerMapAdapter extends TypeAdapter<TimerMap> {
  @override
  final int typeId = 3;

  @override
  TimerMap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerMap(
      fields[0] as int,
      fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TimerMap obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerMapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlateAdapter extends TypeAdapter<Plate> {
  @override
  final int typeId = 4;

  @override
  Plate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plate(
      fields[0] as double,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Plate obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.number);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      fields[0] as String,
    )
      ..weight = fields[1] as double
      ..barWeight = fields[2] as double
      ..increment = fields[3] as double
      ..sets = fields[4] as int
      ..reps = fields[5] as int
      ..repsCompleted = (fields[6] as List).cast<int>()
      ..failed = fields[7] as int
      ..overload = fields[8] as bool
      ..deload = fields[9] as bool
      ..incrementFrequency = fields[10] as int
      ..success = fields[11] as int
      ..deloadFrequency = fields[12] as int
      ..deloadPercent = fields[13] as int
      ..note = fields[14] as String;
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.weight)
      ..writeByte(2)
      ..write(obj.barWeight)
      ..writeByte(3)
      ..write(obj.increment)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.repsCompleted)
      ..writeByte(7)
      ..write(obj.failed)
      ..writeByte(8)
      ..write(obj.overload)
      ..writeByte(9)
      ..write(obj.deload)
      ..writeByte(10)
      ..write(obj.incrementFrequency)
      ..writeByte(11)
      ..write(obj.success)
      ..writeByte(12)
      ..write(obj.deloadFrequency)
      ..writeByte(13)
      ..write(obj.deloadPercent)
      ..writeByte(14)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IndivWorkoutAdapter extends TypeAdapter<IndivWorkout> {
  @override
  final int typeId = 2;

  @override
  IndivWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IndivWorkout(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      (fields[3] as List).cast<String>(),
      (fields[4] as List).cast<double>(),
      (fields[5] as List).cast<int>(),
      (fields[6] as List).cast<int>(),
      (fields[7] as List).map((dynamic e) => (e as List).cast<int>()).toList(),
      fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IndivWorkout obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.sortableDate)
      ..writeByte(3)
      ..write(obj.exercisesCompleted)
      ..writeByte(4)
      ..write(obj.weights)
      ..writeByte(5)
      ..write(obj.repsPlanned)
      ..writeByte(6)
      ..write(obj.setsPlanned)
      ..writeByte(7)
      ..write(obj.repsCompleted)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndivWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
