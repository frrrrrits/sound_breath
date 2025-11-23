import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  static final player = AudioPlayer();

  static Future<void> playUrl(String url) async {
    await player.stop();
    await player.play(UrlSource(url));
  }
}
