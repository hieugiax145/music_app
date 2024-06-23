
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/tile_bottomsheet.dart';
import 'package:music_app/components/song/tile_song.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/pages/player.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MyTracks extends StatefulWidget {
  // String playlistName;
  const MyTracks({
    super.key,
  });

  @override
  State<MyTracks> createState() => _MyTracksState();
}

class _MyTracksState extends State<MyTracks> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic songsProvider;

  List<Song> songs = [];
  int numOfTrack = 0;
  bool isDone = false;
  bool added=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    // getNum();
    // fetchData();
  }

  @override
  void dispose() {
    fetchData();
    getNum();
    super.dispose();
    // fetchData();
    // getNum();
  }

  Future<void> songClick(int index) async {
    songsProvider.currentSongIndex = index;
    if (added == false) {
      await songsProvider.updatePlayList(songs);
      setState(() {
        added = true;
        // print('object');
      });
    }
    songsProvider.songHandler.skipToQueueItem(index);
  }

  void fetchData() async {
    QuerySnapshot querySnapshot = await firestoreService.myTracks.get();
    List<Song> tmp = querySnapshot.docs
        .where((element) => element.reference.id != 'null')
        .map((doc) {
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
    if (!mounted) return;
    setState(() {
      songs = tmp;
      isDone = true;
    });
  }

  void getNum() async {
    int tmp = await firestoreService.getTracksLength();
    if (!mounted) return;
    setState(() {
      numOfTrack = tmp - 1;
    });
  }

  int _currentSort = 1;
  List<String> sort = ['by name', 'by date added'];

  // void sortList() {
  //   _list.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
  // }

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
    // return Consumer<songsProvider>(
    // builder: (BuildContext context, songsProvider value, Widget? child) {
    return ListView(
      children: [
        // Container(
        //   child:
        // Column(
        //   // mainAxisSize: MainAxisSize.min,
        //   children: [
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
        // Text(
        //   playlist.length.toString() + ' tracks',
        //   style: const TextStyle(
        //     fontSize: 15,
        //     // fontWeight: FontWeight.bold,
        //     // letterSpacing: 1,
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  songClick(0);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return const Player();
                  // }));
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (context) {
                    return const Player();
                  }));
                },
                child: Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.play_fill,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Play',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.shuffle,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Shuffle',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        StreamBuilder(
            stream: firestoreService.myTracks
                .orderBy(_currentSort == 0 ? 'songName' : 'timestamp',
                    descending: _currentSort == 0 ? false : true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No results found.'));
              }
              songs = snapshot.data!.docs
                  .where((element) => element.reference.id != 'null')
                  .map((doc) {
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
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    var doc = songs[index];
                    return SongTile(
                      song: doc,
                      onTap: () {
                        songClick(index);
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (context) {
                          return const Player();
                        }));
                      },
                    );
                  });
            }),
        // isDone
        //     ? ListView.builder(
        //         shrinkWrap: true,
        //         physics: const NeverScrollableScrollPhysics(),
        //         itemCount: playlist.length,
        //         itemBuilder: (context, index) {
        //           var data = playlist[index];
        //           return SongTile(
        //             song: data,
        //             onTap: () {
        //               songsProvider.currentSongIndex = index;
        //               songsProvider.addPlayList = playlist;
        //               Navigator.push(context,
        //                   MaterialPageRoute(builder: (context) {
        //                 return const Player();
        //               }));
        //             },
        //           );
        //         })
        //     : Text('Loading...'),
      ],
      //   ),
      // ],
    );
    // },
    // );
  }
}
