import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/album/tile_album_square.dart';
import 'package:music_app/components/song/tile_song.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/pages/artistalbums.dart';
import 'package:music_app/pages/artistsongs.dart';
import 'package:provider/provider.dart';

class ArtistPage extends StatefulWidget {
  final Artist artist;

  const ArtistPage({super.key, required this.artist});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic playingProvider;
  late final dynamic songsProvider;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  List<Song> songs = [];
  List<Album> albums = [];
  bool isDone = false;
  bool isFollow = false;
  bool added = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // playingProvider = Provider.of<PlayingProvider>(context, listen: false);
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    fetchData();
    checkF();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    // fetchData();
    // checkF();
    super.dispose();
  }

  Future<void> songClick(int index) async {
    // songsProvider.currentSongIndex = index;
    if (added == false) {
      await songsProvider.updatePlayList(songs);
      setState(() {
        added = true;
      });
    }
    songsProvider.songHandler.skipToQueueItem(index);
  }

  void fetchData() async {
    QuerySnapshot songSnapshot = await firestoreService.songs
        .where('artistID', isEqualTo: widget.artist.artistID)
        .get();
    List<Song> lsongs = songSnapshot.docs.map((doc) {
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

    QuerySnapshot albumSnapshot = await firestoreService.albums
        .where('artistID', isEqualTo: widget.artist.artistID)
        .get();
    List<Album> lalbums = albumSnapshot.docs.map((doc) {
      return Album(
          albumID: doc.id,
          albumName: doc['albumName'],
          albumCover: doc['albumCover'],
          artistName: doc['artistName'],
          artistID: doc['artistID'],
          yearRelease: doc['yearRelease']);
    }).toList();
    if (!mounted) return;
    setState(() {
      // songs.sort(
      //     (a, b) => int.parse(a.trackNum).compareTo(int.parse(b.trackNum)));
      songs = lsongs;
      albums = lalbums;
      isDone = true;
    });
  }

  void checkF() async {
    bool tmp = await firestoreService.artistCheck(widget.artist.artistID);
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
    final screenWidth = MediaQuery.of(context).size.width;
    checkF();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _showTitle ? Text(widget.artist.artistName) : null,
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
                  ? firestoreService.addToArtists(widget.artist)
                  : firestoreService.removeFromArtists(widget.artist);
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
                imageUrl: widget.artist.artistProfile,
                // imageBuilder: (context, imageProvider) {
                // },
                placeholder: (context, url) =>
                    Image.asset('lib/assets/artist.png'),
                errorWidget: (context, url, error) =>
                    Image.asset('lib/assets/artist.png'),
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
                      Theme.of(context).colorScheme.background.withOpacity(0.2),
                      Theme.of(context).colorScheme.background.withOpacity(0.3),
                      Theme.of(context).colorScheme.background.withOpacity(0.3),
                      Theme.of(context).colorScheme.background.withOpacity(0.4),
                      Theme.of(context).colorScheme.background.withOpacity(0.5),
                      Theme.of(context).colorScheme.background.withOpacity(0.5),
                      Theme.of(context).colorScheme.background.withOpacity(0.8),
                      Theme.of(context).colorScheme.background,
                    ],
                  ),
                ),
              ),
              Column(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenWidth - kToolbarHeight * 3,
                  ),
                  Text(
                    widget.artist.artistName,
                    style:
                        const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      !isFollow
                          ? firestoreService.addToArtists(widget.artist)
                          : firestoreService.removeFromArtists(widget.artist);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !isFollow
                            ? const Icon(Icons.add_rounded)
                            : const Icon(
                                Icons.check_rounded,
                                color: Color.fromARGB(255, 16, 132, 227),
                              ),
                        !isFollow
                            ? const Text(
                                'Follow',
                                style: TextStyle(fontSize: 15),
                              )
                            : const Text(
                                'Following',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 80, 160, 226)),
                              )
                      ],
                    ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tracks',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => AllSongs(
                                                artist: widget.artist,
                                                songs: songs,
                                              ))));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  child: const Text(
                                    'View all',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                            padding: const EdgeInsets.all(0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              // Song data=songs[index];
                              return isDone && songs.isNotEmpty
                                  ? SongTile(
                                      song: songs[index],
                                      onTap: () {
                                        songClick(index);
                                      },
                                    )
                                  : Container(
                                      // margin: EdgeInsets.symmetric(horizontal: 20),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      // height: 90,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'lib/assets/song.png',
                                              width: 65,
                                              height: 65,
                                              fit: BoxFit.cover,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    );
                            }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Albums',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              // ElevatedButton(onPressed: (){}, child: Text('View all'),style: ButtonStyle(padding:),),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) => AllAlbums(
                                                artist: widget.artist,
                                                albums: albums,
                                              ))));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  child: const Text(
                                    'View all',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(left: 20),
                          scrollDirection: Axis.horizontal,
                          child: isDone
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (Album album in albums)
                                      ALbumTileSquare(album: album),
                                    for (Album album in albums)
                                      ALbumTileSquare(album: album),
                                    for (Album album in albums)
                                      ALbumTileSquare(album: album),
                                    for (Album album in albums)
                                      ALbumTileSquare(album: album),
                                  ],
                                )
                              : SizedBox(
                                  width: 160,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          'lib/assets/album.png',
                                          width: 160,
                                          height: 160,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      // Spacer(),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
