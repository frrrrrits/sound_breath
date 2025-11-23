import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final player = AudioPlayer();

  static Future<void> playUrl(String url) async {
    await player.stop();
    await player.setUrl(url);
    await player.play();
  }
  static Stream<Duration?> get positionStream => player.positionStream;
  static Stream<PlayerState> get stateStream => player.playerStateStream;
}
