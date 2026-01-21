import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/offline_storage_service.dart';

class SongMenu {
  static void show(
    BuildContext context,
    Offset position,
    Song song,
    OfflineStorageService offlineStorage,
  ) async {
    final DownloadController downloadController =
        Get.find<DownloadController>();

    final selected = await showMenu(
      context: context,
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(
                song.isDownloaded ? Icons.check : Icons.download,
                color: song.isDownloaded ? Colors.green : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                song.isDownloaded ? 'Downloaded' : 'Download',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'save',
          child: Text('Save', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem(
          value: 'playlist',
          child: Text('Add to Playlist', style: TextStyle(color: Colors.white)),
        ),
      ],
    );

    if (selected == 'download' && !song.isDownloaded) {
      final downloadedSong = song.copyWith(isDownloaded: true);
      offlineStorage.saveDownloadedSong(downloadedSong);
      downloadController.downloadSong(song.title);

      Get.snackbar(
        'Downloaded',
        '${song.title} saved for offline playback',
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    }
  }
}
