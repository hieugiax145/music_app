// import 'dart:js';

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_src/model/playing_provider.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:provider/provider.dart';

// class AudioPlayerTask extends BackgroundAudioTask with ChangeNotifier {
//   final _audioPlayer = AudioPlayer();
//   late List songList;
//   int current=0;

//   @override
//   Future<void> onStart(params) async {
//     AudioServiceBackground.setState(controls: [
//       MediaControl.pause,
//       MediaControl.stop,
//       MediaControl.skipToNext,
//       MediaControl.skipToPrevious
//     ], systemActions: [
//       MediaAction.seek
//     ], playing: true, processingState: AudioProcessingState.loading);
//     // Connect to the URL
//     await _audioPlayer.setUrl(mediaItem.id);
//     AudioServiceBackground.setMediaItem(mediaItem);
//     // Now we're ready to play
//     _audioPlayer.play();
//     // Broadcast that we're playing, and what controls are available.
//     AudioServiceBackground.setState(controls: [
//       MediaControl.pause,
//       MediaControl.stop,
//       MediaControl.skipToNext,
//       MediaControl.skipToPrevious
//     ], systemActions: [
//       MediaAction.seek
//     ], playing: true, processingState: AudioProcessingState.ready);
//   }

//   @override
//   Future<void> onStop() async {
//     AudioServiceBackground.setState(
//         controls: [],
//         playing: false,
//         processingState: AudioProcessingState.ready);
//     await _audioPlayer.stop();
//     await super.onStop();
//   }

//   @override
//   Future<void> onPlay() async {
//     AudioServiceBackground.setState(controls: [
//       MediaControl.pause,
//       MediaControl.stop,
//       MediaControl.skipToNext,
//       MediaControl.skipToPrevious
//     ], systemActions: [
//       MediaAction.seek
//     ], playing: true, processingState: AudioProcessingState.ready);
//     await _audioPlayer.play();
//     return super.onPlay();
//   }

//   @override
//   Future<void> onPause() async {
//     AudioServiceBackground.setState(controls: [
//       MediaControl.play,
//       MediaControl.stop,
//       MediaControl.skipToNext,
//       MediaControl.skipToPrevious
//     ], systemActions: [
//       MediaAction.seek
//     ], playing: false, processingState: AudioProcessingState.ready);
//     await _audioPlayer.pause();
//     return super.onPause();
//   }

//   @override
//   Future<void> onSkipToNext() async {
//     if (current < songList.length - 1)
//       current = current + 1;
//     else
//       current = 0;
//     mediaItem = MediaItem(
//         id: songList[current].url,
//         title: songList[current].name,
//         artUri: Uri.parse(songList[current].icon),
//         album: songList[current].album,
//         duration: songList[current].duration,
//         artist: songList[current].artist);
//     AudioServiceBackground.setMediaItem(mediaItem);
//     await _audioPlayer.setUrl(mediaItem.id);
//     AudioServiceBackground.setState(position: Duration.zero);
//     return super.onSkipToNext();
//   }

//   @override
//   Future<void> onSkipToPrevious() async {
//     if (current != 0)
//       current = current - 1;
//     else
//       current = songList.length - 1;
//     mediaItem = MediaItem(
//         id: songList[current].url,
//         title: songList[current].name,
//         artUri: Uri.parse(songList[current].icon),
//         album: songList[current].album,
//         duration: songList[current].duration,
//         artist: songList[current].artist);
//     AudioServiceBackground.setMediaItem(mediaItem);
//     await _audioPlayer.setUrl(mediaItem.id);
//     AudioServiceBackground.setState(position: Duration.zero);
//     return super.onSkipToPrevious();
//   }

//   @override
//   Future<void> onSeekTo(Duration position) {
//     _audioPlayer.seek(position);
//     AudioServiceBackground.setState(position: position);
//     return super.onSeekTo(position);
//   }
// }