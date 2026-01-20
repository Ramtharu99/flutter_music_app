import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/music_controller.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  List<String> _recentSearches = [];
  List<Song> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    _recentSearches = _offlineStorage.getRecentSearches();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    // Save to recent searches
    await _offlineStorage.addRecentSearch(query);
    _recentSearches = _offlineStorage.getRecentSearches();

    if (_connectivityService.isOnline) {
      // Online: Search via API
      try {
        final response = await _apiService.searchSongs(query);
        if (response.success && response.data != null) {
          _searchResults = response.data!;
        } else {
          _errorMessage = response.message;
          // Fallback to local search
          _searchLocally(query);
        }
      } catch (e) {
        _errorMessage = 'Search failed';
        _searchLocally(query);
      }
    } else {
      // Offline: Search local data
      _searchLocally(query);
    }

    setState(() => _isSearching = false);
  }

  void _searchLocally(String query) {
    // Search in cached and downloaded songs
    final cachedSongs = _offlineStorage.getCachedSongs();
    final downloadedSongs = _offlineStorage.getDownloadedSongs();

    final allSongs = [...cachedSongs, ...downloadedSongs];
    final uniqueSongs = <int, Song>{};
    for (final song in allSongs) {
      uniqueSongs[song.id] = song;
    }

    _searchResults = uniqueSongs.values.where((song) {
      final titleMatch = song.title.toLowerCase().contains(query.toLowerCase());
      final artistMatch = song.artist.toLowerCase().contains(
        query.toLowerCase(),
      );
      return titleMatch || artistMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            if (_connectivityService.isOffline) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search for songs, artists...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  icon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.length >= 2) {
                    _performSearch(value);
                  }
                },
                onSubmitted: _performSearch,
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_searchController.text.isEmpty) {
      // Show recent searches
      return _buildRecentSearches();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          "No results found",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Show search results
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return ListTile(
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
              url: song.localPath ?? song.fileUrl!,
              title: song.title,
              artist: song.artist,
              imageUrl: song.coverImage,
            );
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildSongImage(song),
          ),
          title: Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: song.isDownloaded
              ? Icon(
                  Icons.download_done,
                  color: Colors.green.shade400,
                  size: 18,
                )
              : null,
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Searches",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await _offlineStorage.clearRecentSearches();
                  _loadRecentSearches();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(
              child: Text(
                'No recent searches',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _recentSearches.map((e) => _chip(e)).toList(),
          ),
      ],
    );
  }

  Widget _chip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSongImage(Song song) {
    final imageUrl = song.coverImage;

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
      );
    }

    return Image.asset(
      imageUrl.isNotEmpty ? imageUrl : 'assets/images/logo.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade800,
      child: const Icon(Icons.music_note, color: Colors.white),
    );
  }
}
