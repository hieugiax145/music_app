import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/components/neu_box.dart';
import 'package:music_app/model/playing_provider.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class ListPlaying extends StatefulWidget {
  const ListPlaying({super.key});

  @override
  State<ListPlaying> createState() => _ListPlayingState();
}

class _ListPlayingState extends State<ListPlaying> {
  // late final dynamic playingProvider;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();

  //   playingProvider=Provider.of<PlayingProvider>(context,listen: false);
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongsProvider>(
      builder: (context, value, child) {
        // List playlist = value.playlist;
        // final idx = value.currentSongIndex;
        // final currentSong = playlist[idx!];
        // final playlistx = playlist.sublist(idx + 1, playlist.length);
        // final tmp = playlist.length - idx;
        // print(playlist.length.toString() +
        //     ' ' +
        //     idx.toString() +
        //     ' ' +
        //     tmp.toString());
        // print(idx);
        // print(tmp);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            bottom: PreferredSize(
              preferredSize: const Size(0, 120),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20,0,20,0),
                  child: StreamBuilder<Duration>(
                      stream: value.songHandler.player.positionStream,
                      builder: (context, snapshot) {
                        Duration? position = snapshot.data;
                        return NeuBox(
                          color: Theme.of(context).colorScheme.background,
                          child: Container(
                            child: LinearPercentIndicator(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              // linearStrokeCap: LinearStrokeCap.roundAll,
                              barRadius: const Radius.circular(6),
                              lineHeight: 100,
                              percent: (position?.inSeconds ?? 0) /
                                  (value.songHandler.player.duration
                                          ?.inSeconds ??
                                      1),
                              progressColor:
                                  Theme.of(context).colorScheme.secondary,
                              backgroundColor: Colors.transparent,
                              center: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          width: 80,
                                          height: 80,
                                          imageUrl: value.currentSong!.albumCover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              value.currentSong!.songName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              value.currentSong!.artistName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                    // ],
                                    ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
          // body: ListView.builder(
          //     itemCount: playlistx.length,
          //     itemBuilder: (context, index) {
          //       var data = playlistx[index];
          //       return InkWell(
          //         onTap: () {
          //           value.currentSongIndex = index + idx + 1;
          //         },
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 18.0),
          //           child: ListTile(
          //             // visualDensity: VisualDensity(vertical: 2),
          //             leading: ClipRRect(
          //               borderRadius: BorderRadius.circular(10),
          //               child: CachedNetworkImage(
          //                 // width: 50,
          //                 // height: 70,
          //                 imageUrl: data.albumCover,
          //                 placeholder: (context, url) =>
          //                     const CircularProgressIndicator(),
          //                 errorWidget: (context, url, error) =>
          //                     const Icon(Icons.error),
          //               ),
          //             ),
          //             title: Text(
          //               data.songName,
          //               overflow: TextOverflow.ellipsis,
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             subtitle: Text(
          //               data.artistName,
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           ),
          //         ),
          //       );
          //     }),
          // )
        );
      },
    );
  }
}
