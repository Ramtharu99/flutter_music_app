import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/api_service.dart';

class MusicController extends GetxController {
  static final AudioPlayer _player = AudioPlayer();
  final ApiService _apiService = ApiService();

  // Observable state
  final RxBool _isLoading = false.obs;
  final RxList<Song> _allSongs = <Song>[].obs;
  final RxList<Song> _filteredSongs = <Song>[].obs;
  final Rxn<Song> _currentSong = Rxn<Song>();
  final RxString _searchQuery = ''.obs;
  final RxString _selectedGenre = ''.obs;
  final RxString _selectedArtist = ''.obs;

  static final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  static final ValueNotifier<String?> currentTitle = ValueNotifier(null);
  static final ValueNotifier<String?> currentSubtitle = ValueNotifier(null);
  static final ValueNotifier<Duration> currentPosition = ValueNotifier(
    Duration.zero,
  );
  static final ValueNotifier<Duration> totalDuration = ValueNotifier(
    Duration.zero,
  );
  static final ValueNotifier<int?> currentIndex = ValueNotifier(null);
  static final ValueNotifier<bool> isShuffle = ValueNotifier(false);
  static final ValueNotifier<LoopMode> loopMode = ValueNotifier(LoopMode.off);

  static List<AudioSource> _playlist = [];

  // Getters
  bool get isLoading => _isLoading.value;
  List<Song> get allSongs => _allSongs;
  List<Song> get filteredSongs => _filteredSongs;
  Song? get currentSong => _currentSong.value;
  String get searchQuery => _searchQuery.value;
  String get selectedGenre => _selectedGenre.value;
  String get selectedArtist => _selectedArtist.value;

  @override
  void onInit() {
    super.onInit();
    loadAllSongs();
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                   MUSIC LOADING & FILTERING                     ║
  // ═══════════════════════════════════════════════════════════════════

  /// Load all songs from API
  Future<bool> loadAllSongs({int page = 1, int perPage = 50}) async {
    _isLoading.value = true;

    try {
      final response = await _apiService.getMusic(perPage: perPage, page: page);

      if (response.success && response.data != null) {
        if (page == 1) {
          _allSongs.clear();
        }
        _allSongs.addAll(response.data!);
        _filteredSongs.assignAll(_allSongs);

        debugPrint('✅ Loaded ${response.data!.length} songs');
        return true;
      } else {
        debugPrint('❌ Failed to load songs: ${response.message}');
        return false;
      }
    } catch (e) {
      debugPrint('Error loading songs: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Search songs by query
  Future<bool> searchSongs(String query) async {
    _searchQuery.value = query;
    _isLoading.value = true;

    try {
      if (query.isEmpty) {
        _filteredSongs.assignAll(_allSongs);
        _isLoading.value = false;
        return true;
      }

      final response = await _apiService.searchSongs(query);

      if (response.success && response.data != null) {
        _filteredSongs.assignAll(response.data!);
        debugPrint('✅ Found ${response.data!.length} songs');
        return true;
      } else {
        _filteredSongs.clear();
        return false;
      }
    } catch (e) {
      debugPrint('Search error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filter songs by genre
  void filterByGenre(String genre) {
    _selectedGenre.value = genre;
    _applyFilters();
  }

  /// Filter songs by artist
  void filterByArtist(String artist) {
    _selectedArtist.value = artist;
    _applyFilters();
  }

  /// Apply all filters
  void _applyFilters() {
    List<Song> filtered = _allSongs;

    // Apply genre filter
    if (_selectedGenre.value.isNotEmpty) {
      filtered = filtered
          .where(
            (song) =>
                song.genre?.toLowerCase() == _selectedGenre.value.toLowerCase(),
          )
          .toList();
    }

    // Apply artist filter
    if (_selectedArtist.value.isNotEmpty) {
      filtered = filtered
          .where(
            (song) =>
                song.artist.toLowerCase() ==
                _selectedArtist.value.toLowerCase(),
          )
          .toList();
    }

    _filteredSongs.assignAll(filtered);
  }

  /// Clear all filters
  void clearFilters() {
    _selectedGenre.value = '';
    _selectedArtist.value = '';
    _searchQuery.value = '';
    _filteredSongs.assignAll(_allSongs);
  }

  /// Get song by ID
  Future<Song?> getSongById(int musicId) async {
    try {
      final response = await _apiService.getMusicById(musicId);

      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting song by ID: $e');
      return null;
    }
  }

  /// Increment play count for a song
  Future<bool> incrementPlayCount(int musicId) async {
    try {
      final response = await _apiService.incrementPlayCount(musicId);

      if (response.success) {
        // Update local song data
        final songIndex = _allSongs.indexWhere((song) => song.id == musicId);
        if (songIndex != -1) {
          final song = _allSongs[songIndex];
          _allSongs[songIndex] = song.copyWith(playsCount: song.playsCount + 1);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error incrementing play count: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                     MUSIC PLAYBACK                              ║
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> playPlaylist({
    required List<Song> songs,
    int startIndex = 0,
  }) async {
    try {
      _playlist = songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.fileUrl ?? ''),
          tag: MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.artist,
            artUri: Uri.parse(song.coverImage),
          ),
        );
      }).toList();

      await _player.setAudioSources(_playlist, initialIndex: startIndex);

      _listenStreams();
      _player.play();
    } catch (e) {
      debugPrint('Playlist error: $e');
    }
  }

  static Future<void> playFromUrl({
    required String url,
    required String title,
    required String artist,
    required String imageUrl,
  }) async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: title,
            album: artist,
            artUri: Uri.parse(imageUrl),
          ),
        ),
      );

      _listenStreams();
      _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  static Future<void> playFromSong(Song song) async {
    if (song.fileUrl == null || song.fileUrl!.isEmpty) {
      debugPrint('❌ No file URL available for song');
      return;
    }

    await playFromUrl(
      url: song.fileUrl!,
      title: song.title,
      artist: song.artist,
      imageUrl: song.coverImage,
    );
  }

  static void togglePlayPause() {
    _player.playing ? _player.pause() : _player.play();
  }

  static void playNext() {
    if (_player.hasNext) _player.seekToNext();
  }

  static void playPrevious() {
    if (_player.hasPrevious) _player.seekToPrevious();
  }

  static void seekTo(Duration position) {
    _player.seek(position);
  }

  static Future<void> toggleShuffle() async {
    isShuffle.value = !isShuffle.value;
    await _player.setShuffleModeEnabled(isShuffle.value);
  }

  static Future<void> toggleLoop() async {
    if (loopMode.value == LoopMode.off) {
      loopMode.value = LoopMode.one;
    } else if (loopMode.value == LoopMode.one) {
      loopMode.value = LoopMode.all;
    } else {
      loopMode.value = LoopMode.off;
    }
    await _player.setLoopMode(loopMode.value);
  }

  static void _listenStreams() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    _player.positionStream.listen((pos) {
      currentPosition.value = pos;
    });

    _player.durationStream.listen((dur) {
      totalDuration.value = dur ?? Duration.zero;
    });

    _player.currentIndexStream.listen((index) {
      currentIndex.value = index;
      final tag = _player.sequenceState.currentSource?.tag;
      if (tag is MediaItem) {
        currentTitle.value = tag.title;
        currentSubtitle.value = tag.album;
      }
    });
  }

  static Future<void> disposeMusicPlayer() async {
    await _player.dispose();
  }
}
