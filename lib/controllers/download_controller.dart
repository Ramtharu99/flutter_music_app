// File: controllers/download_controller.dart
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/offline_storage_service.dart';

import '../main.dart'; // To access flutterLocalNotificationsPlugin

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

  /// Get downloaded songs (legacy method)
  List<String> getDownloadedSongs() {
    return _downloadedSongs.map((s) => s.title).toList();
  }

  /// Download a song with offline storage + notifications
  Future<void> downloadSong(Song song) async {
    _isDownloading.value = true;
    _currentDownloadId.value = song.id.toString();

    try {
      // Simulate download progress
      for (int progress = 0; progress <= 100; progress += 10) {
        await Future.delayed(const Duration(milliseconds: 300));

        // Android: show progress bar, iOS: show text
        if (Platform.isAndroid) {
          await flutterLocalNotificationsPlugin.show(
            0,
            'Downloading ${song.title}',
            '$progress% completed',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'download_channel',
                'Downloads',
                channelDescription: 'Song download progress',
                importance: Importance.high,
                priority: Priority.high,
                showProgress: true,
                maxProgress: 100,
                progress: progress,
                onlyAlertOnce: true,
              ),
            ),
          );
        } else if (Platform.isIOS) {
          await flutterLocalNotificationsPlugin.show(
            0,
            'Downloading ${song.title}',
            '$progress% completed',
            NotificationDetails(iOS: DarwinNotificationDetails()),
          );
        }
      }

      // Save downloaded song
      final downloadedSong = song.copyWith(isDownloaded: true);
      await _offlineStorage.saveDownloadedSong(downloadedSong);
      _downloadedSongs.add(downloadedSong);

      // Completed notification
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Complete',
        '${song.title} is ready offline',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'download_channel',
            'Downloads',
            channelDescription: 'Completed downloads',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } finally {
      _isDownloading.value = false;
      _currentDownloadId.value = '';
      update(); // Ensure UI updates
    }
  }

  /// Download song with just title (legacy support)
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

  /// Remove a downloaded song
  Future<void> removeSong(String titleOrId) async {
    await _offlineStorage.removeDownloadedSong(titleOrId);
    _downloadedSongs.removeWhere(
      (s) => s.id == titleOrId || s.title == titleOrId,
    );
    update();
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    for (final song in _downloadedSongs) {
      await _offlineStorage.removeDownloadedSong(song.id.toString());
    }
    _downloadedSongs.clear();
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

  /// Download song model directly
  Future<void> downloadSongModel(Song song) async {
    await downloadSong(song);
  }

  /// Refresh controller data
  @override
  void refresh() {
    _loadDownloadedSongs();
    update();
  }
}
