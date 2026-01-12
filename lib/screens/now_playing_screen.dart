import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/music_controller.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album art
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo.png',
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<String?>(
              valueListenable: MusicController.currentTitle,
              builder: (_, title, __) => Text(
                title ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String?>(
              valueListenable: MusicController.currentSubtitle,
              builder: (_, subtitle, __) => Text(
                subtitle ?? '',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              ),
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<Duration>(
              valueListenable: MusicController.currentPosition,
              builder: (_, position, __) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: MusicController.totalDuration,
                  builder: (_, total, __) {
                    return Column(
                      children: [
                        Slider(
                          min: 0,
                          max: total.inMilliseconds.toDouble(),
                          value: position.inMilliseconds.toDouble().clamp(
                            0,
                            total.inMilliseconds.toDouble(),
                          ),
                          onChanged: (val) => MusicController.seekTo(
                            Duration(milliseconds: val.toInt()),
                          ),
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDuration(position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                formatDuration(total),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: MusicController.isPlaying,
                  builder: (_, playing, __) => IconButton(
                    onPressed: MusicController.togglePlayPause,
                    icon: Icon(
                      playing ? Icons.pause_circle : Icons.play_circle,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
