import 'package:audioplayers/audioplayers.dart';

void playRemoteFile() {
  AudioPlayer player = AudioPlayer();
  player.play(AssetSource("workout_alarm.mp3"));
}
