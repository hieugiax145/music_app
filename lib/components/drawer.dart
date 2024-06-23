import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/history.dart';
import 'package:music_app/pages/setting.dart';
import 'package:music_app/pages/userdetail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/songsprovider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final user = FirebaseAuth.instance.currentUser!;
  late final dynamic songsProvider;

  @override
  void initState(){
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);

  }

  void logOut() async {
    songsProvider.songHandler.stop();

    songsProvider.resetPlaylist();
    // await songsProvider.updatePlayList([]);


    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('playlist');
    await preferences.clear();
    // print('clear all data');
    // print(preferences.getStringList('playlist'));
    // Provider.of<PlayingProvider>(context, listen: false).resetPlaylist();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Center(
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: ((context) => const UserDetail())));
                    },
                    icon: Icon(
                      Icons.supervised_user_circle,
                      size: 50,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
                Text(user.email.toString())
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Column(children: [
              ListTile(
                title: const Text('Listening history'),
                leading: const Icon(Icons.history_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => History()));
                },
              ),
              ListTile(
                title: const Text('Setting'),
                leading: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => const Setting()));
                },
              ),
              ListTile(
                title: const Text('Log out'),
                leading: const Icon(Icons.logout_rounded),
                onTap: () {
                  logOut();
                },
              ),
            ]),
          )
        ],
      ),
    );
  }
}
