import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String songID;
  final String songName;
  final String songFile;
  final String albumName;
  final String albumCover;
  final String artistName;
  final String trackNum;
  final String artistID;
  final String albumID;
  late final Timestamp? timestamp;

  Song(
      {required this.songID,
      required this.songName,
      required this.songFile,
      required this.albumName,
      required this.albumCover,
      required this.artistName,
      required this.trackNum,
      required this.artistID,
      required this.albumID,
      this.timestamp});

  factory Song.fromJson(Map<String, dynamic> parsedJson) {
    return Song(
      songID: parsedJson['songID'] ?? "",
      songName: parsedJson['songName'] ?? "",
      songFile: parsedJson['songFile'] ?? "",
      albumName: parsedJson['albumName'] ?? "",
      albumCover: parsedJson['albumCover'] ?? "",
      artistName: parsedJson['artistName'] ?? "",
      trackNum: parsedJson['trackNum'] ?? "",
      artistID: parsedJson['artistID'] ?? "",
      albumID: parsedJson['albumID'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songID': songID,
      'songName': songName,
      'songFile': songFile,
      'albumName': albumName,
      'albumCover': albumCover,
      'artistName': artistName,
      'trackNum': trackNum,
      'artistID': artistID,
      'albumID': albumID
    };
  }
}
