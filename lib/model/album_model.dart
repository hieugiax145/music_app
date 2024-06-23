import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_app/model/song_model.dart';

class Album {
  final String albumID;
  final String albumName;
  final String albumCover;
  final String artistName;
  final String yearRelease;
  final String artistID;
  late final Timestamp? timestamp;
  late List<Song> songs;

  Album({
    required this.albumID,
    required this.albumName,
    required this.albumCover,
    required this.artistName,
    required this.yearRelease,
    required this.artistID,
    this.timestamp
  });
}
