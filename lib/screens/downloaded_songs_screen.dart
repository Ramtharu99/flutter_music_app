import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/download_controller.dart';
import '../controllers/music_controller.dart';

class DownloadedSongsScreen extends StatefulWidget {
  const DownloadedSongsScreen({super.key});

  @override
  State<DownloadedSongsScreen> createState() => _DownloadedSongsScreenState();
}

class _DownloadedSongsScreenState extends State<DownloadedSongsScreen> {
  final DownloadController downloadController = DownloadController();

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
      body: downloadedSongs.isEmpty
          ? const Center(
              child: Text(
                'No downloaded songs',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
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
                    // Play the downloaded song
                    MusicController.playAsset(
                      path: 'assets/music/song1.mp3',
                      // Replace with actual local path later
                      title: songTitle,
                      subtitle: '',
                    );
                  },
                );
              },
            ),
    );
  }
}
