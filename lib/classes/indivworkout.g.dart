// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indivworkout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, IndivWorkout obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.bodyWeight);
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
