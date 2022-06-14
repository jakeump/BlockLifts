// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
