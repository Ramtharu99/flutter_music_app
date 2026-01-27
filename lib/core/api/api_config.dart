import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl => dotenv.get('API_BASE_URL');

  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String forgotPassword = '/change-password';

  static const String profile = '/me';
  static const String updateProfile = '/update-profile';
  static const String uploadProfileImage = '/update-profile';
  static const String changePassword = '/change-password';
  static const String deleteAccount = '/delete-account';

  // Music
  static const String music = '/music';
  static const String musicById = '/music';
  static const String musicPlay = '/music';
  static const String searchSongs = '/music';
  static const String songById = '/music';

  // Purchases
  static const String purchase = '/purchase';
  static const String myPurchases = '/my-purchases';
  static const String checkPurchase = '/check-purchase';

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
