import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/models/models.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';
import 'package:music_app/utils/app_colors.dart';
import 'package:music_app/widgets/bottom_player.dart';

import '../controllers/music_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/songs_list.dart';

class DownloadedSongsScreen extends StatefulWidget {
  const DownloadedSongsScreen({super.key});

  @override
  State<DownloadedSongsScreen> createState() => _DownloadedSongsScreenState();
}

class _DownloadedSongsScreenState extends State<DownloadedSongsScreen> {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  List<Song> offlineSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load downloaded songs from offline storage
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Small delay for smooth RefreshIndicator animation
    await Future.delayed(const Duration(milliseconds: 300));

    // Get downloaded songs
    final downloadedSongs = _offlineStorage.getDownloadedSongs();

    // Remove duplicates by song ID
    final uniqueSongs = <int, Song>{};
    for (var song in downloadedSongs) {
      uniqueSongs[song.id] = song;
    }

    setState(() {
      offlineSongs = uniqueSongs.values.toList();
      _isLoading = false;
    });
  }

  /// Play tapped song
  void _playSong(Song song) {
    if (song.fileUrl != null && song.fileUrl!.isNotEmpty) {
      MusicController.playFromSong(song);
    } else {
      Get.snackbar(
        'Error',
        'Song file not available.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: const Text(
          'Offline Songs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : offlineSongs.isEmpty
          ? const EmptyState(
              title: 'No downloaded songs',
              subtitle: 'Download songs to play offline',
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryColor,
              backgroundColor: Colors.black,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: offlineSongs.map((song) {
                    return SongsList(
                      songs: [song],
                      offlineStorageService: _offlineStorage,
                      connectivityService: _connectivityService,
                      onSongTap: _playSong,
                    );
                  }).toList(),
                ),
              ),
            ),
      bottomSheet: const BottomPlayer(),
    );
  }
}
