import 'package:get/get.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/offline_storage_service.dart';

class DownloadController extends GetxController {
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  // Observable state
  final RxList<Song> _downloadedSongs = <Song>[].obs;
  final RxBool _isDownloading = false.obs;
  final RxString _currentDownloadId = ''.obs;

  // Getters
  List<Song> get downloadedSongs => _downloadedSongs;

  bool get isDownloading => _isDownloading.value;

  String get currentDownloadId => _currentDownloadId.value;

  @override
  void onInit() {
    super.onInit();
    _loadDownloadedSongs();
  }

  /// Load downloaded songs from storage
  void _loadDownloadedSongs() {
    _downloadedSongs.value = _offlineStorage.getDownloadedSongs();
  }

  /// Get downloaded songs (legacy method for compatibility)
  List<String> getDownloadedSongs() {
    return _downloadedSongs.map((s) => s.title).toList();
  }

  /// Download a song (save to offline storage)
  Future<void> downloadSong(String title, {Song? song}) async {
    _isDownloading.value = true;
    _currentDownloadId.value = song?.id.toString() ?? title;

    try {
      // Simulate download delay
      await Future.delayed(const Duration(seconds: 1));

      if (song != null) {
        final downloadedSong = song.copyWith(isDownloaded: true);
        await _offlineStorage.saveDownloadedSong(downloadedSong);
        _downloadedSongs.add(downloadedSong);
      } else {
        // Legacy support - create a basic song from title
        final basicSong = Song(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          artist: 'Unknown Artist',
          fileUrl: '',
          coverImage: 'assets/images/logo.png',
          duration: 0,
          price: '0.00',
          description: '',
          playsCount: 0,
          isPurchased: false,
          isDownloaded: true,
        );
        await _offlineStorage.saveDownloadedSong(basicSong);
        _downloadedSongs.add(basicSong);
      }

      update();
    } finally {
      _isDownloading.value = false;
      _currentDownloadId.value = '';
    }
  }

  /// Download song with full Song model
  Future<void> downloadSongModel(Song song) async {
    await downloadSong(song.title, song: song);
  }

  /// Remove a downloaded song
  Future<void> removeSong(String titleOrId) async {
    await _offlineStorage.removeDownloadedSong(titleOrId);
    _downloadedSongs.removeWhere(
      (s) => s.id == titleOrId || s.title == titleOrId,
    );
    update();
  }

  /// Check if a song is downloaded
  bool isSongDownloaded(dynamic songId) {
    return _downloadedSongs.any(
      (s) => s.id == songId || s.id.toString() == songId.toString(),
    );
  }

  /// Check if song title is downloaded (legacy)
  bool isTitleDownloaded(String title) {
    return _downloadedSongs.any((s) => s.title == title);
  }

  /// Get downloaded song by ID
  Song? getDownloadedSong(int songId) {
    try {
      return _downloadedSongs.firstWhere((s) => s.id == songId);
    } catch (_) {
      return null;
    }
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    for (final song in _downloadedSongs) {
      await _offlineStorage.removeDownloadedSong(song.id.toString());
    }
    _downloadedSongs.clear();
    update();
  }

  /// Refresh downloaded songs from storage
  @override
  void refresh() {
    _loadDownloadedSongs();
  }
}
