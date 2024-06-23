import 'package:audio_service/audio_service.dart';
import 'package:music_app/model/playing_provider.dart';
import 'package:just_audio/just_audio.dart';

class AutioTask extends BaseAudioHandler{
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  MyAudioHandler() {
    _loadEmptyPlaylist();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {

  }
}