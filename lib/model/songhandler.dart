import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final player = AudioPlayer();
  // final SongsProvider songsProvider =SongsProvider();

  // void _loadPlaylist() {}

  // Duration _currentDuration = Duration.zero;
  // Duration totalDuration = Duration.zero;
  // Duration get currentDuration => _currentDuration;
  // Duration get totalDuration => _totalDuration;

  // SongHandler(){
  //   // initSongs(songs: songs);
  //   
  //   _listenForDurationChanges();
  //   _listenForCurrentSongIndexChanges();
  //   _listenForSequenceStateChanges();
  // }

  UriAudioSource _createAudioSource(MediaItem item) {
    return AudioSource.uri(Uri.parse(item.id), tag: item);
  }

  void _listenForDurationChanges() {
    player.durationStream.listen((duration) {
      // totalDuration=duration!;
      var index = player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (player.shuffleModeEnabled) index = player.shuffleIndices![index];
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    player.currentIndexStream.listen((index) {
      final playlist = queue.value;

      if (index == null || playlist.isEmpty) {
        return;
      }
      if (player.shuffleModeEnabled) index = player.shuffleIndices![index];
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((e) => e.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  Future<void> initSongs({required List<MediaItem> songs}) async {
    // Listen for playback events and broadcast the state
    player.playbackEventStream.listen(_broadcastState);

    // Create a list of audio sources from the provided songs
    final audioSource = songs.map(_createAudioSource).toList();

    // Set the audio source of the audio player to the concatenation of the audio sources
    await player
        .setAudioSource(ConcatenatingAudioSource(children: audioSource));

    // Add the songs to the queue
    queue.value.clear();
    queue.value.addAll(songs);
    queue.add(queue.value);

    // Listen for changes in the current song index
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();

    // Listen for processing state changes and skip to the next song when completed
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) skipToNext();
    });
  }

  // Play function to start playback
  @override
  Future<void> play() => player.play();

  @override
  Future<void> stop() => player.stop();

  // Pause function to pause playback
  @override
  Future<void> pause() => player.pause();

  // Seek function to change the playback position
  @override
  Future<void> seek(Duration position) => player.seek(position);

  // Skip to a specific item in the queue and start playback
  @override
  Future<void> skipToQueueItem(int index) async {
    await player.seek(Duration.zero, index: index);
    play();
  }

  // Skip to the next item in the queue
  @override
  Future<void> skipToNext() async {
    await player.seekToNext();
    play();
  }

  // Skip to the previous item in the queue
  @override
  Future<void> skipToPrevious() async {
    await player.seekToPrevious();
    play();
  }
}
