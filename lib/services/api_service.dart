import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/api/api_client.dart';
import 'package:music_app/core/api/api_config.dart';
import 'package:music_app/core/api/api_response.dart';
import 'package:music_app/models/artist_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/models/purchase_model.dart';
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
        debugPrint('✅ [API SERVICE] Login response received');
        debugPrint('   - response.data type: ${response.data.runtimeType}');
        debugPrint('   - response.data: ${response.data}');

        // The server response has structure: {success, message, data: {user, token}}
        // response.data is the entire response body
        var tokenData = response.data;
        String? token;
        String? refreshToken;
        Map<String, dynamic>? userData;

        // Handle both possible response structures
        if (tokenData is Map<String, dynamic>) {
          if (tokenData.containsKey('data') && tokenData['data'] is Map) {
            // Structure: {success, message, data: {user, token}}
            token = tokenData['data']['token'];
            refreshToken = tokenData['data']['refresh_token'];
            userData = tokenData['data']['user'];
          } else if (tokenData.containsKey('token')) {
            // Direct structure
            token = tokenData['token'];
            refreshToken = tokenData['refresh_token'];
            userData = tokenData['user'];
          }
        }

        if (token != null) {
          debugPrint(
            '   - Token found: ${token.substring(0, min(20, token.length))}...',
          );
          _client.authToken = token;
          debugPrint('   - ✅ Token assignment completed');
        } else {
          debugPrint('   - ❌ NO TOKEN FOUND in response!');
        }

        if (refreshToken != null) {
          _client.refreshToken = refreshToken;
        }

        // Parse user
        if (userData != null) {
          final user = User.fromJson(userData);
          return ApiResponse.success(user, message: response.message);
        } else {
          return ApiResponse.error('No user data in response');
        }
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
    required String phone,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConfig.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
        },
      );

      if (response.success && response.data != null) {
        debugPrint('✅ [API SERVICE] Register response received');

        // The server response has structure: {success, message, data: {user, token}}
        var tokenData = response.data;
        String? token;
        String? refreshToken;
        Map<String, dynamic>? userData;

        // Handle both possible response structures
        if (tokenData is Map<String, dynamic>) {
          if (tokenData.containsKey('data') && tokenData['data'] is Map) {
            // Structure: {success, message, data: {user, token}}
            token = tokenData['data']['token'];
            refreshToken = tokenData['data']['refresh_token'];
            userData = tokenData['data']['user'];
          } else if (tokenData.containsKey('token')) {
            // Direct structure
            token = tokenData['token'];
            refreshToken = tokenData['refresh_token'];
            userData = tokenData['user'];
          }
        }

        if (token != null) {
          debugPrint(
            '   - Token found: ${token.substring(0, min(20, token.length))}...',
          );
          _client.authToken = token;
        }

        if (refreshToken != null) {
          _client.refreshToken = refreshToken;
        }

        if (userData != null) {
          final user = User.fromJson(userData);
          return ApiResponse.success(user, message: response.message);
        } else {
          return ApiResponse.error('No user data in response');
        }
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
        ApiConfig.music,
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

  /// Get featured songs (not available on this server)
  Future<ApiResponse<List<Song>>> getFeaturedSongs() async {
    // This endpoint is not available on the current API server
    // Return empty list instead
    debugPrint('⚠️ Featured songs endpoint not available on server');
    return ApiResponse.success(
      [],
      message: 'Featured songs not available on this server',
    );
  }

  /// Get trending songs (not available on this server)
  Future<ApiResponse<List<Song>>> getTrendingSongs() async {
    // This endpoint is not available on the current API server
    // Return empty list instead
    debugPrint('⚠️ Trending songs endpoint not available on server');
    return ApiResponse.success(
      [],
      message: 'Trending songs not available on this server',
    );
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
    debugPrint('🚀 getProfile() called');

    // Check token before API call
    final token = _client.authToken;
    debugPrint('🔑 [API SERVICE] Token check:');
    if (token != null) {
      debugPrint('   ✅ Token available (${token.length} chars)');
    } else {
      debugPrint('   ❌ NO TOKEN - API will return 401 Unauthorized!');
    }

    try {
      debugPrint('🔍 Fetching user profile from /me endpoint...');
      final response = await _client.get<dynamic>(ApiConfig.profile);

      debugPrint('📥 API Response: ${response.data}');

      if (response.success && response.data != null) {
        final userData = response.data is Map
            ? response.data
            : response.data['data'];

        debugPrint('👤 Parsing user data: $userData');

        final user = User.fromJson(userData);
        debugPrint('✓ User object created: ${user.email}');

        return ApiResponse.success(user);
      }

      debugPrint('✗ Profile fetch failed: ${response.message}');
      return ApiResponse.error(response.message ?? 'Failed to load profile');
    } catch (e) {
      debugPrint('✗ Get profile error: $e');
      return ApiResponse.error('Error fetching profile: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<ApiResponse<User>> getUserById(String userId) async {
    try {
      final response = await _client.get<dynamic>(
        '${ApiConfig.profile}/$userId',
      );

      if (response.success && response.data != null) {
        final userData = response.data is Map
            ? response.data
            : response.data['data'];

        final user = User.fromJson(userData);
        return ApiResponse.success(user);
      }

      return ApiResponse.error(response.message ?? 'Failed to load user');
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await _client.post<dynamic>(
        ApiConfig.updateProfile,
        body: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
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

  /// Upload profile image
  Future<ApiResponse<User>> uploadProfileImage(String imagePath) async {
    try {
      final response = await _client.uploadFile<dynamic>(
        ApiConfig.uploadProfileImage,
        imagePath,
        fileFieldName: 'profile_image',
      );

      if (response.success && response.data != null) {
        final userData = response.data is Map
            ? response.data
            : response.data['data'];

        final user = User.fromJson(userData);
        return ApiResponse.success(user, message: 'Profile image updated');
      }

      return ApiResponse.error(response.message ?? 'Failed to upload image');
    } catch (e) {
      debugPrint('Upload profile image error: $e');
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

  // ═══════════════════════════════════════════════════════════════════
  // ║                  USER PROFILE MANAGEMENT                        ║
  // ═══════════════════════════════════════════════════════════════════

  /// Change user password
  Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConfig.changePassword,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      if (response.success) {
        return ApiResponse.success(
          true,
          message: response.message ?? 'Password changed successfully',
        );
      }

      return ApiResponse.error(response.message ?? 'Failed to change password');
    } catch (e) {
      debugPrint('Change password error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Delete user account
  Future<ApiResponse<bool>> deleteAccount() async {
    try {
      final response = await _client.delete<Map<String, dynamic>>(
        ApiConfig.deleteAccount,
      );

      if (response.success) {
        _client.clearTokens();
        return ApiResponse.success(
          true,
          message: response.message ?? 'Account deleted successfully',
        );
      }

      return ApiResponse.error(response.message ?? 'Failed to delete account');
    } catch (e) {
      debugPrint('Delete account error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                        MUSIC ENDPOINTS                          ║
  // ═══════════════════════════════════════════════════════════════════

  /// Get all music with filters and pagination
  Future<ApiResponse<List<Song>>> getMusic({
    String? search,
    String? genre,
    String? artist,
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'per_page': perPage, 'page': page};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }
      if (artist != null && artist.isNotEmpty) {
        queryParams['artist'] = artist;
      }

      final response = await _client.get<dynamic>(
        ApiConfig.music,
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final List<dynamic> songsData = response.data is List
            ? response.data
            : response.data['data'] ?? [];

        final songs = songsData.map((json) => Song.fromJson(json)).toList();
        return ApiResponse.success(songs);
      }

      return ApiResponse.error(response.message ?? 'Failed to load music');
    } catch (e) {
      debugPrint('Get music error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Get single music track by ID
  Future<ApiResponse<Song>> getMusicById(int musicId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '${ApiConfig.musicById}/$musicId',
      );

      if (response.success && response.data != null) {
        final songData = response.data is Map
            ? response.data
            : response.data?['data'];

        final song = Song.fromJson(songData as Map<String, dynamic>);
        return ApiResponse.success(song);
      }

      return ApiResponse.error(response.message ?? 'Failed to load music');
    } catch (e) {
      debugPrint('Get music by ID error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Increment play count for a music track
  Future<ApiResponse<bool>> incrementPlayCount(int musicId) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '${ApiConfig.musicPlay}/$musicId/play',
      );

      if (response.success) {
        return ApiResponse.success(
          true,
          message: response.message ?? 'Play count incremented',
        );
      }

      return ApiResponse.error(
        response.message ?? 'Failed to increment play count',
      );
    } catch (e) {
      debugPrint('Increment play count error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                     PURCHASE MANAGEMENT                         ║
  // ═══════════════════════════════════════════════════════════════════

  /// Purchase a music track
  Future<ApiResponse<Purchase>> purchaseMusic(int musicId) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiConfig.purchase,
        body: {'music_id': musicId},
      );

      if (response.success && response.data != null) {
        final purchaseData = response.data is Map
            ? response.data
            : response.data?['data'];

        final purchase = Purchase.fromJson(
          purchaseData as Map<String, dynamic>,
        );
        return ApiResponse.success(
          purchase,
          message: response.message ?? 'Music purchased successfully',
        );
      }

      return ApiResponse.error(response.message ?? 'Failed to purchase music');
    } catch (e) {
      debugPrint('Purchase music error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Get user's purchased music
  Future<ApiResponse<List<Purchase>>> getMyPurchases({int page = 1}) async {
    try {
      final response = await _client.get<dynamic>(
        ApiConfig.myPurchases,
        queryParams: {'page': page},
      );

      if (response.success && response.data != null) {
        final List<dynamic> purchasesData = response.data is List
            ? response.data
            : response.data?['data'] ?? [];

        final purchases = purchasesData
            .map((json) => Purchase.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(purchases);
      }

      return ApiResponse.error(response.message ?? 'Failed to load purchases');
    } catch (e) {
      debugPrint('Get my purchases error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Check if user has purchased a specific music
  Future<ApiResponse<bool>> checkPurchaseStatus(int musicId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '${ApiConfig.checkPurchase}/$musicId',
      );

      if (response.success && response.data != null) {
        final isPurchased = response.data?['is_purchased'] ?? false;
        return ApiResponse.success(isPurchased as bool);
      }

      return ApiResponse.error(
        response.message ?? 'Failed to check purchase status',
      );
    } catch (e) {
      debugPrint('Check purchase status error: $e');
      return ApiResponse.error(e.toString());
    }
  }
}
