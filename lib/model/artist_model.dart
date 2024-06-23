import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  final String artistID;
  final String artistName;
  final String artistProfile;
  late final Timestamp? timestamp;

  Artist(
      {required this.artistID,
      required this.artistName,
      required this.artistProfile,
      this.timestamp});
}
