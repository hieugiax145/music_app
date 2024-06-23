import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/button_big.dart';
import 'package:music_app/components/playlist/tile_playlist.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_model.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/pages/info_playlist.dart';
import 'package:music_app/pages/playlist_create.dart';
import 'package:provider/provider.dart';

import '../../components/tile_bottomsheet.dart';

class MyPlaylist extends StatefulWidget {
  const MyPlaylist({super.key});

  @override
  State<MyPlaylist> createState() => _MyPlaylistState();
}

class _MyPlaylistState extends State<MyPlaylist> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic allPlaylistsProvider;

  bool isDone = false;

  List<Playlist> playlists = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allPlaylistsProvider =
        Provider.of<AllPlaylistsProvider>(context, listen: false);
    // playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    // fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    // fetchData();
  }

  // void fetchData() async {
  //   QuerySnapshot querySnapshot = await firestoreService.playlists.get();
  //   List<Playlist> tmp = querySnapshot.docs
  //       .where((element) => element.reference.id != 'null')
  //       .map((doc) {
  //     return Playlist(
  //         playlistID: doc.id, title: doc['playlistName'], songs: []);
  //   }).toList();
  //   if (!mounted) return;
  //   setState(() {
  //     playlists = tmp;
  //     isDone = true;
  //   });
  // }

  int _currentSort = 1;
  List<String> sort = ['by name', 'by date added'];

  // void sortList() {
  //   _list.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
  // }

  @override
  Widget build(BuildContext context) {
    // fetchData();
    // return Consumer<AllPlaylistsProvider>(
    //   builder:
    //       (BuildContext context, AllPlaylistsProvider value, Widget? child) {
    //     List<Playlist> playlists = value.allPlaylists;
        return Scaffold(
          body: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  openBottomSheet(context);
                },
                child: Container(
                  // color: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        'Sorted ${sort[_currentSort]}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  BigButton(
                      buttonText: 'Create playlist',
                      ontap: () {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => const PlaylistCreate()));
                      }),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  const SizedBox(
                    height: 10,
                  ),
                  //
                  StreamBuilder(
                      stream: firestoreService.playlists
                          .orderBy(_currentSort == 0 ? 'playlistName' : 'timestamp',
                              descending: _currentSort == 0 ? false : true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: Text('Loading...'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No results found.'));
                        }
                        playlists = snapshot.data!.docs
                            .where((element) => element.reference.id != 'null')
                            .map((doc) {
                          return Playlist(
                              playlistID: doc.id,
                              title: doc['playlistName'],
                              songs: []);
                        }).toList();
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: playlists.length,
                            itemBuilder: (context, index) {
                              var data = playlists[index];
                              // print(data.songs.length.toString()+' '+data.title);
                              return PlaylistTile(
                                playlist: data,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PlaylistPage(playlist: data)));
                                },
                              );
                            });
                      }),
                  // ListView.builder(
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     itemCount: playlists.length,
                  //     itemBuilder: (context, index) {
                  //       var data = playlists[index];
                  //       // print(data.songs.length.toString()+' '+data.title);
                  //       return PlaylistTile(
                  //         playlist: data,
                  //         onTap: () {
                  //           Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       PlaylistPage(playlist: data)));
                  //         },
                  //       );
                  //     })
                ],
              ),
            ],
          ),
        );
    //   },
    // );
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
}
