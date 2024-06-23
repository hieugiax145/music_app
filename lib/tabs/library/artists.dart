import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/artist/tile_artist.dart';
import 'package:music_app/components/tile_bottomsheet.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/pages/info_artist.dart';

class MyArtists extends StatefulWidget {
  const MyArtists({super.key});

  @override
  State<MyArtists> createState() => _MyArtistsState();
}

class _MyArtistsState extends State<MyArtists> {
  final FirestoreService firestoreService = FirestoreService();

  List<Album> _list = [];
  bool isDone = false;

  List<String> sort = ['by name', 'by date added'];

  int _currentSort = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchData();
  }

  @override
  void dispose() {
    fetchData();
    super.dispose();
    // fetchData();
  }

  void fetchData() async {
    QuerySnapshot querySnapshot = await firestoreService.myAlbums.get();
    List<Album> songs = querySnapshot.docs
        .where((element) => element.reference.id != 'null')
        .map((doc) {
      return Album(
          albumID: doc.id,
          albumName: doc['albumName'],
          albumCover: doc['albumCover'],
          artistName: doc['artistName'],
          artistID: doc['artistID'],
          yearRelease: doc['yearRelease'],
          timestamp: doc['timestamp']);
    }).toList();
    if (!mounted) return;
    setState(() {
      _list = songs;
      isDone = true;
    });
  }

  void sortList() {
    _list.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
  }

  void openBottomSheet(BuildContext context) {
    showModalBottomSheet(
        useRootNavigator: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: const Row(
                  children: [
                    Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              SheetTile(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentSort = 0;
                    });
                  },
                  icon: Icons.abc_rounded,
                  text: 'By name'),
              SheetTile(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentSort = 1;
                    });
                  },
                  icon: Icons.date_range_rounded,
                  text: 'By date added'),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // fetchData();
    // sortList();
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            openBottomSheet(context);
          },
          child: Container(
            // color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  'Sorted ${sort[_currentSort]}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        StreamBuilder(
            stream: firestoreService.myArtists
                
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No results found.'));
              }
              List<Artist> artists = snapshot.data!.docs
                  .where((element) => element.reference.id != 'null')
                  .map((doc) {
                return Artist(
                    artistID: doc.id,
                    artistName: doc['artistName'],
                    artistProfile: doc['artistProfile']);
              }).toList();
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    var doc = artists[index];
                    return ArtistTile(
                      artist: doc,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ArtistPage(
                            artist: doc,
                          );
                        }));
                      },
                    );
                  });
            }),
        // isDone
        //     ? ListView.builder(
        //         shrinkWrap: true,
        //         physics: const NeverScrollableScrollPhysics(),
        //         itemCount: _list.length,
        //         itemBuilder: (context, index) {
        //           var data = _list[index];
        //           print(_currentSort);
        //           return AlbumTile(
        //             album: data,
        //             onTap: () {
        //               Navigator.push(context,
        //                   MaterialPageRoute(builder: (context) {
        //                 return AlbumPage(
        //                   album: data,
        //                 );
        //               }));
        //             },
        //           );
        //         })
        //     : Text('Loading...'),
        // Lis
      ],
    );
  }
}
