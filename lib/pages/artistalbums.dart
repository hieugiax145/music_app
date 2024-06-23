import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/album_model.dart';
import 'package:music_app/model/artist_model.dart';
import 'package:music_app/pages/info_album.dart';

class AllAlbums extends StatelessWidget {
  AllAlbums({super.key, required this.artist, required this.albums});


  final Artist artist;
  final List<Album> albums;

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Albums'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 250),
                    itemCount: albums.length,
                    itemBuilder: ((context, index) {
                      Album album = albums[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AlbumPage(
                              album: album,
                            );
                          }));
                        },
                        
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: CachedNetworkImage(
                                  // width: 160,
                                  // height: 160,
                                  fit: BoxFit.fill,
                                  imageUrl: album.albumCover,
                                  // imageBuilder: (context, imageProvider) {
                                  // },
                                  placeholder: (context, url) =>
                                      Image.asset('lib/assets/album.png'),
                                  errorWidget: (context, url, error) =>
                                      Image.asset('lib/assets/album.png'),
                                  // ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  // decoration: BoxDecoration(color: Colors.blue),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        album.albumName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        album.artistName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        album.yearRelease,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      // Song data=snapshot.data!.docs[index];
                      // return Container(
                      //   // height: 100,
                      //   // width: 50,
                      //   decoration: BoxDecoration(color: Colors.amber),
                      // );
                    }),
                  ),
                // }),
          ),
        ],
      ),
    );
  }
}
