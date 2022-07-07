// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incrementssettings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncrementsSettingsAdapter extends TypeAdapter<IncrementsSettings> {
  @override
  final int typeId = 5;

  @override
  IncrementsSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IncrementsSettings(
      fields[0] as bool,
      fields[1] as int,
      fields[2] as double,
      fields[3] as bool,
      fields[4] as int,
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, IncrementsSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.overload)
      ..writeByte(1)
      ..write(obj.incrementFrequency)
      ..writeByte(2)
      ..write(obj.increment)
      ..writeByte(3)
      ..write(obj.deload)
      ..writeByte(4)
      ..write(obj.deloadPercent)
      ..writeByte(5)
      ..write(obj.deloadFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncrementsSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
