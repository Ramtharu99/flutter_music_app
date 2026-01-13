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
  String selectedChip = 'All';

  final List<Map<String, dynamic>> chips = [
    {'label': 'All', 'icon': Icons.library_music},
    {'label': 'Sounds', 'icon': Icons.graphic_eq},
    {'label': 'Frequencies', 'icon': Icons.waves},
    {'label': 'Songs', 'icon': Icons.music_note},
    {'label': 'Offline', 'icon': Icons.download},
  ];

  final List<Map<String, String>> songs = [
    {
      'title': 'Song 1',
      'subtitle': 'Song 1 description',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'title': 'Song 2',
      'subtitle': 'Song 2 description',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
  ];

  final List<Map<String, String>> offlineSongs = [
    {'title': 'Offline Song 1', 'subtitle': 'Offline description'},
    {'title': 'Offline Song 2', 'subtitle': 'Offline description'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/images/logo.png'),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SearchScreen()),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Get.to(() => const AccountScreen()),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 CHIP ROW
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips
                    .map(
                      (chip) => _chip(chip['label'], chip['icon'] as IconData),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 CONTENT BASED ON SELECTED CHIP
            if (selectedChip == 'Sounds') ...[
              _sectionTitle('Sounds'),
              const SizedBox(height: 12),
              const Text(
                'Ambient & nature sounds coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
            ],

            if (selectedChip == 'Frequencies') ...[
              _sectionTitle('Frequencies'),
              const SizedBox(height: 12),
              const Text(
                'Healing frequencies coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
            ],

            if (selectedChip == 'Songs') ...[
              _sectionTitle('Quick picks'),
              const SizedBox(height: 8),
              Column(
                children: songs.map((song) {
                  return MusicListTile(
                    image: 'assets/images/logo.png',
                    title: song['title']!,
                    subtitle: song['subtitle']!,
                    onTap: () {
                      MusicController.playFromUrl(
                        url: song['url']!,
                        title: song['title']!,
                        artist: '',
                        imageUrl: 'assets/images/logo.png',
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
                  );
                }).toList(),
              ),
            ],

            if (selectedChip == 'Offline') ...[
              _sectionTitle('Offline songs'),
              const SizedBox(height: 8),
              Column(
                children: offlineSongs.map((song) {
                  return MusicListTile(
                    image: 'assets/images/logo.png',
                    title: song['title']!,
                    subtitle: song['subtitle']!,
                    onTap: () {
                      MusicController.playFromUrl(
                        url: '', // Replace with offline path
                        title: song['title']!,
                        artist: '',
                        imageUrl: 'assets/images/logo.png',
                      );
                    },
                    onMoreTap: (position) {
                      _showSongMenu(
                        context,
                        position,
                        song['title']!,
                        'offline',
                      );
                    },
                  );
                }).toList(),
              ),
            ],

            if (selectedChip == 'All') ...[
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Quick picks'),
              const SizedBox(height: 8),
              Column(
                children: songs.map((song) {
                  return MusicListTile(
                    image: 'assets/images/logo.png',
                    title: song['title']!,
                    subtitle: song['subtitle']!,
                    onTap: () {
                      MusicController.playFromUrl(
                        url: song['url']!,
                        title: song['title']!,
                        artist: '',
                        imageUrl: 'assets/images/logo.png',
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
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: const BottomPlayer(),
    );
  }

  /// 🔹 CHIP WIDGET
  Widget _chip(String text, IconData icon) {
    final bool isSelected = selectedChip == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedChip = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 SECTION TITLE
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

  /// 🔹 SONG MENU
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
