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
  String selectedChip = 'All';

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    offlineSongs = _offlineStorage.getDownloadedSongs();

    if (_connectivityService.isOnline) {
      final response = await _apiService.getSongs();
      if (response.success && response.data != null) {
        songs = response.data!;
        _offlineStorage.cacheSongs(songs);
        featuredSongs = songs.take(5).toList();
      }
    } else {
      songs = _offlineStorage.getCachedSongs();
      featuredSongs = songs.take(5).toList();
    }

    setState(() => isLoading = false);
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
                    // CHIPS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: chips.map((chip) {
                          return ChipWidget(
                            label: chip['label'],
                            icon: chip['icon'],
                            isSelected: selectedChip == chip['label'],
                            onTap: () {
                              setState(() {
                                selectedChip = chip['label'];
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (selectedChip == 'All') ...[
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
                              onTap: () {
                                MusicController.playFromUrl(
                                  url: song.fileUrl!,
                                  title: song.title,
                                  artist: song.artist,
                                  imageUrl: song.coverImage,
                                );
                              },
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
                      ),
                    ],

                    if (selectedChip == 'Songs')
                      SongsList(
                        songs: songs,
                        offlineStorageService: _offlineStorage,
                        connectivityService: _connectivityService,
                      ),

                    if (selectedChip == 'Frequencies') ...[
                      const SectionTitle(title: 'Frequencies'),
                      const SizedBox(height: 12),
                      const Text(
                        'Healing frequencies coming soon...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],

                    if (selectedChip == 'Offline')
                      offlineSongs.isEmpty
                          ? const EmptyState(
                              title: 'No downloaded songs',
                              subtitle: 'Download songs to play offline',
                            )
                          : SongsList(
                              songs: offlineSongs,
                              offlineStorageService: _offlineStorage,
                              connectivityService: _connectivityService,
                            ),
                  ],
                ),
              ),
            ),
      bottomSheet: const BottomPlayer(),
    );
  }
}
