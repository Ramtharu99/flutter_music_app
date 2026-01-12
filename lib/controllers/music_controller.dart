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

  static Future<void> playAsset({
    required String path,
    required String title,
    required String subtitle,
  }) async {
    try {
      await _player.setAudioSource(
        AudioSource.asset(
          path,
          tag: MediaItem(
            id: path,
            title: title,
            album: subtitle,
            artUri: Uri.parse('asset://assets/images/logo.png'), // album art
          ),
        ),
      );

      _player.play();

      currentTitle.value = title;
      currentSubtitle.value = subtitle;
      isPlaying.value = true;

      _player.positionStream.listen((pos) => currentPosition.value = pos);
      _player.durationStream.listen(
        (dur) => totalDuration.value = dur ?? Duration.zero,
      );
      _player.playerStateStream.listen((state) {
        isPlaying.value = state.playing;
      });
    } catch (e) {
      debugPrint('music play error: $e');
    }
  }

  static void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
      isPlaying.value = false;
    } else {
      _player.play();
      isPlaying.value = true;
    }
  }

  static void seekTo(Duration position) {
    _player.seek(position);
  }
}
