import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/screens/account_screen.dart';
import 'package:music_app/screens/search_screen.dart';
import 'package:music_app/widgets/bottom_player.dart';
import 'package:music_app/widgets/music_card.dart';
import 'package:music_app/widgets/music_list_tile.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/logo.png',
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SearchScreen()),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Get.to(() => AccountScreen()),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [_chip('Sounds'), _chip('Frequencies'), _chip('Songs')],
            ),

            const SizedBox(height: 24),

            _sectionTitle('New releases'),

            const SizedBox(height: 12),

            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  MusicCard(
                    image: 'assets/images/logo.png',
                    title: 'Selfish',
                    artist: 'Justin Timberlake',
                  ),
                  MusicCard(
                    image: 'assets/images/logo.png',
                    title: 'Mugshot',
                    artist: 'Huddy',
                  ),
                  MusicCard(
                    image: 'assets/images/logo.png',
                    title: 'Mugshot',
                    artist: 'Huddy',
                  ),
                  MusicCard(
                    image: 'assets/images/logo.png',
                    title: 'Mugshot',
                    artist: 'Huddy',
                  ),
                  MusicCard(
                    image: 'assets/images/logo.png',
                    title: 'Mugshot',
                    artist: 'Huddy',
                  ),
                  MusicCard(
                    image: 'assets/images/logo.png',
                    title: 'Mugshot',
                    artist: 'Huddy',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Quick picks'),
            const SizedBox(height: 8),
            Column(
              children: [
                MusicListTile(
                  image: 'assets/images/logo.png',
                  title: 'song 1',
                  subtitle: 'song 1 description',
                  onTap: () {
                    MusicController.playFromUrl(
                      url:
                          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                      title: 'song1',
                      artist: '',
                      imageUrl: 'assets/images/logo.png',
                    );
                  },
                  onMoreTap: (position) {
                    _showSongMenu(
                      context,
                      position,
                      'song1',
                      'assets/music/song1.mp3',
                    );
                  },
                ),
                MusicListTile(
                  image: 'assets/images/logo.png',
                  title: 'song 2',
                  subtitle: 'song 2 description',
                  onTap: () {
                    MusicController.playFromUrl(
                      url:
                          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                      title: 'song 2',
                      artist: 'song',
                      imageUrl: 'assets/images/logo.png',
                    );
                  },
                  onMoreTap: (position) {
                    _showSongMenu(
                      context,
                      position,
                      'song2',
                      'assets/music/song1.mp3',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: BottomPlayer(),
    );
  }

  Widget _chip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('More', style: TextStyle(color: Colors.grey.shade400)),
      ],
    );
  }

  void _showSongMenu(
    BuildContext context,
    Offset position,
    String title,
    String path,
  ) async {
    final DownloadController downloadController = DownloadController();

    final selected = await showMenu(
      context: context,
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'download',
          child: Text('Download', style: TextStyle(color: Colors.white)),
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

    if (selected == 'download') {
      downloadController.downloadSong(title);
      Get.snackbar(
        'Downloaded',
        '$title saved successfully',
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );
    }
  }
}
