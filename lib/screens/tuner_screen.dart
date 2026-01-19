import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/download_controller.dart';
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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Always load offline songs
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
      // Fetch songs from API
      final songsResponse = await _apiService.getSongs();
      if (songsResponse.success && songsResponse.data != null) {
        songs = songsResponse.data!;
        // Cache for offline use
        _offlineStorage.cacheSongs(songs);
      }

      // Fetch featured songs
      final featuredResponse = await _apiService.getFeaturedSongs();
      if (featuredResponse.success && featuredResponse.data != null) {
        featuredSongs = featuredResponse.data!;
      }
    } catch (e) {
      debugPrint('Error loading online data: $e');
      // Fallback to cached data
      _loadOfflineData();
    }
  }

  /// Load cached data when offline
  void _loadOfflineData() {
    songs = _offlineStorage.getCachedSongs();
    featuredSongs = songs.take(5).toList();

    if (songs.isEmpty && offlineSongs.isEmpty) {
      setState(() {
        selectedChip = 'Offline';
      });
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                const SizedBox(width: 6),
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
            onPressed: () => Get.to(() => const AccountScreen()),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
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
                              (chip) => _chip(
                                chip['label'],
                                chip['icon'] as IconData,
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Content based on selected chip
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
                      _buildSongsList(songs),
                    ],

                    if (selectedChip == 'Offline') ...[
                      _sectionTitle('Downloaded Songs'),
                      const SizedBox(height: 8),
                      if (offlineSongs.isEmpty)
                        _emptyState(
                          'No downloaded songs',
                          'Download songs to play them offline',
                        )
                      else
                        _buildSongsList(offlineSongs),
                    ],

                    if (selectedChip == 'All') ...[
                      _sectionTitle(
                        'Playlist',
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
                                        image: song.imageUrl,
                                        title: song.title,
                                        artist: song.artist,
                                        onTap: () {
                                          MusicController.playFromUrl(
                                            url: song.url,
                                            title: song.title,
                                            artist: song.artist,
                                            imageUrl: song.imageUrl,
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

                      _sectionTitle(
                        'Quick picks',
                        onMoreTap: () => Get.to(() => SongsListScreen()),
                      ),
                      const SizedBox(height: 8),
                      _buildSongsList(songs),

                      // Show offline songs if available
                      if (offlineSongs.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Offline Songs'),
                        const SizedBox(height: 8),
                        _buildSongsList(offlineSongs.take(3).toList()),
                      ],
                    ],
                  ],
                ),
              ),
            ),
      bottomSheet: const BottomPlayer(),
    );
  }

  /// Build songs list widget
  Widget _buildSongsList(List<Song> songsList) {
    if (songsList.isEmpty) {
      return Center(
        child: _emptyState(
          'No songs available',
          _connectivityService.isOffline
              ? 'Connect to internet to load songs'
              : 'Pull to refresh',
        ),
      );
    }

    return Column(
      children: songsList.map((song) {
        return MusicListTile(
          image: song.imageUrl.startsWith('http')
              ? song.imageUrl
              : 'assets/images/logo.png',
          title: song.title,
          subtitle: song.artist,
          onTap: () {
            if (_connectivityService.isOffline && !song.isDownloaded) {
              Get.snackbar(
                'Offline',
                'This song is not available offline',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            MusicController.playFromUrl(
              url: song.localPath ?? song.url,
              title: song.title,
              artist: song.artist,
              imageUrl: song.imageUrl,
            );
          },
          onMoreTap: (position) {
            _showSongMenu(context, position, song);
          },
        );
      }).toList(),
    );
  }

  /// Empty state widget
  Widget _emptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.music_off, size: 48, color: Colors.grey.shade600),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

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
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onMoreTap}) {
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
        if (onMoreTap != null)
          InkWell(
            onTap: onMoreTap,
            child: Text('More', style: TextStyle(color: Colors.grey.shade400)),
          ),
      ],
    );
  }

  void _showSongMenu(BuildContext context, Offset position, Song song) async {
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
      // Save song to offline storage
      final downloadedSong = song.copyWith(isDownloaded: true);
      _offlineStorage.saveDownloadedSong(downloadedSong);
      downloadController.downloadSong(song.title);

      Get.snackbar(
        'Downloaded',
        '${song.title} saved for offline playback',
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
      );

      // Refresh to show updated state
      setState(() {
        offlineSongs = _offlineStorage.getDownloadedSongs();
      });
    }
  }
}
