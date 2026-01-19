library;

class ApiConfig {
  static const String baseUrl = 'https://music-api-qhag.onrender.com/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String refreshToken = '/refresh';

  // User
  static const String profile = '/me';
  static const String updateProfile = '/update-profile';
  static const String uploadProfileImage = '/upload-profile';

  // Songs
  static const String songs = '/songs';
  static const String searchSongs = '/songs/search';
  static const String songById = '/songs';
  static const String featuredSongs = '/songs/featured';
  static const String trendingSongs = '/songs/trending';

  // Playlists
  static const String playlists = '/playlists';
  static const String createPlaylist = '/playlists/create';
  static const String addToPlaylist = '/playlists/add';

  // Artists
  static const String artists = '/artists';
  static const String artistSongs = '/artists';

  // Categories
  static const String categories = '/categories';

  static const bool enableLogging = true;
  static const bool enableRetry = true;
  static const int maxRetryAttempts = 3;
}
