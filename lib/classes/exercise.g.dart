// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      fields[2] as double,
      fields[4] as int,
      fields[5] as int,
      fields[8] as bool,
      fields[10] as int,
      fields[3] as double,
      fields[9] as bool,
      fields[13] as int,
      fields[12] as int,
    )
      ..weight = fields[1] as double
      ..repsCompleted = (fields[6] as List).cast<int>()
      ..failed = fields[7] as int
      ..success = fields[11] as int
      ..note = fields[14] as String
      ..bookmarked = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(16)
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
      ..write(obj.note)
      ..writeByte(15)
      ..write(obj.bookmarked);
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
