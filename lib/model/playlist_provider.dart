import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_model.dart';

class AllPlaylistsProvider extends ChangeNotifier {
  final FirestoreService firestoreService = FirestoreService();

  List<Playlist> _allPlaylists = [];

  List<Playlist> get allPlaylists => _allPlaylists;

  void addPlaylists(List<Playlist>? newPlaylists) {
    _allPlaylists = newPlaylists!;
    notifyListeners();
  }

  void fetchData() async {
    QuerySnapshot querySnapshot = await firestoreService.playlists.get();
    List<Playlist> tmp = querySnapshot.docs
        .where((element) => element.reference.id != 'null')
        .map((doc) {
      return Playlist(
          playlistID: doc.id, title: doc['playlistName'], songs: []);
    }).toList();
    _allPlaylists = tmp;
    notifyListeners();
  }
}
