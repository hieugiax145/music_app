import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/model/song_model.dart';

class FirestoreService {
  User? user;
  late final CollectionReference all;
  late final CollectionReference songs;
  late final CollectionReference albums;
  late final CollectionReference artists;
  late final CollectionReference playlists;
  late final CollectionReference myTracks;
  late final CollectionReference myAlbums;
  late final CollectionReference myArtists;
  late final CollectionReference history;
  late final CollectionReference search;

  FirestoreService() {
    user = FirebaseAuth.instance.currentUser;
    all = FirebaseFirestore.instance.collection('all');
    songs = FirebaseFirestore.instance.collection('songs');
    albums = FirebaseFirestore.instance.collection('albums');
    artists = FirebaseFirestore.instance.collection('artists');
    playlists = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .collection('playlists');
    myTracks = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .collection('tracks');
    myAlbums = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .collection('albums');
    myArtists = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .collection('artists');
    history = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .collection('history');
    search = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .collection('search');
  }

  Stream<QuerySnapshot> getPlaylistStream() {
    return playlists.snapshots();
  }

  Stream<QuerySnapshot> getPlaylistSongsStream(String docID) {
    return playlists.doc(docID).collection('songs').snapshots();
  }

  Stream<dynamic> getTracksStream() {
    return myTracks.snapshots();
  }

  Stream<dynamic> getAlbumsStream() {
    return myAlbums.snapshots();
  }

  Stream<dynamic> getArtistsStream() {
    return myArtists.snapshots();
  }

  Stream<dynamic> getHistory() {
    return history.snapshots();
  }

  Stream<dynamic> getSearch() {
    return search.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getImage(String docID) {
    return playlists.doc(docID).collection('songs').limit(4).snapshots();
  }

  Future<void> createPlaylist(String playlistName) async {
    await playlists.add({
      'playlistName': playlistName,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> addToPlaylist(Song song, String playlistID) async {
    await playlists.doc(playlistID).collection('songs').doc(song.songID).set({
      'songName': song.songName,
      'songFile': song.songFile,
      'albumName': song.albumName,
      'albumCover': song.albumCover,
      'artistName': song.artistName,
      'trackNum': song.trackNum,
      'artistID': song.artistID,
      'albumID': song.albumID,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> addToTracks(Song song) async {
    await myTracks.doc(song.songID).set({
      'songName': song.songName,
      'songFile': song.songFile,
      'albumName': song.albumName,
      'albumCover': song.albumCover,
      'artistName': song.artistName,
      'trackNum': song.trackNum,
      'artistID': song.artistID,
      'albumID': song.albumID,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> addToAlbums(Album album) async {
    await myAlbums.doc(album.albumID).set({
      'albumName': album.albumName,
      'albumCover': album.albumCover,
      'artistName': album.artistName,
      'yearRelease': album.yearRelease,
      'artistID': album.artistID,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> addToArtists(Artist artist) async {
    await myArtists.doc(artist.artistID).set({
      'artistName': artist.artistName,
      'artistProfile': artist.artistProfile,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> addToSearch(var data) async {
    if (data is Song) {
      await search.doc(data.songID).set({
        'name': data.songName,
        'songFile': data.songFile,
        'albumName': data.albumName,
        'albumCover': data.albumCover,
        'artistName': data.artistName,
        'trackNum': data.trackNum,
        'artistID': data.artistID,
        'albumID': data.albumID,
        'timestamp': FieldValue.serverTimestamp()
      });
    }
    if (data is Album) {
      await search.doc(data.albumID).set({
        'name': data.albumName,
        'albumCover': data.albumCover,
        'artistName': data.artistName,
        'yearRelease': data.yearRelease,
        'artistID': data.artistID,
        'timestamp': FieldValue.serverTimestamp()
      });
    }
    if (data is Artist) {
      await search.doc(data.artistID).set({
        'name': data.artistName,
        'artistProfile': data.artistProfile,
        'timestamp': FieldValue.serverTimestamp()
      });
    }
  }

  Future<void> renamePlaylist(String docID, String newName) async {
    try {
      await playlists.doc(docID).update({'playlistName': newName});
      print('Playlist name updated successfully');
    } catch (error) {
      print('Error updating playlist name: $error');
    }
  }

  Future<void> deletePlaylist(String docID) async {
    try {
      await playlists.doc(docID).delete();
      print('Playlist deleted successfully');
    } catch (error) {
      print('Error deleting playlist: $error');
    }
  }

  Future<void> removeFromPlaylist(String playlistID, String songID) async {
    try {
      await playlists.doc(playlistID).collection('songs').doc(songID).delete();
      print('Playlist deleted successfully');
    } catch (error) {
      print('Error deleting playlist: $error');
    }
  }

  Future<void> removeFromTracks(String songID) async {
    try {
      await myTracks.doc(songID).delete();
      print('Favourite deleted successfully');
    } catch (error) {
      print('Error deleting playlist: $error');
    }
  }

  Future<void> removeFromAlbums(Album album) async {
    try {
      await myAlbums.doc(album.albumID).delete();
      print('Favourite deleted successfully');
    } catch (error) {
      print('Error deleting playlist: $error');
    }
  }

  Future<void> removeFromArtists(Artist artist) async {
    try {
      await myArtists.doc(artist.artistID).delete();
      print('Favourite deleted successfully');
    } catch (error) {
      print('Error deleting playlist: $error');
    }
  }

  Future<int> getPlaylistLength(String id) async {
    QuerySnapshot tmp = await playlists.doc(id).collection('songs').get();
    return tmp.size;
  }

  Future<int> getTracksLength() async {
    QuerySnapshot tmp = await myTracks.get();
    return tmp.size;
  }

  Future<bool> trackCheck(String songID) async {
    try {
      DocumentSnapshot snapshot = await myTracks.doc(songID).get();
      return snapshot.exists;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> albumCheck(Album album) async {
    try {
      DocumentSnapshot snapshot = await myAlbums.doc(album.albumID).get();
      return snapshot.exists;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> artistCheck(String artistID) async {
    try {
      DocumentSnapshot snapshot = await myArtists.doc(artistID).get();
      return snapshot.exists;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
