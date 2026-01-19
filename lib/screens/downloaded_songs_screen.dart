import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/utils/app_colors.dart';

import '../controllers/download_controller.dart';
import '../controllers/music_controller.dart';

class DownloadedSongsScreen extends StatefulWidget {
  const DownloadedSongsScreen({super.key});

  @override
  State<DownloadedSongsScreen> createState() => _DownloadedSongsScreenState();
}

class _DownloadedSongsScreenState extends State<DownloadedSongsScreen> {
  final DownloadController downloadController = DownloadController();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  Future<void> _onRefresh() async {
    if (_connectivityService.isOffline) return;

    downloadController.downloadedSongs;

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    List<String> downloadedSongs = downloadController.getDownloadedSongs();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: const Text(
          'Downloaded Songs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Colors.black,
        onRefresh: _onRefresh,
        child: downloadedSongs.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'No downloaded songs',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: downloadedSongs.length,
                itemBuilder: (context, index) {
                  final songTitle = downloadedSongs[index];
                  return ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.white),
                    title: Text(
                      songTitle,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      MusicController.playFromUrl(
                        url: 'assets/music/song1.mp3',
                        title: songTitle,
                        artist: 'Dj Nova',
                        imageUrl: 'assets/images/logo.png',
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
