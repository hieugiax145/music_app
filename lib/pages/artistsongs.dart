import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/song/tile_song.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:provider/provider.dart';

import '../model/songsprovider.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({super.key, required this.artist, required this.songs});

  final Artist artist;
  final List<Song> songs;

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic songsProvider;

  bool added = false;

  @override
  void initState() {
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
  }

  Future<void> songClick(int index) async {
    // songsProvider.currentSongIndex = index;
    if (added == false) {
      await songsProvider.updatePlayList(widget.songs);
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
          title: const Text('Tracks'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView.builder(
            itemCount: widget.songs.length,
            itemBuilder: ((context, index) {
              // Song data = songs[index];
              return SongTile(
                  onTap: () {
                    songClick(index);
                  },
                  song: widget.songs[index]);
              // Song data=snapshot.data!.docs[index];
            }))
        // }),
        );
  }
}
