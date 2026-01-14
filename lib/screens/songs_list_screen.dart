import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/music_controller.dart';
import '../widgets/music_list_tile.dart';

class SongsListScreen extends StatefulWidget {
  const SongsListScreen({super.key});

  @override
  State<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen> {
  List<Map<String, String>> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    songs = [
      {
        'title': 'Selfish',
        'subtitle': 'Justin Timberlake',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        'image': 'assets/images/logo.png',
      },
      {
        'title': 'Mirrors',
        'subtitle': 'Justin Timberlake',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        'image': 'assets/images/logo.png',
      },
      {
        'title': 'Another Song',
        'subtitle': 'Some Artist',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        'image': 'assets/images/logo.png',
      },
    ];

    setState(() => isLoading = false);
  }

  Future<void> _refreshSongs() async {
    await _loadSongs();
  }

  void _showSongMenu(
    BuildContext context,
    Offset position,
    String title,
    String url,
  ) {
    showMenu(
      context: context,
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: const [
        PopupMenuItem(
          value: 'download',
          child: Text('Download', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'save',
          child: Text('Save', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'playlist',
          child: Text('Add to Playlist', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).then((selected) {
      if (selected == 'download') {
        Get.snackbar(
          'Download',
          '$title will be downloaded soon',
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
        );
      } else if (selected == 'save') {
        Get.snackbar(
          'Save',
          '$title saved to library',
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
        );
      } else if (selected == 'playlist') {
        Get.snackbar(
          'Playlist',
          '$title added to playlist',
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
        );
      }
    });
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshSongs,
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
                      image: song['image']!,
                      title: song['title']!,
                      subtitle: song['subtitle']!,
                      onTap: () {
                        MusicController.playFromUrl(
                          url: song['url']!,
                          title: song['title']!,
                          artist: song['subtitle']!,
                          imageUrl: song['image']!,
                        );
                      },
                      onMoreTap: (position) {
                        _showSongMenu(
                          context,
                          position,
                          song['title']!,
                          song['url']!,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
