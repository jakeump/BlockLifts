import 'package:hive_flutter/hive_flutter.dart';
part 'incrementssettings.g.dart';

// Hive doesn't work well with lists, so I'm making a custom class
@HiveType(typeId: 5)
class IncrementsSettings extends HiveObject {
  @HiveField(0)
  bool overload;
  @HiveField(1)
  int incrementFrequency;
  @HiveField(2)
  double increment;
  @HiveField(3)
  bool deload;
  @HiveField(4)
  int deloadPercent;
  @HiveField(5)
  int deloadFrequency;

  IncrementsSettings(this.overload, this.incrementFrequency, this.increment,
      this.deload, this.deloadPercent, this.deloadFrequency);
}
