/// Auth Controller
/// Handles authentication state with offline support.
/// - Stores user credentials locally for offline access
/// - Auto-navigates to home if already logged in (even offline)
/// - Uses API for login when online
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_app/models/user_model.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/offline_storage_service.dart';

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final ApiService _apiService = ApiService();

  // Observable state
  final RxBool _isFirstTime = true.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  final Rxn<User> _currentUser = Rxn<User>();
  final RxString _errorMessage = ''.obs;

  // Getters
  bool get isFirstTime => _isFirstTime.value;

  bool get isLoggedIn => _isLoggedIn.value;

  bool get isLoading => _isLoading.value;

  User? get currentUser => _currentUser.value;

  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
  }

  /// Load saved state from storage
  Future<void> _loadInitialState() async {
    await Future.delayed(const Duration(milliseconds: 100));

    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;

    // Load saved user
    _currentUser.value = _offlineStorage.getUser();

    debugPrint('📱 Auth State Loaded:');
    debugPrint('   - First Time: ${_isFirstTime.value}');
    debugPrint('   - Logged In: ${_isLoggedIn.value}');
    debugPrint('   - User: ${_currentUser.value?.email ?? 'None'}');
  }

  /// Set first time done (after onboarding/payment)
  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // Check connectivity
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        // Offline login - check stored credentials
        final savedUser = _offlineStorage.getUser();
        if (savedUser != null && savedUser.email == email) {
          _currentUser.value = savedUser;
          _isLoggedIn.value = true;
          _storage.write('isLoggedIn', true);
          debugPrint('✅ Offline login successful');
          return true;
        } else {
          _errorMessage.value =
              'No internet connection. Please connect to login.';
          return false;
        }
      }

      // Dummy credentials for testing
      if (email == 'test@example.com' && password == 'test@123') {
        final dummyUser = User(
          id: '1',
          email: email,
          firstName: 'Test',
          lastName: 'User',
          profileImage: null,
          phone: '+1234567890',
          isPremium: true,
        );
        _currentUser.value = dummyUser;
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);
        await _offlineStorage.saveUser(dummyUser);
        debugPrint('✅ Test login successful with dummy credentials');
        return true;
      }

      // Online login via API
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _currentUser.value = response.data;
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);

        await _offlineStorage.saveUser(response.data!);

        debugPrint('✅ Online login successful');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Login failed';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register new user with ID only - stores ID and returns success
  /// User then navigates to sign in screen to login with same credentials
  Future<bool> registerWithId({required String id}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // Store the signup ID locally
      _storage.write('signupId', id);
      _storage.write('hasSignedUp', true);

      debugPrint('✅ ID stored for signup: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        _errorMessage.value = 'Internet connection required for registration.';
        return false;
      }

      final response = await _apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _currentUser.value = response.data;
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);

        // Save user for offline access
        await _offlineStorage.saveUser(response.data!);

        debugPrint('✅ Registration successful');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get stored signup ID
  String? getSignupId() {
    return _storage.read('signupId');
  }

  /// Check if user has signed up with ID
  bool hasSignedUp() {
    return _storage.read('hasSignedUp') ?? false;
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        _errorMessage.value = 'Internet connection required.';
        return false;
      }

      final response = await _apiService.forgotPassword(email);

      if (response.success) {
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to send reset email';
        return false;
      }
    } catch (e) {
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading.value = true;

    try {
      await _apiService.logout();
    } catch (_) {
      // Ignore API errors on logout
    }

    // Clear local state
    _currentUser.value = null;
    _isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
    await _offlineStorage.clearUser();

    _isLoading.value = false;
    debugPrint('✅ Logged out');
  }

  /// Quick login for demo/testing (skip API)
  void loginOffline() {
    _isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
    debugPrint('✅ Quick offline login');
  }

  /// Update user profile locally
  void updateLocalUser(User user) {
    _currentUser.value = user;
    _offlineStorage.saveUser(user);
  }
}
