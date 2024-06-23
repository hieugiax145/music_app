import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songhandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongsProvider extends ChangeNotifier {
  List<Song> _playlist = [];
  List<MediaItem> _list = [];
  int? _currentSongIndex;
  bool _isLoading = true;
  late SongHandler _songHandler;

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  SongsProvider(List<Song> saveSongs, int? idx, SongHandler songhandler) {
    _playlist = saveSongs;
    _currentSongIndex = idx;
    _songHandler = songhandler;
    // listenToDuration();
    // loadMediaItem(songHandler);
  }


  SongHandler get songHandler => _songHandler;
  List<Song> get playlist => _playlist;
  List<MediaItem> get list => _list;
  bool get isLoading => _isLoading;
  int get currentSongIndex => _currentSongIndex!;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  Song? get currentSong =>
      _currentSongIndex != null ? _playlist[_currentSongIndex!] : null;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex!;
    _saveCurrentSong();
    notifyListeners();
  }
  // void resetPlaylist(List<Song>? newL){
  //   _playlist=newL!;
  //   notifyListeners();
  // }

  Future<void> playNextSong() async {
    currentSongIndex = _currentSongIndex! + 1;
    await songHandler.skipToNext();
    // if (_currentSongIndex != null) {
    //   if (_currentSongIndex! < _playlist.length - 1) {
    //     if(_isReplayOne) play();
    //     else currentSongIndex = _currentSongIndex! + 1;
    //   } else {
    //     if(!_isReplayAll) stop();
    //     else if(_isReplayAll) currentSongIndex=0;
    //     else if(_isReplayOne) play();
    //   }
    // }
  }

  void playPreviousSong() async {
    currentSongIndex = _currentSongIndex! - 1;
    await songHandler.skipToPrevious();
    // if (_currentDuration.inSeconds > 2) {
    //   songHandler.seek(Duration.zero);
    // } else {
    //   if (_currentSongIndex! > 0) {
    //     currentSongIndex = _currentSongIndex! - 1;
    //   } else {
    //     currentSongIndex = _playlist.length - 1;
    //   }
    // }
  }

  void resetPlaylist() {
    _currentSongIndex = null;
    _playlist.clear();
    notifyListeners();
  }

  loadMediaItem() async {
    try {
      _list = _playlist
          .map((song) => MediaItem(
              id: song.songFile,
              title: song.songName,
              album: song.albumName,
              artist: song.artistName,
              artUri: Uri.parse(song.albumCover),extras:{'songID':song.songID}))
          .toList();

      await songHandler.initSongs(songs: _list);
      _isLoading = false;
      notifyListeners();
    } catch (e) {}
  }

  void listenToDuration() {
    songHandler.player.positionStream.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    songHandler.player.durationStream.listen((newDuration) {
      _totalDuration = newDuration!;
      notifyListeners();
    });
  }

  void updatePlayList(List<Song>? newPlaylist) async {
    _playlist = newPlaylist!;
    await loadMediaItem();
    _savePlaylist();
    notifyListeners();
  }

  void _savePlaylist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistEncode =
        _playlist.map((song) => jsonEncode(song.toJson())).toList();
    await prefs.setStringList('playlist', playlistEncode);
  }

  void _saveCurrentSong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current', _currentSongIndex!);
  }
}
