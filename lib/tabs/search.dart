import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/components/album/tile_album.dart';
import 'package:music_app/components/artist/tile_artist.dart';
import 'package:music_app/components/button_filter.dart';
import 'package:music_app/components/song/tile_song.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/pages/info_album.dart';
import 'package:music_app/pages/info_artist.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FirestoreService firestoreService = FirestoreService();
  String currentFilter = 'all';
  List playlist = [];
  List searchList = [];
  List searchHistory = [];
  final TextEditingController _search = TextEditingController();
  // bool _isLoaded = false;
  late final dynamic songsProvider;
  int n = 0;
  bool added = false;
  bool isFocus=false;

  @override
  void initState() {
    super.initState();
    // _search.addListener(_onSearchChange);
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
  }

  @override
  void dispose(){
    _search.dispose();
    super.dispose();


  }


  Future<void> songClick(int index, List<Song> song) async {
    // songsProvider.currentSongIndex = 0;
    // if (added == false) {
      await songsProvider.updatePlayList(song);
      // setState(() {
      //   added = true;
      // });
    // }
    songsProvider.songHandler.play();
    // songsProvider.songHandler.skipToQueueItem(index);
    // setState(() {
    //   added=false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // return Consumer<songsProvider>(
    // onTap: ()=>FocusScope.of(context).unfocus(),
    // builder: (BuildContext context, songsProvider value, Widget? child) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        // systemNavigationBarContrastEnforced: true,
        // systemNavigationBarColor: navColor,
        // systemNavigationBarDividerColor: navColor,
        // systemNavigationBarIconBrightness:
        // Theme.of(context).brightness == Brightness.light
        // ? Brightness.dark
        // : Brightness.light,
      ),
      // child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 2,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Column(
            children: [
              TextField(

                controller: _search,
                onTap: (){
                  setState(() {
                    isFocus=true;
                  });
                },
                // onTapOutside: (){},
                onChanged: (value) {
                  setState(() {
                    _search.text = value;
                  });
                },
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    isFocus=false;
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      fontWeight:FontWeight.bold,
                        fontSize: 15
                        ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : InkWell(
                            onTap: () {
                              setState(() {});
                              _search.clear();
                            },
                            child: const Icon(Icons.cancel_rounded)),
                    contentPadding: const EdgeInsets.all(0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none)),
              ),
              const SizedBox(height: kToolbarHeight * 0.1),
              _search.text.isNotEmpty ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterButton(
                        label: 'Top',
                        onPressed: () {
                          setState(() {
                            currentFilter = 'all';
                          });
                        },
                        isSelected: currentFilter == 'all',
                      ),
                      FilterButton(
                        label: 'Tracks',
                        onPressed: () {
                          setState(() {
                            currentFilter = 'songs';
                          });
                        },
                        isSelected: currentFilter == 'songs',
                      ),
                      FilterButton(
                        label: 'Albums',
                        onPressed: () {
                          setState(() {
                            currentFilter = 'albums';
                          });
                        },
                        isSelected: currentFilter == 'albums',
                      ),
                      FilterButton(
                        label: 'Artists',
                        onPressed: () {
                          setState(() {
                            currentFilter = 'artists';
                          });
                        },
                        isSelected: currentFilter == 'artists',
                      ),
                      FilterButton(
                        label: 'Playlists',
                        onPressed: () {
                          setState(() {
                            currentFilter = 'artists';
                          });
                        },
                        isSelected: currentFilter == 'artists',
                      ),
                    ],
                  ),
                ),
              ):const SizedBox(),
            ],
          ),
        ),
        body: ListView(
          // child: Padding(
          // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (_search.text != null && _search.text!.isNotEmpty)
                _search.text != ''
                    ? showSearchList()
                    : Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent searches',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(onPressed: () {
                                    deleteAll();
                                  }, icon: const Icon(CupertinoIcons.delete_solid))
                                ],
                              ),
                            ),
                            showSearchHistory()
                          ],
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
      // ),
      // ),
    );
    // },
    // );
  }

  Future<void> deleteAll() async {
    final collection = await firestoreService.search.get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in collection.docs) {
      batch.delete(doc.reference);
    }

    return batch.commit();
  }

  Widget showSearchHistory() {
    return StreamBuilder(
        stream: firestoreService.getSearch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.length == 0) {
            return const Center(
                child:
                    Text('Search your favorite artists, tracks and albums.'));
          }

          searchHistory = snapshot.data!.docs.where((element) => element.reference.id != 'null').map((doc) {
            if (doc.id.startsWith('song')) {
              return Song(
                  songID: doc.id,
                  songName: doc['name'],
                  songFile: doc['songFile'],
                  albumName: doc['albumName'],
                  albumCover: doc['albumCover'],
                  artistName: doc['artistName'],
                  trackNum: doc['trackNum'],
                  artistID: doc['artistID'],
                  albumID: doc['albumID']);
            }
            if (doc.id.startsWith('album')) {
              return Album(
                  albumID: doc.id,
                  albumName: doc['name'],
                  albumCover: doc['albumCover'],
                  artistName: doc['artistName'],
                  yearRelease: doc['yearRelease'],
                  artistID: doc['artistID']);
            }
            if (doc.id.startsWith('artist')) {
              return Artist(
                  artistID: doc.id,
                  artistName: doc['name'],
                  artistProfile: doc['artistProfile']);
            }
          }).toList();
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                var data = searchHistory[index];
                if (data is Song) {
                  return SongTile(
                    song: data,
                    onTap: () {
                      songClick(index, [data]);
                      // Navigator.of(context, rootNavigator: true)
                      //     .push(MaterialPageRoute(builder: (context) {
                      //   return const Player();
                      // }));
                      firestoreService.addToSearch(data);
                    },
                  );
                }
                if (data is Album) {
                  return AlbumTile(
                      album: data,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return AlbumPage(
                            album: data,
                          );
                        }));
                        firestoreService.addToSearch(data);
                      });
                }
                if (data is Artist) {
                  return ArtistTile(
                      artist: data,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ArtistPage(artist: data);
                        }));
                        firestoreService.addToSearch(data);
                      });
                }
                return null;
              });
        });
  }

  Widget showSearchList() {
    return StreamBuilder(
      stream: firestoreService.all.snapshots(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No results found.'));
        }
        searchList = snapshot.data!.docs
            .where((element) =>
                element['name'].toString().toLowerCase().contains(_search.text.toLowerCase()))
            .toList();
        if (searchList.isEmpty) {
          return const Center(child: Text('No results found.'));
        } else {
          searchList = searchList.map((doc) {
            if (doc.id.startsWith('song')) {
              return Song(
                  songID: doc.id,
                  songName: doc['name'],
                  songFile: doc['songFile'],
                  albumName: doc['albumName'],
                  albumCover: doc['albumCover'],
                  artistName: doc['artistName'],
                  trackNum: doc['trackNum'],
                  artistID: doc['artistID'],
                  albumID: doc['albumID']);
            }
            if (doc.id.startsWith('album')) {
              return Album(
                  albumID: doc.id,
                  albumName: doc['name'],
                  albumCover: doc['albumCover'],
                  artistName: doc['artistName'],
                  yearRelease: doc['yearRelease'],
                  artistID: doc['artistID']);
            }
            if (doc.id.startsWith('artist')) {
              return Artist(
                  artistID: doc.id,
                  artistName: doc['name'],
                  artistProfile: doc['artistProfile']);
            }
          }).toList();
          if (_search.text!=' '&& currentFilter == 'all') {
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchList.length,
                itemBuilder: (context, index) {
                  var data = searchList[index];
                  if (data is Song) {
                    return SongTile(
                      song: data,
                      onTap: () {
                        songClick(index, [data]);
                        // Navigator.of(context,
                        //         rootNavigator: true)
                        //     .push(MaterialPageRoute(
                        //         builder: (context) {
                        //   return const Player();
                        // }));
                        firestoreService.addToSearch(data);
                      },
                    );
                  }
                  if (data is Album) {
                    return AlbumTile(
                        album: data,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AlbumPage(
                              album: data,
                            );
                          }));
                          firestoreService.addToSearch(data);
                        });
                  }
                  if (data is Artist) {
                    return ArtistTile(
                        artist: data,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ArtistPage(artist: data);
                          }));
                          firestoreService.addToSearch(data);
                        });
                  }
                  return null;
                });
          }
          if (currentFilter == 'songs') {
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchList.length,
                itemBuilder: (context, index) {
                  var data = searchList[index];
                  // print(data.id);
                  if (data is Song) {
                    return SongTile(
                      song: data,
                      onTap: () {
                        songClick(index, [data]);
                        // Navigator.of(context, rootNavigator: true)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return const Player();
                        // }));
                        firestoreService.addToSearch(data);
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                });
          }
          if (currentFilter == 'albums') {
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchList.length,
                itemBuilder: (context, index) {
                  var data = searchList[index];
                  if (data is Album) {
                    return AlbumTile(
                        album: data,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AlbumPage(
                              album: data,
                            );
                          }));
                          firestoreService.addToSearch(data);
                        });
                  }
                  return null;
                  // }
                });
          }
          if (currentFilter == 'artists') {
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchList.length,
                itemBuilder: (context, index) {
                  var data = searchList[index];
                  // return Text("hello");
                  if (data is Artist) {
                    return ArtistTile(
                        artist: data,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ArtistPage(artist: data);
                          }));
                          firestoreService.addToSearch(data);
                        });
                  } else {
                    return const SizedBox();
                  }
                  // }
                });
          } else {
            return const Text('No results found.');
          }
        }

        // }
      },
    );
  }
}


