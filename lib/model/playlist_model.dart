import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_app/model/song_model.dart';

class Playlist {
  final String playlistID;
  final String title;
  late List<Song> songs;
  late final Timestamp? timestamp;

  Playlist(
      {required this.playlistID,
      required this.title,
      required this.songs,
      this.timestamp});
}
