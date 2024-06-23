import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/song/tile_song_album.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AlbumPage extends StatefulWidget {
  final Album album;
  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic playingProvider;
  late final dynamic songsProvider;
  bool added = false;

  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  List playlist = [];
  bool isDone = false;
  late bool isFollow = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    fetchData();
    checkF();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    fetchData();
    super.dispose();
  }

  Future<void> songClick(int index) async {
    // songsProvider.currentSongIndex = index;
    if (added == false) {
      await songsProvider.updatePlayList(widget.album.songs);
      setState(() {
        added = true;
      });
    }
    songsProvider.songHandler.skipToQueueItem(index);
  }

  void fetchData() async {
    QuerySnapshot querySnapshot = await firestoreService.songs
        .where('albumID', isEqualTo: widget.album.albumID)
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
      songs.sort(
          (a, b) => int.parse(a.trackNum).compareTo(int.parse(b.trackNum)));
      widget.album.songs = songs;
      isDone = true;
    });
  }

  void checkF() async {
    bool tmp = await firestoreService.albumCheck(widget.album);
    if (!mounted) return;
    setState(() {
      isFollow = tmp;
    });
  }

  void _scrollListener() {
    setState(() {
      _showTitle =
          _scrollController.hasClients && _scrollController.offset > 300;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkF();
    final screenWidth = MediaQuery.of(context).size.width;
    // return Consumer<PlayingProvider>(
    //   builder: (BuildContext context, PlayingProvider value, Widget? child) {
    // print(value.playlist.length.toString()+ ' heh');
    // print(value.currentSongIndex);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _showTitle ? Text(widget.album.albumName) : null,
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
        actions: [
          IconButton(
            icon:
                !isFollow ? const Icon(Icons.add_rounded) : const Icon(Icons.check_rounded),
            tooltip: 'Follow',
            onPressed: () {
              !isFollow
                  ? firestoreService.addToAlbums(widget.album)
                  : firestoreService.removeFromAlbums(widget.album);
            },
          ),
        ],
        // actions: [const Icon(Icons.more_vert)],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 0),
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                width: screenWidth,
                height: screenWidth,
                fit: BoxFit.cover,
                imageUrl: widget.album.albumCover,
                // imageBuilder: (context, imageProvider) {
                // },
                placeholder: (context, url) => Image.asset(
                  'lib/assets/album.png',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'lib/assets/album.png',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                // ),
              ),
              Container(
                width: screenWidth,
                height: screenWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.background.withOpacity(0.5),
                      Theme.of(context).colorScheme.background.withOpacity(0.8),
                      Theme.of(context).colorScheme.background,
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: kToolbarHeight * 1.5,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      imageUrl: widget.album.albumCover,
                      // imageBuilder: (context, imageProvider) {
                      // },
                      placeholder: (context, url) =>
                          Image.asset('lib/assets/album.png',color: Theme.of(context).colorScheme.secondary,),
                      errorWidget: (context, url, error) =>
                          Image.asset('lib/assets/album.png',color: Theme.of(context).colorScheme.secondary,),
                      // ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Text(
                        widget.album.albumName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Album by ${widget.album.artistName}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500
                            // fontWeight: FontWeight.bold,
                            // letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.album.yearRelease,
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
                            songClick(0);
                            // playingProvider.currentSongIndex = 0;
                            // playingProvider.addPlayList = widget.album.songs;
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return const Player();
                            // }));
                          },
                          child: Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.play_fill,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 25,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Play',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
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
                  isDone && widget.album.songs.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.album.songs.length,
                          itemBuilder: (context, index) {
                            var data = widget.album.songs[index];
                            // MediaItem songsss=songsProvider.list[index];
                            return SongTileAlbum(
                              song: data,
                              onTap: () {
                                songClick(index);
                                //
                                // Navigator.of(context, rootNavigator: true)
                                //     .push(MaterialPageRoute(
                                //         builder: (context) {
                                //   return const Player();
                                // }));
                              },
                            );
                          })
                      : const Text('Loading...'),
                ],
              )
            ],
          ),
        ],
      ),
      // body: CustomScrollView(
      //   controller: _scrollController,
      //   slivers: [
      //     SliverAppBar(
      //       pinned: true,
      //       backgroundColor: Colors.transparent,
      //       // expandedHeight: 100,
      //       flexibleSpace: ClipRect(
      //     child: _showTitle? BackdropFilter(
      //       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      //       child: Container(
      //         color: Colors.transparent,
      //       ),
      //     ):null,
      //   ),
      //       title: _showTitle ? Text(widget.album.albumName) : null,
      //     ),
      //     SliverToBoxAdapter(
      //       // child: ListView(
      //       //   // crossAxisAlignment: CrossAxisAlignment.start,
      //       //   children: <Widget>[
      //       // Container(
      //       // child:
      //       child: Column(
      //         // mainAxisSize: MainAxisSize.min,
      //         children: [
      //           Stack(
      //             children: [
      //               CachedNetworkImage(
      //               width:screenWidth,
      //               // height: 180,
      //               fit: BoxFit.fitWidth,
      //               imageUrl: widget.album.albumCover,
      //               // imageBuilder: (context, imageProvider) {
      //               // },
      //               placeholder: (context, url) =>
      //                   Image.asset('lib/assets/album.png'),
      //               errorWidget: (context, url, error) =>
      //                   Image.asset('lib/assets/album.png'),
      //               // ),
      //             ),
      //             ],
      //           ),
      //           SizedBox(
      //             height: 10,
      //           ),
      //           ClipRRect(
      //             borderRadius: BorderRadius.circular(12),
      //             child: CachedNetworkImage(
      //               width: 180,
      //               height: 180,
      //               fit: BoxFit.cover,
      //               imageUrl: widget.album.albumCover,
      //               // imageBuilder: (context, imageProvider) {
      //               // },
      //               placeholder: (context, url) =>
      //                   Image.asset('lib/assets/album.png'),
      //               errorWidget: (context, url, error) =>
      //                   Image.asset('lib/assets/album.png'),
      //               // ),
      //             ),
      //           ),
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           Column(
      //             children: [
      //               Text(
      //                 widget.album.albumName,
      //                 style: const TextStyle(
      //                   fontSize: 20,
      //                   fontWeight: FontWeight.bold,
      //                   letterSpacing: 1,
      //                 ),
      //               ),
      //               const SizedBox(
      //                 height: 5,
      //               ),
      //               Text(
      //                 'Album by ' + widget.album.artistName,
      //                 style: const TextStyle(
      //                     fontSize: 15, fontWeight: FontWeight.w500
      //                     // fontWeight: FontWeight.bold,
      //                     // letterSpacing: 1,
      //                     ),
      //               ),
      //               const SizedBox(
      //                 height: 5,
      //               ),
      //               Text(
      //                 widget.album.yearRelease,
      //                 style: const TextStyle(
      //                   fontSize: 15,
      //                   // fontWeight: FontWeight.bold,
      //                   // letterSpacing: 1,
      //                 ),
      //               )
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.symmetric(horizontal: 20),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceAround,
      //               children: [
      //                 InkWell(
      //                   onTap: () {
      //                     playingProvider.currentSongIndex = 0;
      //                     playingProvider.addPlayList = widget.album.songs;
      //                     Navigator.push(context,
      //                         MaterialPageRoute(builder: (context) {
      //                       return const Player();
      //                     }));
      //                   },
      //                   child: Container(
      //                     width: 150,
      //                     height: 40,
      //                     decoration: BoxDecoration(
      //                       color: Theme.of(context)
      //                           .colorScheme
      //                           .inversePrimary,
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Icon(
      //                           CupertinoIcons.play_fill,
      //                           color:
      //                               Theme.of(context).colorScheme.secondary,
      //                           size: 25,
      //                         ),
      //                         const SizedBox(
      //                           width: 5,
      //                         ),
      //                         Text(
      //                           'Play',
      //                           style: TextStyle(
      //                               fontSize: 16,
      //                               color: Theme.of(context)
      //                                   .colorScheme
      //                                   .secondary,
      //                               fontWeight: FontWeight.bold),
      //                         )
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //                 InkWell(
      //                   onTap: () {},
      //                   child: Container(
      //                     width: 150,
      //                     height: 40,
      //                     decoration: BoxDecoration(
      //                       color: Theme.of(context).colorScheme.primary,
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Icon(
      //                           CupertinoIcons.shuffle,
      //                           color: Theme.of(context)
      //                               .colorScheme
      //                               .inversePrimary,
      //                           size: 25,
      //                         ),
      //                         const SizedBox(
      //                           width: 5,
      //                         ),
      //                         Text(
      //                           'Shuffle',
      //                           style: TextStyle(
      //                               fontSize: 16,
      //                               color: Theme.of(context)
      //                                   .colorScheme
      //                                   .inversePrimary,
      //                               fontWeight: FontWeight.bold),
      //                         )
      //                       ],
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             ),
      //           ),
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           isDone && widget.album.songs.length != 0
      //               ? ListView.builder(
      //                   shrinkWrap: true,
      //                   physics: const NeverScrollableScrollPhysics(),
      //                   itemCount: widget.album.songs.length,
      //                   itemBuilder: (context, index) {
      //                     var data = widget.album.songs[index];
      //                     return SongTileAlbum(
      //                       song: data,
      //                       onTap: () {
      //                         playingProvider.currentSongIndex = index;
      //                         playingProvider.addPlayList =
      //                             widget.album.songs;
      //                         Navigator.push(context,
      //                             MaterialPageRoute(builder: (context) {
      //                           return const Player();
      //                         }));
      //                       },
      //                     );
      //                   })
      //               : const Text('Loading...'),
      //         ],
      //       ),
      //       //   ],
      //       // ),
      //     ),
      //   ],
      // ),
    );
    //   },
    // );
  }
}
