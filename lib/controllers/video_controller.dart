import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music_app/models/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  late VideoPlayerController player;
  final videos = <VideoModel>[].obs;
  final currentIndex = 0.obs;
  final isInitialized = false.obs;
  final showControls = true.obs;
  final isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyVideos();
  }

  void _loadDummyVideos() {
    videos.value = [
      VideoModel(
        id: '1',
        title: 'Big Buck Bunny',
        url: 'https://www.w3schools.com/html/mov_bbb.mp4',
        thumbnail:
            'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg',
      ),
      VideoModel(
        id: '2',
        title: 'Sintel Trailer',
        url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        thumbnail:
            'https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png',
      ),
      VideoModel(
        id: '3',
        title: 'Sample Video',
        url: 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4',
        thumbnail: 'https://dummyimage.com/600x400/000/fff&text=Sample+Video',
      ),
    ];
  }

  Future<void> initializePlayer(int index) async {
    try {
      currentIndex.value = index;

      // Dispose old player if exists
      if (isInitialized.value) {
        await player.dispose();
      }

      player = VideoPlayerController.networkUrl(Uri.parse(videos[index].url));
      await player.initialize();

      // Setup listeners
      player.addListener(() {
        isPlaying.value = player.value.isPlaying;

        // Auto-play next video when current finishes
        if (player.value.position >= player.value.duration &&
            index < videos.length - 1) {
          nextVideo();
        }
      });

      isInitialized.value = true;
      await player.play();
      isPlaying.value = true;

      // Set landscape orientation for video playback
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      isInitialized.value = false;
    }
  }

  void togglePlay() {
    if (player.value.isPlaying) {
      player.pause();
      isPlaying.value = false;
    } else {
      player.play();
      isPlaying.value = true;
    }
    update();
  }

  void nextVideo() {
    if (currentIndex.value < videos.length - 1) {
      initializePlayer(currentIndex.value + 1);
    }
  }

  void previousVideo() {
    if (currentIndex.value > 0) {
      initializePlayer(currentIndex.value - 1);
    }
  }

  void toggleControl() {
    showControls.value = !showControls.value;
  }

  /// Seek to position
  void seekToPosition(Duration position) {
    player.seekTo(position);
  }

  /// Get current position
  Duration getCurrentPosition() {
    return player.value.position;
  }

  /// Get total duration
  Duration getTotalDuration() {
    return player.value.duration;
  }

  @override
  void onClose() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      player.dispose();
    } catch (e) {
      debugPrint('Error disposing video player: $e');
    }
    super.onClose();
  }
}
