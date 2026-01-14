import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/utils/app_colors.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DownloadController downloadController =
        Get.find<DownloadController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              showFullScreenDownloadSheet(context, downloadController);
            },

            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo.png',
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 30),
          SizedBox(
            height: 30,
            child: ValueListenableBuilder<String?>(
              valueListenable: MusicController.currentTitle,
              builder: (_, title, __) {
                if ((title ?? '').length < 20) {
                  return Text(
                    title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                return Marquee(
                  text: title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  blankSpace: 50,
                  velocity: 30,
                  pauseAfterRound: const Duration(seconds: 1),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          ValueListenableBuilder<String?>(
            valueListenable: MusicController.currentSubtitle,
            builder: (_, subtitle, __) => Text(
              subtitle ?? '',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ),

          const SizedBox(height: 30),

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

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: MusicController.isShuffle,
                builder: (_, shuffle, __) => IconButton(
                  onPressed: MusicController.toggleShuffle,
                  icon: Icon(
                    Icons.shuffle,
                    color: shuffle ? AppColors.primaryColor : Colors.white54,
                  ),
                ),
              ),

              ValueListenableBuilder(
                valueListenable: MusicController.loopMode,
                builder: (_, LoopMode mode, __) {
                  IconData icon;
                  if (mode == LoopMode.one) {
                    icon = Icons.repeat_one;
                  } else {
                    icon = Icons.repeat;
                  }
                  return IconButton(
                    onPressed: MusicController.toggleLoop,
                    icon: Icon(
                      icon,
                      color: mode == LoopMode.off
                          ? Colors.white54
                          : AppColors.primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: MusicController.playPrevious,
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
                onPressed: MusicController.playNext,
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
    );
  }

  String formatDuration(Duration duration) {
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void showFullScreenDownloadSheet(
    BuildContext context,
    DownloadController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Downloaded Songs",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                GetBuilder<DownloadController>(
                  builder: (controller) {
                    final songs = controller.getDownloadedSongs();

                    return Expanded(
                      child: songs.isEmpty
                          ? const Center(
                              child: Text(
                                "No downloaded songs",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              itemCount: songs.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: Colors.grey.shade800),
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    songs[index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDeleteDialog(
                                        context,
                                        songs[index],
                                        controller,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteDialog(
    BuildContext context,
    String songTitle,
    DownloadController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(fontSize: 20, color: Colors.black)),
          ],
        ),
        content: const Text('Are you sure you want to delete this song?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),

          const SizedBox(width: 8),

          TextButton(
            onPressed: () {
              controller.removeSong(songTitle); // 🔥 DELETE
              Get.back(); // 🔥 CLOSE DIALOG
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
