// import 'dart:js';

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter_src/model/playing_provider.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:provider/provider.dart';

// class AudioPlayerTask extends BackgroundAudioTask {
//   late AudioPlayer _player;
//   final playlist=Provider.of<PlayingProvider>(context, listen: false);

//   @override
//   Future<void> onStart(Map<String, dynamic>? params) async {
//     final uri = params!['uri'] as String;
//     final title = params['title'] as String;
//     final artist = params['artist'] as String;
//     final coverUrl = params['coverUrl'] as String;

//     _player = AudioPlayer();
//     await _player.setUrl(uri);
//     await _player.play();
//     _player.processingStateStream.listen((state) {
//       AudioServiceBackground.setState(
//         playing: state == ProcessingState.ready ||
//             state == ProcessingState.buffering ||
//             state == ProcessingState.loading,
//         systemActions: [MediaAction.pause, MediaAction.stop],
//       );
//     });

//     AudioServiceBackground.setQueue([MediaItem(id: uri, title: title, artist: artist, artUri: Uri.parse(coverUrl))]);
//   }

//   @override
//   Future<void> onStop() async {
//     await _player.dispose();
//     await super.onStop();
//   }
// }
