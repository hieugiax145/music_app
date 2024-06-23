import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/song/tile_song_playlist.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  const PlaylistPage({super.key, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final FirestoreService firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  late final dynamic songsProvider;

  List<String> _imageUrls = [];
  // List<Song> playlist = [];
  int numOfTrack = 0;
  bool isDone = false;
  bool added=false;
  bool _showTitle = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    getNum();
    fetchImages();
    fetchData();
  }

  @override
  void dispose() {
    // Provider.of<SongsProvider>(context).dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    // fetchData();
    // fetchImages();
    // getNum();
    super.dispose();

  }

  void fetchData() async {
    QuerySnapshot querySnapshot = await firestoreService.playlists
        .doc(widget.playlist.playlistID)
        .collection('songs')
        .get();
    List<Song> songs = querySnapshot.docs.map((doc) {
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
      widget.playlist.songs = songs;
      isDone = true;
    });
  }

  void getNum() async {
    int tmp =
        await firestoreService.getPlaylistLength(widget.playlist.playlistID);
    if (!mounted) return;
    setState(() {
      numOfTrack = tmp;
    });
  }

  void fetchImages() async {
    try {
      QuerySnapshot snapshot =
          await firestoreService.getImage(widget.playlist.playlistID).first;
      List<String> urls = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        urls.add(data!['albumCover']);
      }
      if (!mounted) return;
      setState(() {
        _imageUrls = urls;
      });
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  // void fetchImages() {
  //   try {

  //     List<String> urls = [];

  //     playlist.forEach((doc) {
  //       urls.add(doc.albumCover);
  //     });

  //     setState(() {
  //       _imageUrls = urls;
  //     });
  //   } catch (e) {
  //     print("Error fetching images: $e");
  //   }
  // }

  List<Widget> buildGridTiles() {
    List<Widget> tiles = [];
    for (int i = 0; i < 4; i++) {
      if (i < _imageUrls.length) {
        // If there are images fetched, display image tiles
        tiles.add(Image.network(
          _imageUrls[i],
          fit: BoxFit.cover,
        ));
      } else {
        // If there are fewer images than tiles, display placeholder tiles
        tiles.add(const Placeholder());
      }
    }
    return tiles;
  }

  void _scrollListener() {
    setState(() {
      _showTitle =
          _scrollController.hasClients && _scrollController.offset > 300;
    });
  }

  Future<void> songClick(int index) async {
    // songsProvider.currentSongIndex = index;
    if (added == false) {
      await songsProvider.updatePlayList(widget.playlist.songs);
      setState(() {
        added = true;
      });
    }
    songsProvider.songHandler.skipToQueueItem(index);
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    fetchImages();
    // return Consumer<playingProvider>(
    //   builder: (BuildContext context, playingProvider value, Widget? child) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _showTitle ? Text(widget.playlist.title) : null,
        flexibleSpace: _showTitle
            ? ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        )
            : null,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // actions: [
        //   IconButton(
        //     icon:
        //     !isFollow ? Icon(Icons.add_rounded) : Icon(Icons.check_rounded),
        //     tooltip: 'Follow',
        //     onPressed: () {
        //       !isFollow
        //           ? firestoreService.addToArtists(widget.artist)
        //           : firestoreService.removeFromArtists(widget.artist);
        //     },
        //   ),
        // ],
        // actions: [const Icon(Icons.more_vert)],
      ),
      body: ListView(
        // padding: EdgeInsets.only(top: 0),
        // crossAxisAlignment: CrossAxisAlignment.start,
        controller: _scrollController,
        children: <Widget>[
          // Container(
          //   child:
          Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //       vertical: 20, horizontal: 20),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       InkWell(
              //         onTap: () {
              //           Navigator.pop(context);
              //         },
              //         child: const Icon(
              //           CupertinoIcons.back,
              //           size: 30,
              //         ),
              //       ),
              //       InkWell(
              //         onTap: () {},
              //         child: const Icon(
              //           Icons.more_vert,
              //           size: 30,
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  width: 180,
                  child: GridView.builder(
                    primary: false,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.playlist.songs.length == 1 ? 1 : 2,
                    ),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _imageUrls.length) {
                        // If there's an image URL available, display it

                        return CachedNetworkImage(
                          imageUrl: _imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      } else {
                        // If no image URL available, display a placeholder from assets
                        return Image.asset(
                          'lib/assets/track.png', // Replace with your placeholder image asset path
                          fit: BoxFit.cover,
                        );
                      }
                    },
                    // separatorBuilder: (BuildContext context, int index) {
                    // return SizedBox.shrink(); // Empty container as separator
                    // },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Text(
                    widget.playlist.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'by Me',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500
                        // fontWeight: FontWeight.bold,
                        // letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${widget.playlist.songs.length} tracks',
                    style: const TextStyle(
                      fontSize: 15,
                      // fontWeight: FontWeight.bold,
                      // letterSpacing: 1,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        // songsProvider.currentSongIndex = 0;
                        // songsProvider.addPlayList = widget.playlist.songs;
                        songClick(0);
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return const Player();
                        // }));
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 25,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Shuffle',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
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
                height: 20,
              ),
              // StreamBuilder(
              //   stream: firestoreService.getPlaylistSongsStream(widget.docID),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //     if (!snapshot.hasData) {
              //       return const Center(
              //         child: Text('No data'),
              //       );
              //     }
              //     playlist.clear();
              //     playlist = snapshot.data!.docs.toList();
              //     // value.addPlayList(playlist);
              //     // snapshot.data!.docs.forEach((element) {
              //     //   playlist.add(element.data() as Map<String, dynamic>);
              //     // });
              //     // playlist.sort((a, b) => int.parse(a['trackNum'])
              //     //     .compareTo(int.parse(b['trackNum'])));
              //     // print(playlist.length.toString()+value.playlist.length.toString());
              //     // playlist.forEach((element) {
              //     //   print(element['songFile']);
              //     // });
              //     playlist.forEach((song) {
              //       print(song['songName']);
              //     });
              //     // print("hello " + playlist.length.toString());
              //     // print(playingProvider.playlist.length);
              //     return ListView.builder(
              //         shrinkWrap: true,
              //         physics: NeverScrollableScrollPhysics(),
              //         itemCount: playlist.length,
              //         itemBuilder: (context, index) {
              //           var data = playlist[index];
              //           return SongTilePlaylist(
              //             song: Song(
              //                 songID: data.id,
              //                 songName: data['songName'],
              //                 songFile: data['songFile'],
              //                 albumName: data['albumName'],
              //                 albumCover: data['albumCover'],
              //                 artistName: data['artistName'],
              //                 trackNum: data['trackNum']),
              //             playlistID: widget.docID,
              //             onTap: () {
              //               playingProvider.currentSongIndex = index;
              //               playingProvider.addPlayList = playlist;
              //               Navigator.push(context,
              //                   MaterialPageRoute(builder: (context) {
              //                 return Player();
              //               }));
              //             },
              //           );
              //         });
              //   },
              // ),
              isDone && widget.playlist.songs.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.playlist.songs.length,
                      itemBuilder: (context, index) {
                        var data = widget.playlist.songs[index];
                        return SongTilePlaylist(
                          song: data,
                          playlist: widget.playlist,
                          onTap: () {
                            songClick(index);
                            // Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) {
                            //   return const Player();
                            // }));
                          },
                        );
                      })
                  : widget.playlist.songs.isEmpty
                      ? const Text('No tracks yet.')
                      : const Text('Loading...'),
            ],
          ),
        ],
      ),
    );
    //   },
    // );
  }
}
