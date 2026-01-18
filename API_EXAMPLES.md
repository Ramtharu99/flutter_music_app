/// Example: Integrating Real API with Music App
/// This file shows how to modify music_service.dart for different API types

// ============================================================================
// EXAMPLE 1: RESTful API with HTTP Package
// ============================================================================

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/song_model.dart';

class MusicService {
  static const String baseUrl = 'https://your-api.com/api';
  static const String apiKey = 'YOUR_API_KEY';

  /// Fetch songs from real API (RESTful)
  Future<List<Song>> fetchSongs({
    int page = 1,
    int limit = 50,
    String? searchQuery,
  }) async {
    try {
      // Build URL with query parameters
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (searchQuery != null) 'search': searchQuery,
      };

      final uri = Uri.parse('$baseUrl/songs').replace(queryParameters: params);

      // Make API request
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonData = jsonDecode(response.body);

        // Example: {"data": [{"id": "1", "title": "Song", ...}]}
        final List<dynamic> songsList = jsonData['data'] ?? jsonData['songs'] ?? [];

        // Convert to Song model
        final songs = songsList
            .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
            .toList();

        print('✅ Fetched ${songs.length} songs from API');
        return songs;
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized: Invalid API key');
        return _getDummySongs();
      } else {
        print('❌ API Error: ${response.statusCode}');
        return _getDummySongs();
      }
    } on TimeoutException catch (e) {
      print('⏱️ Request timeout: $e');
      return _getDummySongs();
    } catch (e) {
      print('❌ Error fetching songs: $e');
      return _getDummySongs();
    }
  }

  /// Search songs by title or artist
  Future<List<Song>> searchSongs(String query) async {
    return fetchSongs(searchQuery: query);
  }

  /// Get songs by genre
  Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songs/genre/$genre'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData['songs'] as List)
            .map((s) => Song.fromJson(s))
            .toList();
      }
      return _getDummySongs();
    } catch (e) {
      print('Error fetching by genre: $e');
      return _getDummySongs();
    }
  }

  /// Add song to favorites
  Future<bool> addToFavorites(String songId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'songId': songId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove from favorites
  Future<bool> removeFromFavorites(String songId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$songId'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Keep dummy songs for offline fallback
  List<Song> _getDummySongs() {
    return [
      Song(
        id: '1',
        title: 'Summer Vibes',
        artist: 'The Band',
        album: 'Greatest Hits',
        duration: const Duration(minutes: 3, seconds: 45),
        imageUrl: 'https://via.placeholder.com/300',
      ),
      Song(
        id: '2',
        title: 'Midnight Echo',
        artist: 'Luna Artist',
        album: 'Night Sounds',
        duration: const Duration(minutes: 4, seconds: 12),
        imageUrl: 'https://via.placeholder.com/300',
      ),
    ];
  }
}

// ============================================================================
// EXAMPLE 2: Using Dio Package (More Robust)
// ============================================================================

/*
// Add to pubspec.yaml:
dependencies:
  dio: ^5.0.0

import 'package:dio/dio.dart';

class MusicServiceDio {
  late Dio _dio;

  MusicServiceDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://your-api.com/api',
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add interceptors for logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🔄 Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<Song>> fetchSongs({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/songs',
        queryParameters: {'page': page, 'limit': 50},
      );

      final songs = (response.data['data'] as List)
          .map((s) => Song.fromJson(s))
          .toList();

      return songs;
    } catch (e) {
      print('Error: $e');
      return _getDummySongs();
    }
  }

  List<Song> _getDummySongs() => [...];
}
*/

// ============================================================================
// EXAMPLE 3: Using GetConnect (Built into GetX)
// ============================================================================

/*
// If you're already using GetX, use GetConnect:

import 'package:get/get.dart';

class MusicServiceGetX {
  final GetConnect _getConnect = GetConnect();

  MusicServiceGetX() {
    // Configure default headers
    _getConnect.httpClient.defaultDecoder = (dynamic data) {
      if (data is List<dynamic>) return data.map((e) => Song.fromJson(e)).toList();
      if (data is Map) return Song.fromJson(data);
      return null;
    };
    _getConnect.httpClient.addAuthorizationHeader('Bearer YOUR_API_KEY');
  }

  Future<List<Song>> fetchSongs() async {
    try {
      final response = await _getConnect.get(
        'https://your-api.com/api/songs',
      );

      if (response.isOk) {
        return response.body as List<Song>;
      }
      return _getDummySongs();
    } catch (e) {
      print('Error: $e');
      return _getDummySongs();
    }
  }

  List<Song> _getDummySongs() => [...];
}
*/

// ============================================================================
// EXAMPLE 4: GraphQL API Integration
// ============================================================================

/*
// Add to pubspec.yaml:
dependencies:
  graphql: ^5.0.0

import 'package:graphql/client.dart';

class MusicServiceGraphQL {
  late GraphQLClient _client;

  MusicServiceGraphQL() {
    final HttpLink httpLink = HttpLink(
      'https://your-api.com/graphql',
      defaultHeaders: {
        'Authorization': 'Bearer YOUR_TOKEN',
      },
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer YOUR_TOKEN',
    );

    _client = GraphQLClient(
      link: authLink.concat(httpLink),
      cache: GraphQLCache(),
    );
  }

  Future<List<Song>> fetchSongs() async {
    const String query = r'''
      query GetSongs {
        songs {
          id
          title
          artist
          album
          duration
          imageUrl
        }
      }
    ''';

    try {
      final result = await _client.query(
        QueryOptions(document: gql(query)),
      );

      if (result.hasException) {
        print('GraphQL Error: ${result.exception}');
        return _getDummySongs();
      }

      final songs = (result.data?['songs'] as List)
          .map((s) => Song.fromJson(s))
          .toList();

      return songs;
    } catch (e) {
      print('Error: $e');
      return _getDummySongs();
    }
  }

  List<Song> _getDummySongs() => [...];
}
*/

// ============================================================================
// USAGE IN MusicController
// ============================================================================

/*
// In lib/controllers/music_controller.dart:

class MusicController extends ChangeNotifier {
  late MusicService _musicService;

  List<Song> _songs = [];
  List<Song> get songs => _songs;

  MusicController() {
    _musicService = MusicService();
    loadSongs();
  }

  void loadSongs() async {
    _songs = await _musicService.fetchSongs();
    notifyListeners(); // UI rebuilds automatically
  }

  void searchSongs(String query) async {
    _songs = await _musicService.searchSongs(query);
    notifyListeners();
  }
}
*/
