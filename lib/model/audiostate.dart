import 'package:flutter/material.dart';
import 'package:music_app/model/song_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioState extends ChangeNotifier {
  List<Song> songs = [
    Song(
        songID: '1',
        songName: 'Track 1',
        songFile:
            'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
        albumName: 'Album 1',
        albumCover:
            'https://cdn.hita.com.vn/storage/products/inax/pheu-thoat-san/FDV-12-avt.jpg',
        artistName: 'Artist 1',
        trackNum: '1',
        artistID: '1',
        albumID: '1'),
    Song(
        songID: '2',
        songName: 'Track 2',
        songFile:
            'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
        albumName: 'Album 2',
        albumCover:
            'https://cdn.hita.com.vn/storage/products/inax/pheu-thoat-san/FDV-12-avt.jpg',
        artistName: 'Artist 2',
        trackNum: '2',
        artistID: '2',
        albumID: '2'),
    Song(
        songID: '3',
        songName: 'Track 3',
        songFile:
            'https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3',
        albumName: 'Album 3',
        albumCover:
            'https://cdn.hita.com.vn/storage/products/inax/pheu-thoat-san/FDV-12-avt.jpg',
        artistName: 'Artist 3',
        trackNum: '3',
        artistID: '3',
        albumID: '3'),
  ];
  late AudioPlayer player;
  List<AudioSource> _audioSource = [];
  var _playlistMedia;

  AudioState() {
    _init();
  }

  Future<void> _init() async {
    player = AudioPlayer();
    _audioSource = getAudioSource();

    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      // logger.d('A stream error occurred: $e');
    });
    _playlistMedia = ConcatenatingAudioSource(children: _audioSource);
    try {
      await player.setAudioSource(_playlistMedia);
    } catch (e) {}
  }

  List<AudioSource> getAudioSource() {
    return songs
        .map((song) => AudioSource.uri(Uri.parse(song.songFile),
            tag: MediaItem(
                id: song.songID,
                title: song.songName,
                album: song.albumName,
                artist: song.artistName,
                artUri: Uri.parse(song.albumCover))))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }
}
