import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/offline_storage_service.dart';

class DownloadController extends GetxController {
  final OfflineStorageService _offlineStorage = OfflineStorageService();

  // Observable state
  final RxList<Song> _downloadedSongs = <Song>[].obs;
  final RxMap<String, double> _downloadProgress = <String, double>{}.obs;
  final RxSet<String> _downloadingIds = <String>{}.obs;
  final RxString _currentDownloadingTitle = ''.obs;

  // Recursion guard
  bool _isLoadingSongs = false;

  // Getters
  List<Song> get downloadedSongs => _downloadedSongs;

  Map<String, double> get downloadProgress => _downloadProgress;

  Set<String> get downloadingIds => _downloadingIds;

  String get currentDownloadingTitle => _currentDownloadingTitle.value;

  bool isDownloading(String songId) => _downloadingIds.contains(songId);

  double getProgress(String songId) => _downloadProgress[songId] ?? 0.0;

  @override
  void onInit() {
    super.onInit();
    _loadDownloadedSongs();
  }

  /// Load downloaded songs from storage (with recursion protection)
  void _loadDownloadedSongs() {
    if (_isLoadingSongs) {
      debugPrint('⚠️ Avoided recursive call to _loadDownloadedSongs');
      return;
    }

    _isLoadingSongs = true;
    try {
      final songs = _offlineStorage.getDownloadedSongs();
      _downloadedSongs.value = songs;
      // NO .update() here — .obs already notifies listeners
    } catch (e) {
      debugPrint('Error loading downloaded songs: $e');
      _downloadedSongs.clear();
    } finally {
      _isLoadingSongs = false;
    }
  }

  /// Get downloaded songs titles (legacy method)
  List<String> getDownloadedSongs() {
    return _downloadedSongs.map((s) => s.title).toList();
  }

  /// Download a song with offline storage
  Future<void> downloadSong(Song song) async {
    final songId = song.id.toString();

    if (_downloadingIds.contains(songId)) {
      Get.snackbar(
        'Already Downloading',
        '${song.title} is already being downloaded',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    _downloadingIds.add(songId);
    _currentDownloadingTitle.value = song.title;
    _downloadProgress[songId] = 0.0;
    update();

    try {
      // Simulate realistic download with progress updates (for UI only)
      for (int progress = 0; progress <= 100; progress += 5) {
        await Future.delayed(const Duration(milliseconds: 200));
        _downloadProgress[songId] = progress / 100.0;
        update();
      }

      // Save downloaded song
      final downloadedSong = song.copyWith(isDownloaded: true);
      await _offlineStorage.saveDownloadedSong(downloadedSong);

      if (!_downloadedSongs.any((s) => s.id == song.id)) {
        _downloadedSongs.add(downloadedSong);
      }

      Get.snackbar(
        'Download Complete',
        '${song.title} is ready offline',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Download error: $e');
      Get.snackbar(
        'Download Failed',
        'Could not download ${song.title}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _downloadingIds.remove(songId);
      _currentDownloadingTitle.value = '';
      _downloadProgress.remove(songId);
      update();
    }
  }

  // ────────────────────────────────────────────────
  // The rest of your methods remain unchanged
  // ────────────────────────────────────────────────

  Future<void> downloadSongByTitle(String title) async {
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
    await downloadSong(basicSong);
  }

  Future<void> removeSong(String titleOrId) async {
    await _offlineStorage.removeDownloadedSong(titleOrId);
    _downloadedSongs.removeWhere(
      (s) => s.id == titleOrId || s.title == titleOrId,
    );
    _downloadProgress.remove(titleOrId);
    update();

    Get.snackbar(
      'Removed',
      'Song removed from downloads',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> cancelDownload(String songId) async {
    _downloadingIds.remove(songId);
    _downloadProgress.remove(songId);
    _currentDownloadingTitle.value = '';
    update();

    Get.snackbar(
      'Download Cancelled',
      'Download has been cancelled',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> clearAllDownloads() async {
    for (final song in _downloadedSongs) {
      await _offlineStorage.removeDownloadedSong(song.id.toString());
    }
    _downloadedSongs.clear();
    _downloadProgress.clear();
    update();

    Get.snackbar(
      'Cleared',
      'All downloads have been removed',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  bool isSongDownloaded(dynamic songId) {
    return _downloadedSongs.any(
      (s) => s.id == songId || s.id.toString() == songId.toString(),
    );
  }

  bool isTitleDownloaded(String title) {
    return _downloadedSongs.any((s) => s.title == title);
  }

  Song? getDownloadedSong(int songId) {
    try {
      return _downloadedSongs.firstWhere((s) => s.id == songId);
    } catch (_) {
      return null;
    }
  }

  Future<void> downloadSongModel(Song song) async {
    await downloadSong(song);
  }

  @override
  void refresh() {
    _loadDownloadedSongs();
    // Do NOT call update() here unless really needed
  }
}
