import 'package:hive_flutter/hive_flutter.dart';
part 'timermap.g.dart';

// Hive doesn't work well with lists, so I'm making a custom class
@HiveType(typeId: 3)
class TimerMap extends HiveObject {
  @HiveField(0)
  int time;
  @HiveField(1)
  bool isChecked;

  TimerMap(this.time, this.isChecked);
}
