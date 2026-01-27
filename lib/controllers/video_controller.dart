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
    currentIndex.value = index;

    player = VideoPlayerController.networkUrl(Uri.parse(videos[index].url));
    await player.initialize();
    isInitialized.value = true;
    player.play();

    ///full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    player.addListener(() {
      if (player.value.position >= player.value.duration &&
          index < videos.length - 1) {
        nextVideo();
      }
    });
  }

  void togglePlay() {
    player.value.isPlaying ? player.pause() : player.play();
    update();
  }

  void nextVideo() {
    if (currentIndex.value < videos.length - 1) {
      player.dispose();
      initializePlayer(currentIndex.value + 1);
    }
  }

  void previousVideo() {
    if (currentIndex.value > 0) {
      player.dispose();
      initializePlayer(currentIndex.value - 1);
    }
  }

  void toggleControl() {
    showControls.value = !showControls.value;
  }

  @override
  void onClose() {
    player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.onClose();
  }
}
