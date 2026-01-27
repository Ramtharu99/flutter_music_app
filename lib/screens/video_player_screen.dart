import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/video_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  final int index;

  const VideoPlayerScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(controller.videos[index].title),
      ),
      body: Center(
        child: Obx(() {
          if (!controller.isInitialized.value) {
            return const CircularProgressIndicator();
          }
          return AspectRatio(
            aspectRatio: controller.player.value.aspectRatio,
            child: VideoPlayer(controller.player),
          );
        }),
      ),
    );
  }
}
