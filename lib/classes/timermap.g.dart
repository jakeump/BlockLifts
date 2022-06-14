// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timermap.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
