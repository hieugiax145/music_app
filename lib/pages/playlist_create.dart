import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/button_big.dart';
import 'package:music_app/components/textfield.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlaylistCreate extends StatefulWidget {
  const PlaylistCreate({super.key});

  @override
  State<PlaylistCreate> createState() => _PlaylistCreateState();
}

class _PlaylistCreateState extends State<PlaylistCreate> {
  final _playlistName = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic allPlaylistsProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allPlaylistsProvider =
        Provider.of<AllPlaylistsProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _playlistName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('New playlist'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'Name your playlist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
            const SizedBox(
              height: 10,
            ),
            MyTextField(
                input: _playlistName, obscure: false, hint: 'Playlist name'),
            const Spacer(),
            BigButton(
                buttonText: 'Create playlist',
                ontap: () {
                  firestoreService.createPlaylist(_playlistName.text);
                  Navigator.pop(context);
                  allPlaylistsProvider.fetchData();
                }),
          ],
        ),
      ),
    );
  }
}
