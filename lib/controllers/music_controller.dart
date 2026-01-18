import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MusicController {
  static final AudioPlayer _player = AudioPlayer();

  static final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  static final ValueNotifier<String?> currentTitle = ValueNotifier(null);
  static final ValueNotifier<String?> currentSubtitle = ValueNotifier(null);
  static final ValueNotifier<Duration> currentPosition = ValueNotifier(
    Duration.zero,
  );
  static final ValueNotifier<Duration> totalDuration = ValueNotifier(
    Duration.zero,
  );
  static final ValueNotifier<int?> currentIndex = ValueNotifier(null);
  static final ValueNotifier<bool> isShuffle = ValueNotifier(false);
  static final ValueNotifier<LoopMode> loopMode = ValueNotifier(LoopMode.off);

  static List<AudioSource> _playlist = [];

  static Future<void> playPlaylist({
    required List<Map<String, dynamic>> songs,
    int startIndex = 0,
  }) async {
    try {
      _playlist = songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song['url']),
          tag: MediaItem(
            id: song['id'].toString(),
            title: song['title'],
            album: song['artist'],
            artUri: Uri.parse(song['image']),
          ),
        );
      }).toList();

      await _player.setAudioSources(_playlist, initialIndex: startIndex);

      _listenStreams();
      _player.play();
    } catch (e) {
      debugPrint('Playlist error: $e');
    }
  }

  static Future<void> playFromUrl({
    required String url,
    required String title,
    required String artist,
    required String imageUrl,
  }) async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: title,
            album: artist,
            artUri: Uri.parse(imageUrl),
          ),
        ),
      );

      _listenStreams();
      _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  static void togglePlayPause() {
    _player.playing ? _player.pause() : _player.play();
  }

  static void playNext() {
    if (_player.hasNext) _player.seekToNext();
  }

  static void playPrevious() {
    if (_player.hasPrevious) _player.seekToPrevious();
  }

  static void seekTo(Duration position) {
    _player.seek(position);
  }

  static Future<void> toggleShuffle() async {
    isShuffle.value = !isShuffle.value;
    await _player.setShuffleModeEnabled(isShuffle.value);
  }

  static Future<void> toggleLoop() async {
    if (loopMode.value == LoopMode.off) {
      loopMode.value = LoopMode.one;
    } else if (loopMode.value == LoopMode.one) {
      loopMode.value = LoopMode.all;
    } else {
      loopMode.value = LoopMode.off;
    }
    await _player.setLoopMode(loopMode.value);
  }

  static void _listenStreams() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    _player.positionStream.listen((pos) {
      currentPosition.value = pos;
    });

    _player.durationStream.listen((dur) {
      totalDuration.value = dur ?? Duration.zero;
    });

    _player.currentIndexStream.listen((index) {
      currentIndex.value = index;
      final tag = _player.sequenceState.currentSource?.tag;
      if (tag is MediaItem) {
        currentTitle.value = tag.title;
        currentSubtitle.value = tag.album;
      }
    });
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
