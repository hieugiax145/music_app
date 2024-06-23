import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/components/neu_box.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/pages/listplaying.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:ticker_text/ticker_text.dart';

import '../model/song_model.dart';

// ignore: must_be_immutable
class Player extends StatefulWidget {
  const Player({super.key});
  // String songName, artistName, songImage, songFile;
  // List playlist;
  // int index;

  // Player({required this.playlist, required this.index});

  // Player(
  //     {required this.songName,
  //     required this.artistName,
  //     required this.songImage,
  //     required this.songFile});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  String formatTime(Duration duration) {
    String twoDigitSecons =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inMinutes}:$twoDigitSecons';
  }

  // final player player;
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic songsProvider;
  bool check = false;
  bool isDone = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    // playlistCover = songsProvider.playlist.map((e) => e.albumCover).toList();
    // checkF();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void checkF(String songID) async {
    bool tmp = await firestoreService.trackCheck(songID);
    if (!mounted) return;
    setState(() {
      check = tmp;
      isDone = true;
    });
  }

  List playlistCover = [];

  @override
  Widget build(BuildContext context) {
    // Color navColor = ElevationOverlay.applySurfaceTint(
    //     Theme.of(context).colorScheme.surface,
    //     Theme.of(context).colorScheme.surfaceTint,
    //     3);
    final screenWidth = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarDividerColor:
            Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: NeuBox(
                        color: Theme.of(context).colorScheme.background,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                    const Text('Now Playing'),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: NeuBox(
                        color: Theme.of(context).colorScheme.background,
                        child: IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ListPlaying())),
                          icon: const Icon(Icons.menu_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                // CarouselSlider(
                //     items: playlistCover.map((i) {
                //       return ClipRRect(
                //         borderRadius: BorderRadius.circular(12),
                //         child: Hero(
                //           tag: 'image',
                //           child: CachedNetworkImage(
                //             // width: screenWidth - 40,
                //             // height: screenWidth - 40,
                //             fit: BoxFit.cover,
                //             imageUrl: i,
                //             // imageBuilder: (context, imageProvider) {
                //             // },
                //             placeholder: (context, url) =>
                //                 Image.asset('lib/assets/song.png'),
                //             errorWidget: (context, url, error) =>
                //                 Image.asset('lib/assets/song.png'),
                //             // ),
                //           ),
                //         ),
                //       );
                //     }).toList(),
                //     options: CarouselOptions(
                //         height: screenWidth - 60,
                //         aspectRatio: 1,
                //         initialPage: songsProvider.songHandler.player.currentIndex,
                //         viewportFraction: 1,
                //         enableInfiniteScroll: false,
                //         enlargeCenterPage: true,
                //         // enlargeFactor: 0.8,
                //         onPageChanged: (index, reason) {
                //           songsProvider.songHandler.skipToQueueItem(index);
                //           songsProvider.currentSongIndex = index;
                //         })),
                // SizedBox(
                //   height: 20,
                // ),
                StreamBuilder<SequenceState?>(
                    stream:
                        songsProvider.songHandler.player.sequenceStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state?.sequence.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      }
                      final mediaItem = state!.currentSource!.tag as MediaItem;
                      final media = songsProvider.songHandler.player
                          .sequenceState.currentSource.tag as MediaItem;
                      // songsProvider.currentSongIndex=songsProvider.list.indexOf(mediaItem);
                      checkF(media.extras!['songID']);
                      int idx = songsProvider.list.indexOf(mediaItem);
                      Song currentSong = songsProvider.playlist[idx];
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                const BoxShadow(
                                  blurRadius: 15,
                                  offset: Offset(5, 5),
                                ),
                                BoxShadow(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  // color: isDarkMode?Color(0xffa1b2g3):Colors.white,
                                  blurRadius: 15,
                                  offset: const Offset(-5, -5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Hero(
                                tag: 'image',
                                child: CachedNetworkImage(
                                  width: screenWidth - 40,
                                  height: screenWidth - 40,
                                  fit: BoxFit.cover,
                                  imageUrl: mediaItem.artUri.toString(),
                                  // imageBuilder: (context, imageProvider) {
                                  // },
                                  placeholder: (context, url) => Image.asset(
                                    'lib/assets/song.png',
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'lib/assets/song.png',
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  // ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TickerText(
                                      scrollDirection: Axis.horizontal,
                                      speed: 20,
                                      startPauseDuration:
                                          const Duration(seconds: 1),
                                      endPauseDuration:
                                          const Duration(seconds: 1),
                                      // returnDuration:
                                      //     const Duration(seconds: 10),
                                      primaryCurve: Curves.linear,
                                      returnCurve: Curves.easeOut,
                                      child: Text(
                                        currentSong.songName,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      mediaItem.artist.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    !check
                                        ? firestoreService
                                            .addToTracks(currentSong)
                                        : firestoreService.removeFromTracks(
                                            currentSong.songID);
                                  },
                                  icon: Icon(
                                    check
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: check
                                        ? Colors.red
                                        : Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                    size: 35,
                                  )),
                            ],
                          ),
                        ],
                      );
                    }),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Text(formatTime(songsProvider.currentDuration)),
                //     GestureDetector(
                //       child: Icon(songsProvider.isShuffle
                //           ? Icons.shuffle_on_rounded
                //           : Icons.shuffle_rounded),
                //       // onTap: songsProvider.shuffle,
                //     ),
                //     GestureDetector(
                //         // onTap: songsProvider.replay,
                //         child: Icon(songsProvider.isReplayALL
                //             ? Icons.repeat_on_rounded
                //             : songsProvider.isReplayOne
                //                 ? Icons.repeat_one_on_rounded
                //                 : Icons.repeat)),
                //     Text(formatTime(songsProvider.totalDuration)),
                //   ],
                // ),
                const SizedBox(height: 20.0),

                StreamBuilder<Duration>(
                  stream: songsProvider.songHandler.player.positionStream,
                  builder: (context, snapshot) {
                    Duration? position = snapshot.data;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(formatTime(position ?? Duration.zero)),
                            GestureDetector(
                              child: Icon(songsProvider
                                      .songHandler.player.shuffleModeEnabled
                                  ? Icons.shuffle_on_rounded
                                  : Icons.shuffle_rounded),
                            ),
                            GestureDetector(
                                // onTap: songsProvider.replay,
                                child: const Icon(Icons.repeat)),
                            Text(formatTime(
                                songsProvider.songHandler.player.duration ??
                                    Duration.zero)),
                          ],
                        ),
                        Slider(
                          min: 0,
                          max: songsProvider
                                  .songHandler.player.duration?.inSeconds
                                  .toDouble() ??
                              0,
                          value: position?.inSeconds.toDouble() ?? 0,
                          activeColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          inactiveColor:
                              Theme.of(context).colorScheme.secondary,
                          // thumbColor: Colors.red,
                          // secondaryActiveColor: Colors.red,
                          onChanged: (double double) {
                            songsProvider.songHandler
                                .seek(Duration(seconds: double.toInt()));
                          },
                          onChangeEnd: (double double) {
                            songsProvider.songHandler
                                .seek(Duration(seconds: double.toInt()));
                          },
                        ),
                        // ProgressBar(
                        //   progress: position ?? Duration.zero,
                        //   total: songsProvider.songHandler.player.duration ??
                        //       Duration.zero,
                        //   // Callback for seeking when the user interacts with the progress bar
                        //   onSeek: (position) {
                        //     songsProvider.songHandler.seek(position);
                        //   },
                        //   // Customize the appearance of the progress bar
                        //   barHeight: 10,
                        //   thumbRadius: 2.5,
                        //   thumbGlowRadius: 5,
                        //   timeLabelLocation: TimeLabelLocation.below,
                        //   timeLabelPadding: 10,
                        //   // barCapShape: BarCapShape.square,
                        // ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<SequenceState?>(
                        stream: songsProvider
                            .songHandler.player.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              size: 40,
                            ),
                            onPressed: () {
                              // songsProvider.currentSongIndex =
                              // songsProvider.currentSongIndex + 1;
                              songsProvider.songHandler.player.hasPrevious
                                  ? songsProvider.songHandler.skipToPrevious()
                                  : null;
                            }),
                      ),
                      // ),
                    ),
                    const SizedBox(width: 20.0),
                    NeuBox(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: StreamBuilder<PlayerState>(
                        stream:
                            songsProvider.songHandler.player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (playing != true) {
                            return IconButton(
                              color: Theme.of(context).colorScheme.background,
                              icon: const Icon(Icons.play_arrow_rounded),
                              iconSize: 64.0,
                              onPressed: songsProvider.songHandler.player.play,
                            );
                          } else if (processingState !=
                              ProcessingState.completed) {
                            return IconButton(
                              color: Theme.of(context).colorScheme.background,
                              icon: const Icon(Icons.pause),
                              iconSize: 64.0,
                              onPressed: songsProvider.songHandler.player.pause,
                            );
                          } else {
                            return IconButton(
                              color: Theme.of(context).colorScheme.background,
                              icon: const Icon(Icons.replay),
                              iconSize: 64.0,
                              onPressed: () => songsProvider.songHandler.player
                                  .seek(Duration.zero,
                                      index: songsProvider.songHandler.player
                                          .effectiveIndices!.first),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: StreamBuilder<SequenceState?>(
                        stream: songsProvider
                            .songHandler.player.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              size: 40,
                            ),
                            onPressed: () {
                              // songsProvider.currentSongIndex =
                              // songsProvider.currentSongIndex + 1;
                              songsProvider.songHandler.player.hasNext
                                  ? songsProvider.songHandler.skipToNext()
                                  : null;
                            }),
                      ),
                      // ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
