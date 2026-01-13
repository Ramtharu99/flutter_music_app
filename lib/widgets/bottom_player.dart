import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/screens/now_playing_screen.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: MusicController.currentTitle,
      builder: (context, title, _) {
        if (title == null) return const SizedBox.shrink();

        return InkWell(
          onTap: () => Get.to(() => const NowPlayingScreen()),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 48,
                    width: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ValueListenableBuilder<String?>(
                        valueListenable: MusicController.currentSubtitle,
                        builder: (_, subtitle, __) {
                          return Text(
                            subtitle ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => MusicController.playPrevious(),
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: MusicController.isPlaying,
                  builder: (_, playing, __) {
                    return IconButton(
                      onPressed: MusicController.togglePlayPause,
                      icon: Icon(
                        playing ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () => MusicController.playNext(),
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
