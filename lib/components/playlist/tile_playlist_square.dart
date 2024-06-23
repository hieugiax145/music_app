import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_app/components/tile_bottomsheet.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_model.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/pages/info_playlist.dart';
import 'package:provider/provider.dart';

class PlaylistTileSquare extends StatefulWidget {
  final Playlist playlist;

  final void Function()? onTap;
  final void Function()? moreVert;
  const PlaylistTileSquare({
    super.key,
    required this.playlist,
    this.onTap,
    this.moreVert,
  });

  @override
  State<PlaylistTileSquare> createState() => _PlaylistTileSquareState();
}

class _PlaylistTileSquareState extends State<PlaylistTileSquare> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic allPlaylistsProvider;
  final newName = TextEditingController();

  List<String> _imageUrls = [];
  List playlist = [];
  int numOfTrack = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allPlaylistsProvider =
        Provider.of<AllPlaylistsProvider>(context, listen: false);
    fetchImages();
    getNum();
  }

  @override
  void dispose() {
    super.dispose();
    // fetchImages();
    // getNum();
  }

  void getNum() async {
    int tmp =
        await firestoreService.getPlaylistLength(widget.playlist.playlistID);
    if (!mounted) return;
    setState(() {
      numOfTrack = tmp;
    });
  }

  void fetchImages() async {
    try {
      QuerySnapshot snapshot =
          await firestoreService.getImage(widget.playlist.playlistID).first;
      List<String> urls = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        urls.add(data!['albumCover']);
      }
      if (!mounted) return;
      setState(() {
        _imageUrls = urls;
      });
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  List<Widget> buildGridTiles() {
    List<Widget> tiles = [];
    for (int i = 0; i < 4; i++) {
      if (i < _imageUrls.length) {
        // If there are images fetched, display image tiles
        tiles.add(Image.network(
          _imageUrls[i],
          fit: BoxFit.cover,
        ));
      } else {
        // If there are fewer images than tiles, display placeholder tiles
        tiles.add(const Placeholder());
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    fetchImages();
    getNum();
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlaylistPage(
              playlist: widget.playlist,
            );
          }));
        },
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: GridView.builder(
                    primary: false,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _imageUrls.length) {
                        // If there's an image URL available, display it
                        return CachedNetworkImage(
                          imageUrl: _imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      } else {
                        // If no image URL available, display a placeholder from assets
                        return Image.asset(
                          'lib/assets/track.png', // Replace with your placeholder image asset path
                          fit: BoxFit.cover,
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.playlist.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
          return SafeArea(
            bottom: false,
            child: Wrap(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      ClipRRect(
                        // padding: EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: GridView.builder(
                            primary: false,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemCount: 4,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < _imageUrls.length) {
                                // If there's an image URL available, display it
                                return CachedNetworkImage(
                                  imageUrl: _imageUrls[index],
                                  fit: BoxFit.cover,
                                );
                              } else {
                                // If no image URL available, display a placeholder from assets
                                return Image.asset(
                                  'lib/assets/track.png', // Replace with your placeholder image asset path
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                            // separatorBuilder: (BuildContext context, int index) {
                            // return SizedBox.shrink(); // Empty container as separator
                            // },
                          ),
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
                              widget.playlist.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Text(
                            //   'Track by ' + widget.artistName,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: const TextStyle(
                            //     fontSize: 15,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
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
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Rename'),
                                content: const TextField(
                                  decoration:
                                      InputDecoration(hintText: 'New name'),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('CANCEL'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('RENAME'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      firestoreService.renamePlaylist(
                                          widget.playlist.playlistID,
                                          newName.text);
                                      Flushbar(
                                        flushbarPosition: FlushbarPosition.TOP,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        icon: const Icon(
                                          Icons.change_circle_outlined,
                                          color: Colors.white,
                                        ),
                                        title: "SUCCESSFUL",
                                        message: "Renamed this playlist",
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        flushbarStyle: FlushbarStyle.FLOATING,
                                        margin: const EdgeInsets.all(10),
                                        borderRadius: BorderRadius.circular(12),
                                        backgroundColor: Colors.green.shade600,
                                      ).show(context);
                                      newName.clear();
                                      allPlaylistsProvider.fetchData();
                                    },
                                  ),
                                ],
                                // content: Text('hehe'),
                              ));
                    },
                    icon: Icons.drive_file_rename_outline_outlined,
                    text: 'Rename'),
                SheetTile(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Delete this playlist?'),
                                actions: [
                                  TextButton(
                                    child: const Text('CANCEL'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('DELETE'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      firestoreService.deletePlaylist(
                                          widget.playlist.playlistID);
                                      Flushbar(
                                        flushbarPosition: FlushbarPosition.TOP,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        icon: const Icon(
                                          Icons.delete_forever_rounded,
                                          color: Colors.white,
                                        ),
                                        title: "SUCCESSFUL",
                                        message: "Deleted this playlist",
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        flushbarStyle: FlushbarStyle.FLOATING,
                                        margin: const EdgeInsets.all(10),
                                        borderRadius: BorderRadius.circular(12),
                                        backgroundColor: Colors.red.shade600,
                                      ).show(context);
                                      allPlaylistsProvider.fetchData();
                                    },
                                  ),
                                ],
                                // content: Text('hehe'),
                              ));
                    },
                    icon: Icons.delete_forever_rounded,
                    text: 'Delete')
              ],
            ),
          );
        });
  }
}
