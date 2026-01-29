import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/controllers/video_controller.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/screens/account_screen.dart';
import 'package:music_app/screens/playlist_screen.dart';
import 'package:music_app/screens/search_screen.dart';
import 'package:music_app/screens/songs_list_screen.dart';
import 'package:music_app/screens/video_player_screen.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';
import 'package:music_app/utils/app_colors.dart';
import 'package:music_app/widgets/bottom_player.dart';
import 'package:music_app/widgets/chip_widget.dart';
import 'package:music_app/widgets/empty_state.dart';
import 'package:music_app/widgets/music_card.dart';
import 'package:music_app/widgets/refreshable_scroll_view.dart';
import 'package:music_app/widgets/section_title.dart';
import 'package:music_app/widgets/song_menu.dart';
import 'package:music_app/widgets/songs_list.dart';

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});

  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  int selectedIndex = 0;
  late PageController _pageController;

  // Multi-select state
  Set<int> _selectedSongIds = {};
  bool _isMultiSelectMode = false;

  final List<Map<String, dynamic>> chips = [
    {'label': 'All', 'icon': Icons.library_music},
    {'label': 'Songs', 'icon': Icons.music_note},
    {'label': 'Frequencies', 'icon': Icons.waves},
    {'label': 'Videos', 'icon': Icons.video_camera_back},
    {'label': 'Offline', 'icon': Icons.file_download},
  ];

  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  final VideoController videoController = Get.find<VideoController>();

  List<Song> songs = [];
  List<Song> featuredSongs = [];
  List<Song> offlineSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Load songs from API / cache / offline
  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Get all downloaded songs
      final downloadedSongs = _offlineStorage.getDownloadedSongs();

      List<Song> allSongs = [];

      if (_connectivityService.isOnline) {
        final response = await _apiService.getMusic();
        if (response.success && response.data != null) {
          allSongs = response.data!;
          await _offlineStorage.cacheSongs(allSongs);
        } else {
          allSongs = _offlineStorage.getCachedSongs();
        }
      } else {
        allSongs = _offlineStorage.getCachedSongs();
      }

      songs = allSongs;
      featuredSongs = allSongs.take(5).toList();
      offlineSongs = downloadedSongs;
    } catch (e) {
      debugPrint('Error loading songs: $e');
      songs = _offlineStorage.getCachedSongs();
      featuredSongs = songs.take(5).toList();
      offlineSongs = _offlineStorage.getDownloadedSongs();
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Play a song
  void _playSong(Song song) {
    if (song.fileUrl != null && song.fileUrl!.isNotEmpty) {
      MusicController.playFromSong(song);
    } else {
      debugPrint('This song has no file URL');
    }
  }

  /// Dummy video loader
  Future<void> _loadVideos() async {
    setState(() => isLoading = true);
    setState(() => isLoading = false);
  }

  /// Multi-select toggle
  void _toggleSelection(Song song) {
    setState(() {
      if (_selectedSongIds.contains(song.id)) {
        _selectedSongIds.remove(song.id);
        if (_selectedSongIds.isEmpty) _isMultiSelectMode = false;
      } else {
        _selectedSongIds.add(song.id);
        _isMultiSelectMode = true;
      }
    });
  }

  /// Delete selected songs from offline section
  Future<void> _deleteSelectedSongs() async {
    final songsToDelete = offlineSongs
        .where((s) => _selectedSongIds.contains(s.id))
        .toList();

    for (var song in songsToDelete) {
      await _offlineStorage.removeDownloadedSong(song.id.toString());
      offlineSongs.removeWhere((s) => s.id == song.id);
    }

    setState(() {
      _selectedSongIds.clear();
      _isMultiSelectMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/logo.png',
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const SearchScreen()),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Get.to(() => AccountScreen()),
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                /// CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(chips.length, (index) {
                      final chip = chips[index];
                      return ChipWidget(
                        label: chip['label'],
                        icon: chip['icon'],
                        isSelected: selectedIndex == index,
                        onTap: () {
                          setState(() => selectedIndex = index);
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                /// PAGES
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => selectedIndex = index);
                    },
                    children: [
                      /// ALL PAGE
                      RefreshableScrollView(
                        onRefresh: _loadData,
                        color: AppColors.primaryColor,
                        backgroundColor: Colors.black,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(
                              title: 'Featured',
                              onMoreTap: () => Get.to(() => PlaylistScreen()),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredSongs.length,
                                itemBuilder: (_, index) {
                                  final song = featuredSongs[index];
                                  return MusicCard(
                                    image: song.coverImage,
                                    title: song.title,
                                    artist: song.artist,
                                    onTap: () => _playSong(song),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            SectionTitle(
                              title: 'All Songs',
                              onMoreTap: () => Get.to(() => SongsListScreen()),
                            ),
                            SongsList(
                              songs: songs,
                              offlineStorageService: _offlineStorage,
                              connectivityService: _connectivityService,
                              onSongTap: _playSong,
                              menuType: SongMenuType.all,
                              // Show download button
                              onDeleteSelected: (selectedSongs) async {
                                for (var s in selectedSongs) {
                                  await _offlineStorage.removeDownloadedSong(
                                    s.id.toString(),
                                  );
                                  offlineSongs.removeWhere(
                                    (song) => song.id == s.id,
                                  );
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),

                      /// SONGS PAGE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RefreshableScrollView(
                          onRefresh: _loadData,
                          color: AppColors.primaryColor,
                          backgroundColor: Colors.black,
                          child: SongsList(
                            songs: songs,
                            offlineStorageService: _offlineStorage,
                            connectivityService: _connectivityService,
                            onSongTap: _playSong,
                            menuType: SongMenuType.all,
                          ),
                        ),
                      ),

                      const Center(
                        child: Text(
                          'Healing frequencies coming soon...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                      /// VIDEOS PAGE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RefreshableScrollView(
                          onRefresh: _loadVideos,
                          color: AppColors.primaryColor,
                          backgroundColor: Colors.black,
                          child: Column(
                            children: [
                              if (videoController.videos.isEmpty)
                                const EmptyState(
                                  title: 'No videos available',
                                  subtitle: 'Pull down to refresh',
                                )
                              else
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: videoController.videos.length,
                                  itemBuilder: (context, index) {
                                    final video = videoController.videos[index];
                                    return ListTile(
                                      leading: CachedNetworkImage(
                                        imageUrl: video.thumbnail,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        video.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.red,
                                      ),
                                      onTap: () async {
                                        await videoController.initializePlayer(
                                          index,
                                        );
                                        Get.to(
                                          () => VideoPlayerScreen(index: index),
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      /// OFFLINE PAGE
                      offlineSongs.isEmpty
                          ? const EmptyState(
                              title: 'No downloaded songs',
                              subtitle: 'Download songs to play offline',
                            )
                          : RefreshableScrollView(
                              onRefresh: _loadData,
                              color: AppColors.primaryColor,
                              backgroundColor: Colors.black,
                              child: Column(
                                children: [
                                  if (_isMultiSelectMode)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: _deleteSelectedSongs,
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          label: const Text(
                                            'Delete Selected',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  SongsList(
                                    songs: offlineSongs,
                                    offlineStorageService: _offlineStorage,
                                    connectivityService: _connectivityService,
                                    onSongTap: _playSong,
                                    showOfflineOptions: true,
                                    menuType: SongMenuType.offline,
                                    // delete only
                                    onDeleteSelected: (selectedSongs) async {
                                      for (var s in selectedSongs) {
                                        await _offlineStorage
                                            .removeDownloadedSong(
                                              s.id.toString(),
                                            );
                                        offlineSongs.removeWhere(
                                          (song) => song.id == s.id,
                                        );
                                      }
                                      setState(() {
                                        _selectedSongIds.clear();
                                        _isMultiSelectMode = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomPlayer(),
    );
  }
}
