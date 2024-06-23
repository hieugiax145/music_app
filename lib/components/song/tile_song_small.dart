import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/tile_bottomsheet.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/song_provider.dart';
import 'package:music_app/pages/info_album.dart';
import 'package:music_app/pages/info_artist.dart';
import 'package:music_app/pages/playlist_select.dart';
import 'package:provider/provider.dart';

class SongTileSmall extends StatefulWidget {
  final Song song;
  final void Function()? onTap;
  final void Function()? moreVert;

  const SongTileSmall({
    super.key,
    required this.song,
    this.onTap,
    this.moreVert,
  });

  @override
  State<SongTileSmall> createState() => _SongTileSmallState();
}

class _SongTileSmallState extends State<SongTileSmall> {
  final FirestoreService firestoreService = FirestoreService();

  bool check = false;

  late final Album album;
  late final Artist artist;

  @override
  void initState() {
    super.initState();
    checkF();
    getAlbumArtist();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getAlbumArtist() async {
    DocumentSnapshot artistDoc =
        await firestoreService.artists.doc(widget.song.artistID).get();
    DocumentSnapshot albumDoc =
        await firestoreService.albums.doc(widget.song.albumID).get();
    var artistData = artistDoc.data() as Map<String, dynamic>;
    var albumData = albumDoc.data() as Map<String, dynamic>;
    if (!mounted) return;
    setState(() {
      artist = Artist(
          artistID: artistDoc.id,
          artistName: artistData['artistName'],
          artistProfile: artistData['artistProfile']);
      album = Album(
          albumID: albumDoc.id,
          albumName: albumData['albumName'],
          albumCover: albumData['albumCover'],
          artistName: albumData['artistName'],
          yearRelease: albumData['yearRelease'],
          artistID: albumData['artistID']);
    });
  }

  void checkF() async {
    bool tmp = await firestoreService.trackCheck(widget.song.songID);
    if (!mounted) return;
    setState(() {
      check = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkF();
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        // height: 90,
        decoration: const BoxDecoration(
            // color: Colors.amber,
            ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                imageUrl: widget.song.albumCover,
                // imageBuilder: (context, imageProvider) {
                // },
                placeholder: (context, url) =>
                    // const CircularProgressIndicator(),
                    Image.asset(
                  'lib/assets/song.png',
                  color: Theme.of(context).colorScheme.secondary,
                ),

                errorWidget: (context, url, error) => Image.asset(
                  'lib/assets/song.png',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.songName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Track by ${widget.song.artistName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Spacer(),
            const SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                openBottomSheet(context);
              },
              child: const Icon(
                Icons.more_vert,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // child: FadeInImage.assetNetwork(
                      //   placeholder: 'lib/assets/song.png',
                      //   image: widget.albumCover,
                      //   fit: BoxFit.cover,
                      //   width: 80,
                      //   height: 80,
                      //   placeholderColor: Theme.of(context)
                      //       .colorScheme
                      //       .inversePrimary,
                      child: CachedNetworkImage(
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        imageUrl: widget.song.albumCover,
                        // imageBuilder: (context, imageProvider) {
                        // },
                        placeholder: (context, url) =>
                            Image.asset('lib/assets/song.png',color: Theme.of(context).colorScheme.secondary,),
                        errorWidget: (context, url, error) =>
                            Image.asset('lib/assets/song.png',color: Theme.of(context).colorScheme.secondary,),
                        // ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      // decoration: BoxDecoration(color: Colors.blue),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.song.songName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Track by ${widget.song.artistName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              SheetTile(
                icon: !check
                    ? CupertinoIcons.heart
                    : CupertinoIcons.heart_slash_fill,
                text: !check ? 'Add to favourite' : 'Remove from favourite',
                onTap: () {
                  Navigator.pop(context);
                  if(check){
                    firestoreService.removeFromTracks(widget.song.songID);
                    Flushbar(
                      flushbarPosition: FlushbarPosition.TOP,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      icon: const Icon(
                        Icons.done_outline_rounded,
                        color: Colors.white,
                      ),
                      title: "SUCCESSFUL",
                      message: "Removed from your collection",
                      duration: const Duration(milliseconds: 1500),
                      flushbarStyle: FlushbarStyle.FLOATING,
                      margin: const EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: Colors.red.shade600,
                    ).show(context);
                  }
                  else{
                    firestoreService.addToTracks(widget.song);
                    Flushbar(
                      flushbarPosition: FlushbarPosition.TOP,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      icon: const Icon(
                        Icons.done_outline_rounded,
                        color: Colors.white,
                      ),
                      title: "SUCCESSFUL",
                      message: "Added to your collection",
                      duration: const Duration(milliseconds: 1500),
                      flushbarStyle: FlushbarStyle.FLOATING,
                      margin: const EdgeInsets.all(10),
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: Colors.green.shade600,
                    ).show(context);
                  }
                  // !check
                  //     ? firestoreService.addToTracks(widget.song)
                  //     : firestoreService.removeFromTracks(widget.song.songID);
                },
              ),
              SheetTile(
                icon: CupertinoIcons.add_circled,
                text: 'Add to playlist',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                          builder: (context) => PlaylistSelect(
                                song: widget.song,
                              )));
                },
              ),
              SheetTile(
                icon: Icons.album_outlined,
                text: 'Go to album',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AlbumPage(
                      album: album,
                    );
                  }));
                },
              ),
              SheetTile(
                icon: Icons.person_outlined,
                text: 'Go to artist',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ArtistPage(artist: artist);
                  }));
                },
              ),
            ],
          );
        });
  }
}
