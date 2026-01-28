import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/models/song_model.dart';
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
              builder: (context, title, child) {
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
            builder: (context, subtitle, child) => Text(
              subtitle ?? '',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ),

          const SizedBox(height: 30),

          ValueListenableBuilder<Duration>(
            valueListenable: MusicController.currentPosition,
            builder: (context, position, child) {
              return ValueListenableBuilder<Duration>(
                valueListenable: MusicController.totalDuration,
                builder: (context, total, child) {
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
                builder: (context, shuffle, child) => IconButton(
                  onPressed: MusicController.toggleShuffle,
                  icon: Icon(
                    Icons.shuffle,
                    color: shuffle ? AppColors.primaryColor : Colors.white54,
                  ),
                ),
              ),

              ValueListenableBuilder(
                valueListenable: MusicController.loopMode,
                builder: (context, LoopMode mode, child) {
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
                builder: (context, playing, child) => IconButton(
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Downloaded Songs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Clear All Downloads?'),
                              content: const Text(
                                'This will delete all downloaded songs. Continue?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller.clearAllDownloads();
                                    Get.back();
                                  },
                                  child: const Text(
                                    'Delete All',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.delete_sweep,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                GetBuilder<DownloadController>(
                  builder: (controller) {
                    final songs = controller.downloadedSongs;

                    return Expanded(
                      child: songs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download_for_offline_outlined,
                                    size: 64,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "No downloaded songs yet",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: songs.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey.shade800,
                                height: 0,
                              ),
                              itemBuilder: (context, index) {
                                final song = songs[index];
                                return ListTile(
                                  onTap: () {
                                    // Navigate to downloaded song
                                    MusicController.playFromSong(song);
                                    Get.back();
                                  },
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      image: DecorationImage(
                                        image: NetworkImage(song.coverImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: song.coverImage.isEmpty
                                        ? const Icon(
                                            Icons.music_note,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    song.artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.play_arrow),
                                            SizedBox(width: 8),
                                            Text('Play'),
                                          ],
                                        ),
                                        onTap: () {
                                          MusicController.playFromSong(song);
                                          Get.back();
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                        onTap: () {
                                          showDeleteDialog(
                                            context,
                                            song,
                                            controller,
                                          );
                                        },
                                      ),
                                    ],
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
    Song song,
    DownloadController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(fontSize: 20)),
          ],
        ),
        content: Text('Remove ${song.title} from downloads?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.removeSong(song.id.toString());
              Get.back();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
