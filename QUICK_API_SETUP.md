// 🎯 QUICK START: Where to Add Your API
// This file shows EXACTLY where and how to integrate your music API

// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/services/music_service.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;  // Add this import
import 'dart:convert';                     // Add this import
import '../models/song_model.dart';

class MusicService {
  // ✅ STEP 1: Add your API configuration here
  static const String baseUrl = 'https://your-api.com/api';
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const int timeout = 10; // seconds

  // ═════════════════════════════════════════════════════════════════════════
  // 🔴 THIS IS THE FUNCTION YOU NEED TO MODIFY 🔴
  // ═════════════════════════════════════════════════════════════════════════
  
  /// ⭐ Fetch songs from API
  /// This is called automatically by MusicController
  /// All UI updates happen automatically when this returns data
  Future<List<Song>> fetchSongs({
    int page = 1,
    int limit = 50,
    String? searchQuery,
  }) async {
    try {
      // ✅ STEP 2: Replace this with your actual API call
      
      // OPTION A: Simple REST API
      final uri = Uri.parse('$baseUrl/songs')
          .replace(queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (searchQuery != null) 'search': searchQuery,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: timeout));

      // ✅ STEP 3: Handle the API response

      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonData = jsonDecode(response.body);
        
        // Example JSON structure: 
        // {"data": [{"id": "1", "title": "Song", ...}]}
        // Adjust the key if your API uses different field names
        final List<dynamic> songsList = jsonData['data'] ?? 
                                       jsonData['songs'] ?? 
                                       jsonData;

        // Convert to Song objects
        final songs = songsList
            .map((song) => Song.fromJson(song as Map<String, dynamic>))
            .toList();

        print('✅ Fetched ${songs.length} songs from API');
        return songs;

      } else if (response.statusCode == 401) {
        print('❌ Authentication failed: ${response.statusCode}');
        // Handle token refresh here if needed
        return _getDummySongs();
        
      } else {
        print('❌ API error: ${response.statusCode} - ${response.body}');
        return _getDummySongs();
      }

    } on TimeoutException {
      print('⏱️ API request timed out');
      return _getDummySongs(); // Fallback to dummy data
      
    } catch (e) {
      print('❌ Error fetching songs: $e');
      return _getDummySongs(); // Fallback to dummy data
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Additional API methods (follow same pattern)
  // ═════════════════════════════════════════════════════════════════════════

  /// Search songs by title/artist
  Future<List<Song>> searchSongs(String query) async {
    return fetchSongs(searchQuery: query);
  }

  /// Get songs by genre
  Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songs/genre/$genre'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData['songs'] as List)
            .map((s) => Song.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      return _getDummySongs();
    } catch (e) {
      print('Error: $e');
      return _getDummySongs();
    }
  }

  /// Get trending songs
  Future<List<Song>> getTrendingSongs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songs/trending'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData['songs'] as List)
            .map((s) => Song.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      return _getDummySongs();
    } catch (e) {
      print('Error: $e');
      return _getDummySongs();
    }
  }

  /// Add song to user's favorites
  Future<bool> addToFavorites(String songId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'songId': songId}),
      ).timeout(const Duration(seconds: timeout));

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Remove song from favorites
  Future<bool> removeFromFavorites(String songId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$songId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: timeout));

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get user's favorite songs
  Future<List<Song>> getFavoriteSongs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: timeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData['songs'] as List)
            .map((s) => Song.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Dummy data for offline fallback
  // ═════════════════════════════════════════════════════════════════════════
  
  List<Song> _getDummySongs() {
    return [
      Song(
        id: '1',
        title: 'Summer Vibes',
        artist: 'The Band',
        album: 'Greatest Hits',
        duration: const Duration(minutes: 3, seconds: 45),
        imageUrl: 'https://via.placeholder.com/300',
        isFavorite: false,
      ),
      Song(
        id: '2',
        title: 'Midnight Echo',
        artist: 'Luna Artist',
        album: 'Night Sounds',
        duration: const Duration(minutes: 4, seconds: 12),
        imageUrl: 'https://via.placeholder.com/300',
        isFavorite: false,
      ),
      Song(
        id: '3',
        title: 'Electric Dreams',
        artist: 'Synth Wave',
        album: 'Digital Age',
        duration: const Duration(minutes: 3, seconds: 30),
        imageUrl: 'https://via.placeholder.com/300',
        isFavorite: false,
      ),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOW TO USE THIS FILE
// ═══════════════════════════════════════════════════════════════════════════

/*

STEP 1: Update pubspec.yaml
─────────────────────────────
Add the http package if not already there:

dependencies:
  http: ^1.1.0

Then run: flutter pub get


STEP 2: Update Configuration
──────────────────────────────
Replace these values with YOUR API details:

static const String baseUrl = 'https://your-api.com/api';
                              ^^^^^^^^^^^^^^^^^^^^^^^^
                              Replace with your API URL

static const String apiKey = 'YOUR_API_KEY_HERE';
                              ^^^^^^^^^^^^^^^^
                              Replace with your API key


STEP 3: Update JSON Parsing
────────────────────────────
If your API returns different field names, update the parsing:

// If API returns: {"results": [...]}
final List<dynamic> songsList = jsonData['results'] ?? [];

// If API returns: {"content": {..., "songs": [...]}}
final List<dynamic> songsList = jsonData['content']['songs'] ?? [];


STEP 4: Update Song Model Mapping
──────────────────────────────────
If your API response has different field names, update Song.fromJson():

In lib/models/song_model.dart:

factory Song.fromJson(Map<String, dynamic> json) => Song(
  id: json['songId'],          // ← Change 'id' to match your API
  title: json['songName'],     // ← Change 'title' to match your API
  artist: json['artistName'],  // ← And so on...
  album: json['albumTitle'],
  duration: Duration(seconds: json['durationInSeconds'] ?? 0),
  imageUrl: json['coverImage'],
  isFavorite: json['isFav'] ?? false,
);


STEP 5: Test It
───────────────
Run your app:

flutter run

The songs will now load from YOUR API instead of dummy data!
All the UI updates automatically - no code changes needed!


TROUBLESHOOTING
───────────────

Issue: "The method 'http' isn't defined"
→ Run: flutter pub add http

Issue: "JSON parsing error"
→ Print the response: print('API Response: ${response.body}');
→ Check if field names match your API

Issue: "401 Unauthorized"
→ Check your API key
→ Check if token needs refresh

Issue: "No songs showing"
→ Add print statements to debug
→ Verify API endpoint is correct
→ Check network connectivity


THAT'S IT! 🎉

When you update this file with your real API, all UI automatically updates.
No other code changes needed!

*/
