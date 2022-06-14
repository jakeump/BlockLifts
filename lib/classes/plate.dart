import 'package:hive_flutter/hive_flutter.dart';
part 'plate.g.dart';

@HiveType(typeId: 4)
class Plate extends HiveObject {
  @HiveField(0)
  double weight;
  @HiveField(1)
  int number;

  Plate(this.weight, this.number);
}
