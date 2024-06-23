import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/pages/player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late final dynamic songsProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // songsProvider = Provider.of<songsProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongsProvider>(
      builder: (BuildContext context, SongsProvider value, Widget? child) {
        var check = value.playlist;
        return check.isNotEmpty
            ? Container(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(
              blurRadius: 5,
              offset: Offset(0, -0.1),
            ),]
          ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const Player();
                        }));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kBottomNavigationBarHeight * 0.2,
                            vertical: 5),
                        height: kBottomNavigationBarHeight * 1.2,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: Column(
                          children: [
                            StreamBuilder<SequenceState?>(
                                stream: value
                                    .songHandler.player.sequenceStateStream,
                                builder: (context, snapshot) {
                                  final state = snapshot.data;
                                  if (state?.sequence.isEmpty ?? true) {
                                    return const SizedBox.shrink();
                                  }
                                  final mediaItem =
                                      state!.currentSource!.tag as MediaItem;

                                  // value.currentSongIndex=value.list.indexOf(mediaItem);
                                  return Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Hero(
                                          tag: 'image',
                                          child: CachedNetworkImage(
                                            width: kBottomNavigationBarHeight,
                                            height: kBottomNavigationBarHeight,
                                            fit: BoxFit.cover,
                                            imageUrl:
                                                mediaItem.artUri.toString(),
                                            // imageBuilder: (context, imageProvider) {
                                            // },
                                            placeholder: (context, url) =>
                                                // const CircularProgressIndicator(),
                                                Image.asset(
                                                    'lib/assets/song.png'),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                                        'lib/assets/song.png'),
                                          ),
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
                                              mediaItem.title,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              mediaItem.artist.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Spacer(),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      StreamBuilder<PlayerState>(
                                        stream: value.songHandler.player
                                            .playerStateStream,
                                        builder: (context, snapshot) {
                                          final playerState = snapshot.data;
                                          final processingState =
                                              playerState?.processingState;
                                          final playing = playerState?.playing;
                                          // if (processingState ==
                                          //         ProcessingState.loading ||
                                          //     processingState ==
                                          //         ProcessingState.buffering) {
                                          //   return Container(
                                          //     margin: const EdgeInsets.all(8.0),
                                          //     width: 35,
                                          //     height: 35,
                                          //     child:
                                          //         const CircularProgressIndicator(),
                                          //   );
                                          // } else
                                            if (playing != true) {
                                            return IconButton(
                                              icon: const Icon(
                                                  Icons.play_arrow_rounded),
                                              iconSize: 35,
                                              onPressed:
                                                  value.songHandler.player.play,
                                            );
                                          } else if (processingState !=
                                              ProcessingState.completed) {
                                            return IconButton(
                                              icon: const Icon(Icons.pause),
                                              iconSize: 35,
                                              onPressed: value
                                                  .songHandler.player.pause,
                                            );
                                          } else {
                                            return IconButton(
                                              icon: const Icon(Icons.replay),
                                              iconSize: 35.0,
                                              onPressed: () => value
                                                  .songHandler.player
                                                  .seek(Duration.zero,
                                                      index: value
                                                          .songHandler
                                                          .player
                                                          .effectiveIndices!
                                                          .first),
                                            );
                                          }
                                        },
                                      ),
                                      StreamBuilder<SequenceState?>(
                                        stream: value
                                            .songHandler.player.sequenceStateStream,
                                        builder: (context, snapshot) => IconButton(
                                            icon: const Icon(Icons.skip_next_rounded,size: 35,),
                                            onPressed: () {
                                              // songsProvider.currentSongIndex =
                                              // songsProvider.currentSongIndex + 1;
                                              value.songHandler.player.hasNext
                                                  ? value.songHandler.skipToNext()
                                                  : null;
                                            }),
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<Duration>(
                        stream: value.songHandler.player.positionStream,
                        builder: (context, snapshot) {
                          Duration? position = snapshot.data;
                          return Stack(children: [
                            LinearPercentIndicator(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              // linearStrokeCap: LinearStrokeCap.roundAll,
                              barRadius: const Radius.circular(6),
                              lineHeight: 2,
                              percent: 1,
                              progressColor:
                                  Theme.of(context).colorScheme.secondary,
                              backgroundColor: Colors.transparent,
                            ),
                            LinearPercentIndicator(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              // linearStrokeCap: LinearStrokeCap.roundAll,
                              barRadius: const Radius.circular(6),
                              lineHeight: 2,
                              percent: (position?.inSeconds ?? 0) /
                                  (value.songHandler.player.duration
                                          ?.inSeconds ??
                                      1),
                              progressColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              backgroundColor: Colors.transparent,
                            ),
                          ]);
                        })
                  ],
                ),
              )
            : Container();
      },
    );
  }
}
