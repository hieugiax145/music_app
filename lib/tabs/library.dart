import 'package:flutter/material.dart';
import 'package:music_app/components/drawer.dart';
import 'package:music_app/tabs/library/albums.dart';
import 'package:music_app/tabs/library/artists.dart';
import 'package:music_app/tabs/library/playlists.dart';
import 'package:music_app/tabs/library/songs.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    // fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    // fetchData();
  }

  List<String> items = ['Playlists', 'Albums', 'Tracks', 'Artists'];

  @override
  Widget build(BuildContext context) {
    // fetchData();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            title: const Text('LIBRARY',style: TextStyle(fontWeight:FontWeight.bold),),
            leading: Builder(
              builder: (context) {
                return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.supervised_user_circle));
              },
            ),
            actions: const [],
            bottom: TabBar(
                dividerColor:  Theme.of(context).colorScheme.secondary,
                tabAlignment: TabAlignment.start,
                // labelPadding: EdgeInsets.only(left: 0, right: 0),
                isScrollable: true,
                tabs: const [
                  Tab(
                    text: 'Playlists',
                  ),
                  Tab(
                    text: 'Tracks',
                  ),
                  Tab(
                    text: 'Albums',
                  ),
                  Tab(
                    text: 'Artists',
                  ),
                ]),
          ),
          drawer: const MyDrawer(),
          // body: Container(
          //   margin: EdgeInsets.all(5),
          //   child: Column(
          //     children: [
          //       SizedBox(
          //         height: 60,
          //         // width: double.infinity,
          //         child: ListView.builder(
          //           scrollDirection: Axis.horizontal,
          //           itemCount: items.length,
          //           itemBuilder: (BuildContext context, int index) {
          //             return GestureDetector(
          //               onTap: () {
          //                 setState(() {
          //                   _currentIndex = index;
          //                 });
          //               },
          //               child: AnimatedContainer(
          //                 duration: Duration(milliseconds: 300),
          //                 margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //                 width: 80,
          //                 height: 45,
          //                 decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(12),
          //                     // border: Border.all(color: Colors.black),
          //                     color: _currentIndex == index
          //                         ? Theme.of(context).colorScheme.inversePrimary
          //                         : Theme.of(context).colorScheme.secondary),
          //                 child: Center(
          //                     child: Text(
          //                   items[index],
          //                   style: TextStyle(
          //                       fontSize: 20,
          //                       color: _currentIndex == index
          //                           ? Theme.of(context).colorScheme.secondary
          //                           : Theme.of(context).colorScheme.primary),
          //                 )),
          //               ),
          //             );
          //           },
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          body: TabBarView(
              children: [const MyPlaylist(), MyTracks(), const MyAlbums(), const MyArtists()])),
    );
  }
}
