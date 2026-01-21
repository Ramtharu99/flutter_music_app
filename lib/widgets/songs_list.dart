import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';
import 'package:music_app/widgets/empty_state.dart';
import 'package:music_app/widgets/music_list_tile.dart';
import 'package:music_app/widgets/song_menu.dart';

class SongsList extends StatelessWidget {
  final List<Song> songs;
  final OfflineStorageService offlineStorageService;
  final ConnectivityService connectivityService;

  const SongsList({
    super.key,
    required this.songs,
    required this.offlineStorageService,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return EmptyState(
        title: 'No Songs Available',
        subtitle: connectivityService.isOffline
            ? 'Connect to internet to load songs'
            : 'Pull to refresh',
      );
    }

    return Column(
      children: songs.map((song) {
        return MusicListTile(
          image: song.coverImage.startsWith('http')
              ? song.coverImage
              : 'assets/images/logo.png',
          title: song.title,
          subtitle: song.artist,
          onTap: () {
            if (connectivityService.isOffline && !song.isDownloaded) {
              Get.snackbar(
                'Offline',
                'This song is not available offline',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            MusicController.playFromUrl(
              url: song.localPath ?? song.fileUrl!,
              title: song.title,
              artist: song.artist,
              imageUrl: song.coverImage,
            );
          },
          onMoreTap: (position) {
            SongMenu.show(context, position, song, offlineStorageService);
          },
        );
      }).toList(),
    );
  }
}
