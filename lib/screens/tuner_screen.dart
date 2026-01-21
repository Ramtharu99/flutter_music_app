import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/screens/account_screen.dart';
import 'package:music_app/screens/playlist_screen.dart';
import 'package:music_app/screens/search_screen.dart';
import 'package:music_app/screens/songs_list_screen.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';
import 'package:music_app/utils/app_colors.dart';
import 'package:music_app/widgets/bottom_player.dart';
import 'package:music_app/widgets/chip_widget.dart';
import 'package:music_app/widgets/empty_state.dart';
import 'package:music_app/widgets/music_card.dart';
import 'package:music_app/widgets/section_title.dart';
import 'package:music_app/widgets/songs_list.dart';

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
    {'label': 'Offline', 'icon': Icons.file_download_off},
  ];

  // Services
  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  // State
  List<Song> songs = [];
  List<Song> featuredSongs = [];
  List<Song> offlineSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // Load offline songs always
    offlineSongs = _offlineStorage.getDownloadedSongs();

    if (_connectivityService.isOnline) {
      await _loadOnlineData();
    } else {
      _loadOfflineData();
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadOnlineData() async {
    try {
      final songsResponse = await _apiService.getSongs();
      if (songsResponse.success && songsResponse.data != null) {
        songs = songsResponse.data!;
        _offlineStorage.cacheSongs(songs);
      }

      final featuredResponse = await _apiService.getFeaturedSongs();
      if (featuredResponse.success && featuredResponse.data != null) {
        featuredSongs = featuredResponse.data!;
      }
    } catch (e) {
      debugPrint('Error loading online data: $e');
      _loadOfflineData();
    }
  }

  void _loadOfflineData() {
    songs = _offlineStorage.getCachedSongs();
    featuredSongs = songs.take(5).toList();

    if (songs.isEmpty && offlineSongs.isEmpty) {
      setState(() => selectedChip = 'Offline');
    }
  }

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
        title: Obx(() {
          if (_connectivityService.isOffline) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                SizedBox(width: 6),
                Text(
                  'Offline Mode',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SearchScreen()),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () async {
              final authController = Get.find<AuthController>();
              await authController.fetchProfile();
              Get.to(() => const AccountScreen());
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryColor,
              backgroundColor: Colors.black,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: chips
                            .map(
                              (chip) => ChipWidget(
                                label: chip['label'],
                                icon: chip['icon'] as IconData,
                                isSelected: selectedChip == chip['label'],
                                onTap: () {
                                  setState(() => selectedChip = chip['label']);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content
                    if (selectedChip == 'Sounds') ...[
                      const SectionTitle(title: 'Sounds'),
                      const SizedBox(height: 12),
                      const Text(
                        'Ambient & nature sounds coming soon...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],

                    if (selectedChip == 'Frequencies') ...[
                      const SectionTitle(title: 'Frequencies'),
                      const SizedBox(height: 12),
                      const Text(
                        'Healing frequencies coming soon...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],

                    if (selectedChip == 'Songs') ...[
                      const SectionTitle(title: 'Quick picks'),
                      const SizedBox(height: 8),
                      SongsList(
                        songs: selectedChip == 'Offline' ? offlineSongs : songs,
                        offlineStorageService: _offlineStorage,
                        connectivityService: _connectivityService,
                      ),
                    ],

                    if (selectedChip == 'Offline') ...[
                      const SectionTitle(title: 'Downloaded Songs'),
                      const SizedBox(height: 8),
                      if (offlineSongs.isEmpty)
                        const EmptyState(
                          title: 'No downloaded songs',
                          subtitle: 'Download songs to play them offline',
                        )
                      else
                        SongsList(
                          songs: songs,
                          offlineStorageService: _offlineStorage,
                          connectivityService: _connectivityService,
                        ),
                    ],

                    if (selectedChip == 'All') ...[
                      SectionTitle(
                        title: 'Playlist',
                        onMoreTap: () => Get.to(() => PlaylistScreen()),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: featuredSongs.isNotEmpty
                              ? featuredSongs
                                    .map(
                                      (song) => MusicCard(
                                        image: song.coverImage,
                                        title: song.title,
                                        artist: song.artist,
                                        onTap: () {
                                          MusicController.playFromUrl(
                                            url: song.fileUrl!,
                                            title: song.title,
                                            artist: song.artist,
                                            imageUrl: song.coverImage,
                                          );
                                        },
                                      ),
                                    )
                                    .toList()
                              : [
                                  MusicCard(
                                    image: 'assets/images/logo.png',
                                    title: 'Unknown Song',
                                    artist: 'Unknown Artist',
                                  ),
                                ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SectionTitle(
                        title: 'Quick picks',
                        onMoreTap: () => Get.to(() => SongsListScreen()),
                      ),
                      const SizedBox(height: 8),
                      SongsList(
                        songs: songs,
                        offlineStorageService: _offlineStorage,
                        connectivityService: _connectivityService,
                      ),
                    ],
                  ],
                ),
              ),
            ),
      bottomSheet: const BottomPlayer(),
    );
  }
}
