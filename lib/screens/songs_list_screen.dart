/// Songs List Screen
/// Displays all songs with API integration.
/// Shows offline songs when offline.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';
import 'package:music_app/widgets/music_list_tile.dart';

class SongsListScreen extends StatefulWidget {
  const SongsListScreen({super.key});

  @override
  State<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen> {
  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final DownloadController _downloadController = Get.find<DownloadController>();

  List<Song> songs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (_connectivityService.isOnline) {
      // Online: Fetch from API
      try {
        final response = await _apiService.getSongs();
        if (response.success && response.data != null) {
          songs = response.data!;
          // Cache for offline
          _offlineStorage.cacheSongs(songs);
        } else {
          errorMessage = response.message;
          // Fallback to cached
          songs = _offlineStorage.getCachedSongs();
        }
      } catch (e) {
        errorMessage = 'Failed to load songs';
        songs = _offlineStorage.getCachedSongs();
      }
    } else {
      // Offline: Use cached songs
      songs = _offlineStorage.getCachedSongs();
      if (songs.isEmpty) {
        songs = _offlineStorage.getDownloadedSongs();
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Songs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(() {
            if (_connectivityService.isOffline) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : songs.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: _loadSongs,
              color: Colors.white,
              backgroundColor: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: MusicListTile(
                      image: song.coverImage.isNotEmpty
                          ? song.coverImage
                          : 'assets/images/logo.png',
                      title: song.title,
                      subtitle: song.artist,
                      isDownloaded:
                          song.isDownloaded ||
                          _downloadController.isSongDownloaded(song.id),
                      onTap: () {
                        // Check if offline and song not downloaded
                        if (_connectivityService.isOffline &&
                            !song.isDownloaded) {
                          Get.snackbar(
                            'Offline',
                            'This song is not available offline',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        // Play the song
                        MusicController.playFromUrl(
                          url: song.localPath ?? song.fileUrl!,
                          title: song.title,
                          artist: song.artist,
                          imageUrl: song.coverImage,
                        );
                      },
                      onMoreTap: (position) {
                        _showSongMenu(context, position, song);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 64, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            _connectivityService.isOffline
                ? 'No offline songs available'
                : 'No songs found',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _connectivityService.isOffline
                ? 'Download songs to play offline'
                : 'Pull to refresh',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadSongs, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  void _showSongMenu(BuildContext context, Offset position, Song song) {
    final isDownloaded =
        song.isDownloaded || _downloadController.isSongDownloaded(song.id);

    showMenu(
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
                isDownloaded ? Icons.check : Icons.download,
                color: isDownloaded ? Colors.green : Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isDownloaded ? 'Downloaded' : 'Download',
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
    ).then((selected) {
      if (selected == 'download' && !isDownloaded) {
        _downloadController.downloadSongModel(song);
        Get.snackbar(
          'Downloaded',
          '${song.title} saved for offline',
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
        );
      } else if (selected == 'save') {
        Get.snackbar(
          'Saved',
          '${song.title} saved to library',
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
        );
      } else if (selected == 'playlist') {
        Get.snackbar(
          'Playlist',
          '${song.title} added to playlist',
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
        );
      }
    });
  }
}
