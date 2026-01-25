import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int selectedIndex = 0;
  late PageController _pageController;

  final List<Map<String, dynamic>> chips = [
    {'label': 'All', 'icon': Icons.library_music},
    {'label': 'Songs', 'icon': Icons.music_note},
    {'label': 'Frequencies', 'icon': Icons.waves},
    {'label': 'Offline', 'icon': Icons.file_download},
  ];

  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

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

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    // All downloaded songs
    final downloadedSongs = _offlineStorage.getDownloadedSongs();

    // Get all songs from API or cache
    List<Song> allSongs;
    if (_connectivityService.isOnline) {
      final response = await _apiService.getSongs();
      if (response.success && response.data != null) {
        allSongs = response.data!;
        _offlineStorage.cacheSongs(allSongs);
      } else {
        allSongs = _offlineStorage.getCachedSongs();
      }
    } else {
      allSongs = _offlineStorage.getCachedSongs();
    }

    offlineSongs = downloadedSongs
        .where((d) => allSongs.every((s) => s.id != d.id))
        .map((song) {
          return song.copyWith(
            coverImage: song.coverImage.isNotEmpty
                ? song.coverImage
                : song.coverImage,
          );
        })
        .toList();

    // Featured songs: first 5 songs
    featuredSongs = allSongs.take(5).toList();

    songs = allSongs;

    setState(() => isLoading = false);
  }

  /// Play a song using MusicController
  void _playSong(Song song) {
    if (song.fileUrl != null && song.fileUrl!.isNotEmpty) {
      MusicController.playFromSong(song);
    } else {
      debugPrint('this song has not file url');
    }
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
                      RefreshIndicator(
                        onRefresh: _loadData,
                        color: AppColors.primaryColor,
                        backgroundColor: Colors.black,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
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
                                onMoreTap: () =>
                                    Get.to(() => SongsListScreen()),
                              ),
                              SongsList(
                                songs: songs,
                                offlineStorageService: _offlineStorage,
                                connectivityService: _connectivityService,
                                onSongTap: _playSong,
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// SONGS PAGE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primaryColor,
                          backgroundColor: Colors.black,
                          child: SongsList(
                            songs: songs,
                            offlineStorageService: _offlineStorage,
                            connectivityService: _connectivityService,
                            onSongTap: _playSong,
                          ),
                        ),
                      ),

                      const Center(
                        child: Text(
                          'Healing frequencies coming soon...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                      /// OFFLINE PAGE
                      offlineSongs.isEmpty
                          ? const EmptyState(
                              title: 'No downloaded songs',
                              subtitle: 'Download songs to play offline',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppColors.primaryColor,
                              backgroundColor: Colors.black,
                              child: SongsList(
                                songs: offlineSongs,
                                offlineStorageService: _offlineStorage,
                                connectivityService: _connectivityService,
                                onSongTap: _playSong,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
      bottomSheet: const BottomPlayer(),
    );
  }
}
