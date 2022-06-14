import 'package:audioplayers/audioplayers.dart';

void playRemoteFile() {
  AudioCache player = AudioCache();
  player.play("workout_alarm.mp3");
}
