import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/drawer.dart';
import 'package:music_app/components/playlist/tile_playlist_square.dart';
import 'package:music_app/components/song/tile_song_small.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:provider/provider.dart';

import '../pages/player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirestoreService firestoreService = FirestoreService();
  // late final dynamic allPlaylistsProvider;
  // List<String> _imageUrls = [];
  List<Playlist> _playlists = [];
  List<Song> _exploreSongs = [];
  bool isDone = false;
  late final dynamic songsProvider;
  bool added=false;

  @override
  void initState() {
    super.initState();
    // allPlaylistsProvider=Provider.of<AllPlaylistsProvider>(context,listen:false);
    // playlists=allPlaylistsProvider.allPlaylists;
    fetchData();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
  }

  void fetchData() async {
    QuerySnapshot playlistSnapshot = await firestoreService.playlists.get();
    List<Playlist> pl = playlistSnapshot.docs
        .where((element) => element.reference.id != 'null')
        .map((doc) {
      return Playlist(
          playlistID: doc.id, title: doc['playlistName'], songs: []);
    }).toList();
    QuerySnapshot artistIDSnap = await firestoreService.myArtists.get();
    List artistIDs = artistIDSnap.docs
        .where((element) => element.reference.id != 'null')
        .map((e) => e.reference.id)
        .toList();
    QuerySnapshot exploreSnapshot = await firestoreService.songs
        .where('artistID', whereIn: artistIDs)
        .get();
    List<Song> expl = exploreSnapshot.docs.map((doc) {
      return Song(
          songID: doc.id,
          songName: doc['songName'],
          songFile: doc['songFile'],
          albumName: doc['albumName'],
          albumCover: doc['albumCover'],
          artistName: doc['artistName'],
          trackNum: doc['trackNum'],
          artistID: doc['artistID'],
          albumID: doc['albumID']);
    }).toList();
    List<Song> randomSongs =
        (List<Song>.from(expl)..shuffle()).take(5).toList();
    if (!mounted) return;
    setState(() {
      _playlists = pl;
      _exploreSongs = randomSongs;
      isDone = true;
    });
  }

  Future<void> songClick(int index) async {
    // songsProvider.currentSongIndex = index;
    if (added == false) {
      await songsProvider.updatePlayList(_exploreSongs);
      setState(() {
        added = true;
      });
    }
    songsProvider.songHandler.skipToQueueItem(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('HOME',style: TextStyle(fontWeight:FontWeight.bold),),
          leading: Builder(
            builder: (context) {
              return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.supervised_user_circle));
            },
          )),
      //   title: Text(_currentindex==0?'Home':_currentindex==2?'Library':''),
      // ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: () async{
          fetchData();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          // padding: EdgeInsets.only(top: 0),
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From your favourite artists',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  isDone
                      ? ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          // scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            // Song data=songs[index];
                            return SongTileSmall(onTap: () {
                              songClick(index);
                              Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const Player();
                              }));
                            }, song: _exploreSongs[index]);
                          })
                      : const SizedBox(),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(bottom: 10),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(20),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text(
            //               'Recently played',
            //               style: TextStyle(
            //                   fontSize: 20, fontWeight: FontWeight.bold),
            //             ),
            //           ],
            //         ),
            //       ),
            //       ListView.builder(
            //           padding: EdgeInsets.all(0),
            //           shrinkWrap: true,
            //           physics: NeverScrollableScrollPhysics(),
            //           // scrollDirection: Axis.horizontal,
            //           itemCount: 5,
            //           itemBuilder: (context, index) {
            //             // Song data=songs[index];
            //             return Container(
            //               // margin: EdgeInsets.symmetric(horizontal: 20),
            //               padding: const EdgeInsets.symmetric(
            //                   horizontal: 20, vertical: 5),
            //               // height: 90,
            //               child: Row(
            //                 children: [
            //                   ClipRRect(
            //                     borderRadius: BorderRadius.circular(10),
            //                     child: Image.asset(
            //                       'lib/assets/song.png',
            //                       width: 50,
            //                       height: 50,
            //                       fit: BoxFit.cover,
            //                       color: Theme.of(context).colorScheme.secondary,
            //                     ),
            //                   ),
            //                   const SizedBox(
            //                     width: 10,
            //                   ),
            //                 ],
            //               ),
            //             );
            //           }),
            //     ],
            //   ),
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'From your library',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 20),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (Playlist playlist in _playlists)
                        PlaylistTileSquare(playlist: playlist)
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Made for you',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
