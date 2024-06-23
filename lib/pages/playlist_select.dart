import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/button_big.dart';
import 'package:music_app/components/playlist/tile_playlist.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/song_provider.dart';
import 'package:music_app/pages/playlist_create.dart';
import 'package:provider/provider.dart';

class PlaylistSelect extends StatefulWidget {
  final Song song;
  const PlaylistSelect({super.key, required this.song});

  @override
  State<PlaylistSelect> createState() => _PlaylistSelectState();
}

class _PlaylistSelectState extends State<PlaylistSelect> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic allPlaylistsProvider;

  @override
  void initState() {
    super.initState();
    allPlaylistsProvider =
        Provider.of<AllPlaylistsProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Select Playlist'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            BigButton(
                buttonText: 'Create playlist',
                ontap: () {
                  Navigator.of(context,rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (context) => const PlaylistCreate()));
                }),
            const SizedBox(
              height: 10,
            ),
            Consumer<AllPlaylistsProvider>(
              builder: (BuildContext context, AllPlaylistsProvider value,
                  Widget? child) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: value.allPlaylists.length,
                    itemBuilder: (context, index) {
                      var data = value.allPlaylists[index];
                      return PlaylistTile(
                        playlist: data,
                        onTap: () {
                          // Song song = songProvider.currentSong;
                          firestoreService.addToPlaylist(widget.song, data.playlistID);
                          Navigator.pop(context);
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            icon: const Icon(
                              Icons.done_outline_rounded,
                              color: Colors.white,
                            ),
                            title: "SUCCESSFUL",
                            message: "Added to your playlist",
                            duration: const Duration(milliseconds: 1500),
                            flushbarStyle: FlushbarStyle.FLOATING,
                            margin: const EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(12),
                            backgroundColor: Colors.green.shade600,
                          ).show(context);
                        },
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Flushbar(
//                                   flushbarPosition: FlushbarPosition.TOP,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 10),
//                                   icon: const Icon(
//                                     Icons.done_outline_rounded,
//                                     color: Colors.white,
//                                   ),
//                                   title: "SUCCESSFUL",
//                                   message: "Added to your playlist",
//                                   duration: const Duration(milliseconds: 2000),
//                                   flushbarStyle: FlushbarStyle.FLOATING,
//                                   margin: const EdgeInsets.all(10),
//                                   borderRadius: BorderRadius.circular(12),
//                                   backgroundColor: Colors.green.shade400,
//                                 ).show(context);
