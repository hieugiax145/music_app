import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/song_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayingProvider extends ChangeNotifier {
  List _playlist = [];
  List _tmpPlaylist = [];

  int? _currentSongIndex;

  void resetPlaylist() {
    _currentSongIndex=null;
    _playlist.clear();
    notifyListeners();
  }

  PlayingProvider(List save, int? idx) {
    // _playlist = save;
    // _currentSongIndex = idx;
    listenToDuration();
  }

  @override
  void dispose(){
    _audioPlayer.dispose();
    super.dispose();

  }

  final AudioPlayer _audioPlayer=AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  bool _isPlaying = false;
  bool _isNewSeason = false;

  bool _isShuffle = false;

  bool _isReplayOne = false;

  bool _isReplayAll = false;

  void play() async {
    late final Source path = UrlSource(_playlist[_currentSongIndex!].songFile);
    await _audioPlayer.stop();
    await _audioPlayer.play(path);
    _isPlaying = true;
    _isNewSeason = true;
    notifyListeners();
  }

  void stop() async{
    await _audioPlayer.stop();
    _isPlaying=false;
    notifyListeners();
  }

  void replay(){
    if(!_isReplayAll&&!_isReplayOne){
      _isReplayAll=true;
      // _isReplayOne=false;
    }
    else if(_isReplayAll&&!_isReplayOne){
      _isReplayAll=false;
      _isReplayOne=true;
    }
    else if(_isReplayOne){
      _isReplayAll=false;
      _isReplayOne=false;
    }
    notifyListeners();
  }

  // List shuffleList=playlist.shuffle();
  void shuffle() {
    _isShuffle = !_isShuffle;
    if (!_isShuffle) {
      // _isShuffle=false;
      _playlist = _tmpPlaylist;
    }
    if (_isShuffle) {
      // _isShuffle=true;
      _playlist = List.from(_playlist)
        ..replaceRange(_currentSongIndex! + 1, _playlist.length,
            (List.from(_playlist.sublist(_currentSongIndex! + 1))..shuffle()));
    }
    // _tmpPlaylist = List.from(_playlist)..replaceRange(1, _playlist.length, (List<int>.from(_playlist.sublist(1))..shuffle()));
    notifyListeners();
  }

  // void shuffleOrNot(){
  //   if(!_isShuffle) shuffle();
  //   else
  // }

  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() async {
    if (_isNewSeason == false)
      play();
    else {
      if (_isPlaying) {
        pause();
      } else {
        resume();
      }
    }

    notifyListeners();
  }

  void seek(Duration pos) async {
    await _audioPlayer.seek(pos);
    notifyListeners();
  }

  void playNextSong() {
    if (_currentSongIndex != null) {
      if (_currentSongIndex! < _playlist.length - 1) {
        if(_isReplayOne) play();
        else currentSongIndex = _currentSongIndex! + 1;
      } else {
        if(!_isReplayAll) stop();
        else if(_isReplayAll) currentSongIndex=0;
        else if(_isReplayOne) play();
      }
    }
  }

  void playPreviousSong() async {
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex! > 0) {
        currentSongIndex = _currentSongIndex! - 1;
      } else {
        currentSongIndex = _playlist.length - 1;
      }
    }
  }

  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  set addPlayList(List? newPlaylist) {
    _playlist = newPlaylist!;
    _tmpPlaylist = newPlaylist!;
    _savePlaylist();
    notifyListeners();
  }

  Song? get currentSong =>
      _currentSongIndex != null ? _playlist[_currentSongIndex!] : null;

  List get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  bool get isShuffle => _isShuffle;
  bool get isReplayALL=>_isReplayAll;
  bool get isReplayOne=>_isReplayOne;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex!;
    if (newIndex != null) {
      play();
    }
    _saveCurrentSOng();
    notifyListeners();
  }

  void _savePlaylist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistEncode =
        _playlist.map((song) => jsonEncode(song.toJson())).toList();
    await prefs.setStringList('playlist', playlistEncode);
  }

  void _saveCurrentSOng() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current', _currentSongIndex!);
  }
}

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_src/model/audiohandler.dart';
// import 'package:flutter_src/model/song_model.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:audio_service/audio_service.dart';

// class PlayingProvider extends ChangeNotifier {
//   List<Song> _playlist = [];
//   List<AudioSource> _audioSource=[];
//   var _playlistMedia;
//   late AudioPlayer player;

//   int? _currentSongIndex;

//   PlayingProvider(List<Song> save, int? idx) {
//     _playlist = save;
//     _currentSongIndex = idx;
//     _init();
//     // listenToDuration();
//   }

//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }

//   Future<void> _init() async{
//     player = AudioPlayer();
//     _audioSource=getAudioSource();
//     _playlistMedia=ConcatenatingAudioSource(children: _audioSource);
//     try{
//       await player.setAudioSource(_playlistMedia);
//     }
//     catch(e){

//     }
//     // notifyListeners();
//   }

//   List<AudioSource> getAudioSource() {
//     return _playlist
//         .map((song) => AudioSource.uri(Uri.parse(song.songFile),
//             tag: MediaItem(
//                 id: song.songFile,
//                 title: song.songName,
//                 album: song.albumName,
//                 artist: song.artistName,
//                 artUri: Uri.parse(song.albumCover))))
//         .toList();
//   }

//   void resetPlaylist() {
//     _currentSongIndex = null;
//     _playlist.clear();
//     notifyListeners();
//   }

//   Duration _currentDuration = Duration.zero;
//   Duration _totalDuration = Duration.zero;

//   bool _isPlaying = false;
//   bool _isNewSeason = false;

//   bool _isShuffle = false;

//   bool _isReplayOne = false;

//   bool _isReplayAll = false;

//   // void play()  {
//   //   // late final Uri uri = Uri.parse(_mediaItems[_currentSongIndex!].id);
//   //   // await player.setUrl(uri.toString());
//   //   // await player.play();

//   //   // _isPlaying = true;
//   //   // _isNewSeason = true;
//   //   notifyListeners();
//   // }

//   // void stop() async {
//   //   await player.stop();
//   //   _isPlaying = false;
//   //   notifyListeners();
//   // }

//   // void replay() {
//   //   if (!_isReplayAll && !_isReplayOne) {
//   //     _isReplayAll = true;
//   //   } else if (_isReplayAll && !_isReplayOne) {
//   //     _isReplayAll = false;
//   //     _isReplayOne = true;
//   //   } else if (_isReplayOne) {
//   //     _isReplayAll = false;
//   //     _isReplayOne = false;
//   //   }
//   //   notifyListeners();
//   // }

//   // void shuffle() {
//   //   _isShuffle = !_isShuffle;
//   //   if (!_isShuffle) {
//   //     _playlist = _tmpPlaylist;
//   //   }
//   //   if (_isShuffle) {
//   //     _playlist = List.from(_playlist)
//   //       ..replaceRange(_currentSongIndex! + 1, _playlist.length,
//   //           (List.from(_playlist.sublist(_currentSongIndex! + 1))..shuffle()));
//   //   }
//   //   notifyListeners();
//   // }

//   // void pause() async {
//   //   await player.pause();
//   //   _isPlaying = false;
//   //   notifyListeners();
//   // }

//   // void resume() async {
//   //   await player.play();
//   //   _isPlaying = true;
//   //   notifyListeners();
//   // }

//   // void pauseOrResume() async {
//   //   if (_isNewSeason == false)
//   //     play();
//   //   else {
//   //     if (_isPlaying) {
//   //       pause();
//   //     } else {
//   //       resume();
//   //     }
//   //   }

//   //   notifyListeners();
//   // }

//   void seek(Duration pos) async {
//     await player.seek(pos);
//     notifyListeners();
//   }

//   // void playNextSong() {
//   //   if (_currentSongIndex != null) {
//   //     if (_currentSongIndex! < _playlist.length - 1) {
//   //       if (_isReplayOne)
//   //         play();
//   //       else
//   //         currentSongIndex = _currentSongIndex! + 1;
//   //     } else {
//   //       if (!_isReplayAll)
//   //         stop();
//   //       else if (_isReplayAll)
//   //         currentSongIndex = 0;
//   //       else if (_isReplayOne) play();
//   //     }
//   //   }
//   // }

//   // void playPreviousSong() async {
//   //   if (_currentDuration.inSeconds > 2) {
//   //     seek(Duration.zero);
//   //   } else {
//   //     if (_currentSongIndex! > 0) {
//   //       currentSongIndex = _currentSongIndex! - 1;
//   //     } else {
//   //       currentSongIndex = _playlist.length - 1;
//   //     }
//   //   }
//   // }

//   // void listenToDuration() {
//   //   player.positionStream.listen((newPosition) {
//   //     _currentDuration = newPosition;
//   //     notifyListeners();
//   //   });

//   //   player.durationStream.listen((newDuration) {
//   //     _totalDuration = newDuration!;
//   //     notifyListeners();
//   //   });

//   //   player.playerStateStream.listen((playerState) {
//   //     if (playerState.playing) {
//   //       _isPlaying = true;
//   //     } else {
//   //       _isPlaying = false;
//   //     }
//   //     notifyListeners();
//   //   });

//   //   player.playerStateStream.listen((PlayerState state) {
//   //     if (state.processingState == ProcessingState.completed) {
//   //       playNextSong();
//   //     }
//   //   });
//   // }

//   set addPlayList(List<Song>? newPlaylist) {
//     _playlist = newPlaylist!;
//     // _tmpPlaylist = newPlaylist!;
//     // _audioSource=getAudioSource();
//     // _playlistMedia=ConcatenatingAudioSource(children: _audioSource);
//     _init();
//     // AudioServiceBackground.setQueue(getMediaItems());
//     _savePlaylist();
//     notifyListeners();
//   }

//   Song? get currentSong =>
//       _currentSongIndex != null ? _playlist[_currentSongIndex!] : null;

//   List get playlist => _playlist;
//   int? get currentSongIndex => _currentSongIndex;
//   bool get isPlaying => _isPlaying;
//   Duration get currentDuration => _currentDuration;
//   Duration get totalDuration => _totalDuration;
//   bool get isShuffle => _isShuffle;
//   bool get isReplayALL => _isReplayAll;
//   bool get isReplayOne => _isReplayOne;

//   set currentSongIndex(int? newIndex) {
//     _currentSongIndex = newIndex!;
//     if (newIndex != null) {
//       // play();
//     }
//     _saveCurrentSOng();
//     notifyListeners();
//   }

//   void _savePlaylist() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> playlistEncode =
//         _playlist.map((song) => jsonEncode(song.toJson())).toList();
//     await prefs.setStringList('playlist', playlistEncode);
//   }

//   void _saveCurrentSOng() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('current', _currentSongIndex!);
//   }
// }

// import 'dart:convert';

// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_src/model/song_model.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PlayingProvider extends ChangeNotifier {
//   List _playlist = [];
//   List _tmpPlaylist = [];

//   int? _currentSongIndex;

//   PlayingProvider(List save, int? idx) {
//     _playlist = save;
//     _currentSongIndex = idx;
//     // listenToDuration();
//   }

//   @override
//   void dispose() {
//     AudioService.stop();
//     super.dispose();
//   }

//   Duration _currentDuration = Duration.zero;
//   Duration _totalDuration = Duration.zero;

//   bool _isPlaying = false;
//   bool _isShuffle = false;
//   bool _isReplayOne = false;
//   bool _isReplayAll = false;

//   void play() async {
//     if (_currentSongIndex != null) {
//       late final Uri uri = Uri.parse(_playlist[_currentSongIndex!].songFile);
//       await AudioService.start(
//         backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
//         androidNotificationChannelName: 'Music',
//         androidNotificationIcon: 'drawable/ic_stat_music_note',
//       );
//       await AudioService.updateQueue(_queue);
//       // await AudioService.skipToQueueItem(_currentSongIndex!);
//       _isPlaying = true;
//       notifyListeners();
//     }
//   }

//   void stop() async {
//     await AudioService.stop();
//     _isPlaying = false;
//     notifyListeners();
//   }

//   void seek(Duration pos) async {
//     await AudioServic.seek(pos);
//     notifyListeners();
//   }

//   // void listenToDuration() {
//   //   AudioService.playbackStateStream.listen((state) {
//   //     if (state != null) {
//   //       _currentDuration = state.currentPosition;
//   //       _totalDuration = state.currentPosition;
//   //       _isPlaying = state.playing;
//   //       notifyListeners();
//   //     }
//   //   });
//   // }

//   void playNextSong() {
//     if (_currentSongIndex != null) {
//       if (_currentSongIndex! < _playlist.length - 1) {
//         if (_isReplayOne)
//           play();
//         else
//           currentSongIndex = _currentSongIndex! + 1;
//       } else {
//         if (!_isReplayAll)
//           stop();
//         else if (_isReplayAll)
//           currentSongIndex = 0;
//         else if (_isReplayOne) play();
//       }
//     }
//   }

//   void playPreviousSong() async {
//     if (_currentDuration.inSeconds > 2) {
//       await AudioService.seekTo(Duration.zero);
//     } else {
//       if (_currentSongIndex! > 0) {
//         currentSongIndex = _currentSongIndex! - 1;
//       } else {
//         currentSongIndex = _playlist.length - 1;
//       }
//     }
//   }

//   List<MediaItem> get _queue => _playlist
//       .map((song) => MediaItem(
//             id: song.id,
//             album: song.album,
//             title: song.title,
//             artist: song.artist,
//             duration: song.duration,
//             artUri: Uri.parse(song.artUrl),
//           ))
//       .toList();

//   set addPlayList(List? newPlaylist) {
//     _playlist = newPlaylist!;
//     _tmpPlaylist = newPlaylist;
//     notifyListeners();
//   }

//   Song? get currentSong =>
//       _currentSongIndex != null ? _playlist[_currentSongIndex!] : null;

//   List get playlist => _playlist;
//   int? get currentSongIndex => _currentSongIndex;
//   bool get isPlaying => _isPlaying;
//   Duration get currentDuration => _currentDuration;
//   Duration get totalDuration => _totalDuration;
//   bool get isShuffle => _isShuffle;
//   bool get isReplayALL => _isReplayAll;
//   bool get isReplayOne => _isReplayOne;

//   set currentSongIndex(int? newIndex) {
//     _currentSongIndex = newIndex;
//     if (newIndex != null) {
//       play();
//     }
//     notifyListeners();
//   }
// }

// void _backgroundTaskEntrypoint() {
//   AudioServiceBackground.run(() => AudioPlayerTask());
// }

// class AudioPlayerTask extends BackgroundAudioTask {
//   final _audioPlayer = AudioPlayer();

//   @override
//   Future<void> onStart(Map<String, dynamic>? params) async {
//     AudioServiceBackground.setQueue(_queue);
//     AudioServiceBackground.setState(
//       controls: [
//         MediaControl.pause,
//         MediaControl.stop,
//         MediaControl.skipToNext,
//         MediaControl.skipToPrevious,
//       ],
//       playing: true,
//       processingState: AudioProcessingState.buffering,
//       position: Duration.zero,
//     );
//     await _audioPlayer.setUrl(_queue.first.id);
//     await _audioPlayer.play();
//   }

//   @override
//   Future<void> onStop() async {
//     await _audioPlayer.stop();
//     AudioServiceBackground.setState(
//       controls: [],
//       playing: false,
//       processingState: AudioProcessingState.idle,
//     );
//     await super.onStop();
//   }

//   @override
//   Future<void> onPlay() async {
//     await _audioPlayer.play();
//     AudioServiceBackground.setState(
//       controls: [
//         MediaControl.pause,
//         MediaControl.stop,
//         MediaControl.skipToNext,
//         MediaControl.skipToPrevious,
//       ],
//       playing: true,
//       processingState: AudioProcessingState.ready,
//     );
//   }

//   @override
//   Future<void> onPause() async {
//     await _audioPlayer.pause();
//     AudioServiceBackground.setState(
//       controls: [
//         MediaControl.play,
//         MediaControl.stop,
//         MediaControl.skipToNext,
//         MediaControl.skipToPrevious,
//       ],
//       playing: false,
//       processingState: AudioProcessingState.ready,
//     );
//   }

//   @override
//   Future<void> onSkipToNext() async {
//     await AudioService.skipToNext();
//   }

//   @override
//   Future<void> onSkipToPrevious() async {
//     await AudioService.skipToPrevious();
//   }

//   @override
//   Future<void> onSeekTo(Duration position) async {
//     await _audioPlayer.seek(position);
//     AudioServiceBackground.setState(position: position);
//   }

//   List<MediaItem> get _queue => AudioServiceBackground.queue!;
// }

