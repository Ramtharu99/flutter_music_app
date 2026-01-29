import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/models/user_model.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();

  factory OfflineStorageService() => _instance;

  OfflineStorageService._internal();

  final GetStorage _storage = GetStorage();

  // ============ STORAGE KEYS ============
  static const String _userKey = 'offline_user';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _downloadedSongsKey = 'downloaded_songs';
  static const String _cachedSongsKey = 'cached_songs';
  static const String _recentSearchesKey = 'recent_searches';

  // ═══════════════════════════════════════════════════════════════════
  // ║                    USER/AUTH STORAGE                            ║
  // ═══════════════════════════════════════════════════════════════════

  /// Save user for offline access
  Future<void> saveUser(User user) async {
    try {
      await _storage.write(_userKey, jsonEncode(user.toJson()));
      await _storage.write(_isLoggedInKey, true);
      debugPrint('✅ User saved to offline storage');
    } catch (e) {
      debugPrint('❌ Error saving user: $e');
    }
  }

  /// Get saved user
  User? getUser() {
    try {
      final userData = _storage.read(_userKey);
      if (userData != null) {
        final json = jsonDecode(userData);
        return User.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error reading user: $e');
    }
    return null;
  }

  /// Check if user is logged in
  bool get isLoggedIn => _storage.read(_isLoggedInKey) ?? false;

  /// Check if this is first time opening app
  bool get isFirstTime => _storage.read(_isFirstTimeKey) ?? true;

  /// Set first time done
  Future<void> setFirstTimeDone() async {
    await _storage.write(_isFirstTimeKey, false);
  }

  /// Clear user data (logout)
  Future<void> clearUser() async {
    await _storage.remove(_userKey);
    await _storage.remove(_tokenKey);
    await _storage.write(_isLoggedInKey, false);
    debugPrint('✅ User data cleared');
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                   DOWNLOADED SONGS                              ║
  // ═══════════════════════════════════════════════════════════════════

  /// Save downloaded song
  Future<void> saveDownloadedSong(Song song) async {
    try {
      final songs = getDownloadedSongs();

      // Check if song already exists
      final existingIndex = songs.indexWhere((s) => s.id == song.id);
      if (existingIndex != -1) {
        songs[existingIndex] = song;
      } else {
        songs.add(song);
      }

      final songsJson = songs.map((s) => s.toJson()).toList();
      await _storage.write(_downloadedSongsKey, jsonEncode(songsJson));
      debugPrint('✅ Song downloaded: ${song.title}');
    } catch (e) {
      debugPrint('❌ Error saving downloaded song: $e');
    }
  }

  /// Get all downloaded songs
  List<Song> getDownloadedSongs() {
    try {
      final songsData = _storage.read(_downloadedSongsKey);
      if (songsData != null) {
        final List<dynamic> songsList = jsonDecode(songsData);
        return songsList.map((json) => Song.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error reading downloaded songs: $e');
    }
    return [];
  }

  /// Remove downloaded song
  Future<void> removeDownloadedSong(String songId) async {
    try {
      final songs = getDownloadedSongs();

      final song = songs.firstWhere(
        (s) => s.id.toString() == songId,
        orElse: () => null as Song,
      );

      // 🔥 DELETE AUDIO FILE
      if (song != null &&
          song.localPath != null &&
          song.localPath!.isNotEmpty) {
        final file = File(song.localPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑 File deleted: ${song.localPath}');
        }
      }

      songs.removeWhere((s) => s.id.toString() == songId);

      final songsJson = songs.map((s) => s.toJson()).toList();
      await _storage.write(_downloadedSongsKey, jsonEncode(songsJson));

      debugPrint('✅ Song removed from downloads');
    } catch (e) {
      debugPrint('❌ Error removing downloaded song: $e');
    }
  }

  /// Check if song is downloaded
  bool isSongDownloaded(String songId) {
    final songs = getDownloadedSongs();
    return songs.any((s) => s.id == songId);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                    CACHED SONGS                                 ║
  // ═══════════════════════════════════════════════════════════════════

  /// Cache songs for offline viewing (not full download)
  Future<void> cacheSongs(List<Song> songs) async {
    try {
      final songsJson = songs.map((s) => s.toJson()).toList();
      await _storage.write(_cachedSongsKey, jsonEncode(songsJson));
      debugPrint('✅ ${songs.length} songs cached');
    } catch (e) {
      debugPrint('❌ Error caching songs: $e');
    }
  }

  /// Get cached songs
  List<Song> getCachedSongs() {
    try {
      final songsData = _storage.read(_cachedSongsKey);
      if (songsData != null) {
        final List<dynamic> songsList = jsonDecode(songsData);
        return songsList.map((json) => Song.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error reading cached songs: $e');
    }
    return [];
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                   RECENT SEARCHES                               ║
  // ═══════════════════════════════════════════════════════════════════

  /// Save recent search
  Future<void> addRecentSearch(String query) async {
    try {
      final searches = getRecentSearches();
      searches.remove(query); // Remove if exists
      searches.insert(0, query); // Add to beginning

      // Keep only last 10 searches
      if (searches.length > 10) {
        searches.removeLast();
      }

      await _storage.write(_recentSearchesKey, jsonEncode(searches));
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  /// Get recent searches
  List<String> getRecentSearches() {
    try {
      final searchesData = _storage.read(_recentSearchesKey);
      if (searchesData != null) {
        final List<dynamic> searchesList = jsonDecode(searchesData);
        return searchesList.cast<String>();
      }
    } catch (e) {
      debugPrint('Error reading recent searches: $e');
    }
    return [];
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    await _storage.remove(_recentSearchesKey);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                   UTILITY METHODS                               ║
  // ═══════════════════════════════════════════════════════════════════

  /// Clear all offline data
  Future<void> clearAll() async {
    await _storage.erase();
    debugPrint('✅ All offline data cleared');
  }

  /// Get storage size (approximate)
  int get storageSize {
    int size = 0;
    try {
      final downloads = _storage.read(_downloadedSongsKey);
      final cached = _storage.read(_cachedSongsKey);
      if (downloads != null) size += downloads.toString().length;
      if (cached != null) size += cached.toString().length;
    } catch (_) {}
    return size;
  }
}
