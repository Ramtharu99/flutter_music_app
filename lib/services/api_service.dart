import 'package:flutter/foundation.dart';
import 'package:music_app/core/api/api_client.dart';
import 'package:music_app/core/api/api_config.dart';
import 'package:music_app/core/api/api_response.dart';
import 'package:music_app/models/artist_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final ApiClient _client = ApiClient();

  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConfig.login,
        body: {'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        // Store tokens
        if (response.data!['token'] != null) {
          _client.authToken = response.data!['token'];
        }
        if (response.data!['refresh_token'] != null) {
          _client.refreshToken = response.data!['refresh_token'];
        }

        // Parse user
        final userData = response.data!['user'] ?? response.data;
        final user = User.fromJson(userData);

        return ApiResponse.success(user, message: response.message);
      }

      return ApiResponse.error(response.message ?? 'Login failed');
    } catch (e) {
      debugPrint('Login error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Register a new user
  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConfig.register,
        body: {'name': name, 'email': email, 'password': password},
      );

      if (response.success && response.data != null) {
        // Store tokens
        if (response.data!['token'] != null) {
          _client.authToken = response.data!['token'];
        }

        final userData = response.data!['user'] ?? response.data;
        final user = User.fromJson(userData);

        return ApiResponse.success(user, message: response.message);
      }

      return ApiResponse.error(response.message ?? 'Registration failed');
    } catch (e) {
      debugPrint('Register error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Logout user
  Future<ApiResponse<bool>> logout() async {
    try {
      await _client.post(ApiConfig.logout);
      _client.clearTokens();
      return ApiResponse.success(true, message: 'Logged out successfully');
    } catch (e) {
      _client.clearTokens();
      return ApiResponse.success(true);
    }
  }

  /// Forgot password
  Future<ApiResponse<bool>> forgotPassword(String email) async {
    try {
      final response = await _client.post(
        ApiConfig.forgotPassword,
        body: {'email': email},
      );
      return ApiResponse.success(true, message: response.message);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _client.isAuthenticated;

  // ═══════════════════════════════════════════════════════════════════
  // ║                        SONGS                                    ║
  // ═══════════════════════════════════════════════════════════════════

  /// Get all songs
  Future<ApiResponse<List<Song>>> getSongs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get<dynamic>(
        ApiConfig.songs,
        queryParams: {'page': page, 'limit': limit},
      );

      if (response.success && response.data != null) {
        final List<dynamic> songsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final songs = songsData.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(response.message ?? 'Failed to load songs');
    } catch (e) {
      debugPrint('Get songs error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Get featured songs
  Future<ApiResponse<List<Song>>> getFeaturedSongs() async {
    try {
      final response = await _client.get<dynamic>(ApiConfig.featuredSongs);

      if (response.success && response.data != null) {
        final List<dynamic> songsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final songs = songsData.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(
        response.message ?? 'Failed to load featured songs',
      );
    } catch (e) {
      debugPrint('Get featured songs error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Get trending songs
  Future<ApiResponse<List<Song>>> getTrendingSongs() async {
    try {
      final response = await _client.get<dynamic>(ApiConfig.trendingSongs);

      if (response.success && response.data != null) {
        final List<dynamic> songsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final songs = songsData.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(
        response.message ?? 'Failed to load trending songs',
      );
    } catch (e) {
      debugPrint('Get trending songs error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Search songs
  Future<ApiResponse<List<Song>>> searchSongs(String query) async {
    try {
      final response = await _client.get<dynamic>(
        ApiConfig.searchSongs,
        queryParams: {'q': query},
      );

      if (response.success && response.data != null) {
        final List<dynamic> songsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final songs = songsData.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(response.message ?? 'Search failed');
    } catch (e) {
      debugPrint('Search songs error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Get song by ID
  Future<ApiResponse<Song>> getSongById(String id) async {
    try {
      final response = await _client.get<dynamic>('${ApiConfig.songById}/$id');

      if (response.success && response.data != null) {
        final songData = response.data is Map
            ? response.data
            : response.data['data'];

        final song = Song.fromJson(songData);
        return ApiResponse.success(song);
      }

      return ApiResponse.error(response.message ?? 'Song not found');
    } catch (e) {
      debugPrint('Get song by ID error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                       PLAYLISTS                                 ║
  // ═══════════════════════════════════════════════════════════════════

  /// Get user playlists
  Future<ApiResponse<List<Playlist>>> getPlaylists() async {
    try {
      final response = await _client.get<dynamic>(ApiConfig.playlists);

      if (response.success && response.data != null) {
        final List<dynamic> playlistsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final playlists = playlistsData
            .map((json) => Playlist.fromJson(json))
            .toList();
        return ApiResponse.success(playlists);
      }

      return ApiResponse.error(response.message ?? 'Failed to load playlists');
    } catch (e) {
      debugPrint('Get playlists error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Create a new playlist
  Future<ApiResponse<Playlist>> createPlaylist(
    String name, {
    String? description,
  }) async {
    try {
      final response = await _client.post<dynamic>(
        ApiConfig.createPlaylist,
        body: {'name': name, 'description': description},
      );

      if (response.success && response.data != null) {
        final playlistData = response.data is Map
            ? response.data
            : response.data['data'];

        final playlist = Playlist.fromJson(playlistData);
        return ApiResponse.success(playlist, message: 'Playlist created');
      }

      return ApiResponse.error(response.message ?? 'Failed to create playlist');
    } catch (e) {
      debugPrint('Create playlist error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Add song to playlist
  Future<ApiResponse<bool>> addToPlaylist(
    String playlistId,
    String songId,
  ) async {
    try {
      final response = await _client.post<dynamic>(
        ApiConfig.addToPlaylist,
        body: {'playlist_id': playlistId, 'song_id': songId},
      );

      return ApiResponse.success(
        true,
        message: response.message ?? 'Song added to playlist',
      );
    } catch (e) {
      debugPrint('Add to playlist error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                        ARTISTS                                  ║
  // ═══════════════════════════════════════════════════════════════════

  /// Get all artists
  Future<ApiResponse<List<Artist>>> getArtists() async {
    try {
      final response = await _client.get<dynamic>(ApiConfig.artists);

      if (response.success && response.data != null) {
        final List<dynamic> artistsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final artists = artistsData
            .map((json) => Artist.fromJson(json))
            .toList();
        return ApiResponse.success(artists);
      }

      return ApiResponse.error(response.message ?? 'Failed to load artists');
    } catch (e) {
      debugPrint('Get artists error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Get songs by artist
  Future<ApiResponse<List<Song>>> getArtistSongs(String artistId) async {
    try {
      final response = await _client.get<dynamic>(
        '${ApiConfig.artistSongs}/$artistId/songs',
      );

      if (response.success && response.data != null) {
        final List<dynamic> songsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final songs = songsData.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(
        response.message ?? 'Failed to load artist songs',
      );
    } catch (e) {
      debugPrint('Get artist songs error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                         USER                                    ║
  // ═══════════════════════════════════════════════════════════════════

  /// Get current user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _client.get<dynamic>(ApiConfig.profile);

      if (response.success && response.data != null) {
        final userData = response.data is Map
            ? response.data
            : response.data['data'];

        final user = User.fromJson(userData);
        return ApiResponse.success(user);
      }

      return ApiResponse.error(response.message ?? 'Failed to load profile');
    } catch (e) {
      debugPrint('Get profile error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final response = await _client.put<dynamic>(
        ApiConfig.updateProfile,
        body: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.success && response.data != null) {
        final userData = response.data is Map
            ? response.data
            : response.data['data'];

        final user = User.fromJson(userData);
        return ApiResponse.success(user, message: 'Profile updated');
      }

      return ApiResponse.error(response.message ?? 'Failed to update profile');
    } catch (e) {
      debugPrint('Update profile error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                       CATEGORIES                                ║
  // ═══════════════════════════════════════════════════════════════════

  /// Get music categories
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories() async {
    try {
      final response = await _client.get<dynamic>(ApiConfig.categories);

      if (response.success && response.data != null) {
        final List<dynamic> categoriesData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final categories = categoriesData
            .map((json) => Map<String, dynamic>.from(json))
            .toList();
        return ApiResponse.success(categories);
      }

      return ApiResponse.error(response.message ?? 'Failed to load categories');
    } catch (e) {
      debugPrint('Get categories error: $e');
      return ApiResponse.error(e.toString());
    }
  }
}
