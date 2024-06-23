import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/tile_bottomsheet.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/pages/info_album.dart';
import 'package:music_app/pages/info_artist.dart';

class AlbumTile extends StatefulWidget {
  final Album album;
  final void Function()? onTap;
  final void Function()? moreVert;
  const AlbumTile({super.key, required this.album, this.onTap, this.moreVert});

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  final FirestoreService firestoreService = FirestoreService();

  bool check = false;

  late final Artist artist;

  @override
  void initState() {
    super.initState();
    // checkF();
    getAlbumArtist();
  }

  void checkF() async {
    bool tmp = await firestoreService.albumCheck(widget.album);
    if (!mounted) return;
    setState(() {
      check = tmp;
    });
  }

  void getAlbumArtist() async {
    DocumentSnapshot artistDoc =
        await firestoreService.artists.doc(widget.album.artistID).get();
    var artistData = artistDoc.data() as Map<String, dynamic>;
    if (!mounted) return;
    setState(() {
      artist = Artist(
          artistID: artistDoc.id,
          artistName: artistData['artistName'],
          artistProfile: artistData['artistProfile']);
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
                width: 65,
                height: 65,
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
              width: 10,
            ),
            Expanded(
              // decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.album.albumName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Album by ${widget.album.artistName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
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
                // songProvider.currentSong = widget.song;
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
                      child: CachedNetworkImage(
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        imageUrl: widget.album.albumCover,
                        // imageBuilder: (context, imageProvider) {
                        // },
                        placeholder: (context, url) =>
                            Image.asset('lib/assets/song.png'),
                        errorWidget: (context, url, error) =>
                            Image.asset('lib/assets/song.png'),
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
                            widget.album.albumName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Album by ${widget.album.artistName}',
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
                  !check
                      ? firestoreService.addToAlbums(widget.album)
                      : firestoreService.removeFromAlbums(widget.album);
                },
              ),
              SheetTile(
                icon: Icons.album_outlined,
                text: 'Go to album',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AlbumPage(
                      album: widget.album,
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
