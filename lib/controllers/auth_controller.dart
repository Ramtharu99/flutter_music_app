import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_app/core/api/api_client.dart';
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

  Future<void> _loadInitialState() async {
    try {
      debugPrint('auth controller initialize.....');
      _isFirstTime.value = _storage.read('isFirstTime') ?? true;
      debugPrint('📱 First Time: ${_isFirstTime.value}');

      // Load logged in flag
      _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
      debugPrint('✓ Logged In Flag: ${_isLoggedIn.value}');

      // Try to load token from storage
      final storedToken = _storage.read('auth_token');
      debugPrint('Token in Storage: ${storedToken != null ? 'YES' : 'NO'}');
      if (storedToken != null) {
        ApiClient().authToken = storedToken;
        debugPrint('✓ Token loaded into ApiClient');
      }

      // Load saved user
      _currentUser.value = _offlineStorage.getUser();
      if (_currentUser.value != null) {
        debugPrint('✓ User loaded from offline storage');
        debugPrint('  - Name: ${_currentUser.value?.fullName}');
        debugPrint('  - Email: ${_currentUser.value?.email}');
      }

      // If logged in, fetch fresh profile from API
      if (_isLoggedIn.value && storedToken != null) {
        debugPrint('\nFetching profile from API...');
        await Future.delayed(const Duration(milliseconds: 500));
        await fetchProfile();
      }

      debugPrint('═══════════════════════════════════════════════════\n');
    } catch (e) {
      debugPrint('❌ Error loading initial state: $e');
    }
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

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
          debugPrint('Offline login successful');
          return true;
        } else {
          _errorMessage.value =
              'No internet connection. Please connect to login.';
          return false;
        }
      }

      if (email == 'test@example.com' && password == 'test@123') {
        // Store test token
        final testToken = 'test_token_12345_dummy_token_for_testing';
        ApiClient().authToken = testToken;
        debugPrint('Test token stored: $testToken');

        final dummyUser = User(
          id: 1,
          email: email,
          name: 'Test',
          profileImage: null,
          phone: '+1234567890',
          isPremium: true,
        );
        _currentUser.value = dummyUser;
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);
        await _offlineStorage.saveUser(dummyUser);
        debugPrint('Test login successful with dummy credentials');
        return true;
      }

      // Online login via API
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);

        // Add a small delay to ensure token is written to storage
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify token was stored - use multiple checks
        final storedToken = ApiClient().authToken;
        debugPrint('✅ [LOGIN SUCCESS] Token verification:');
        debugPrint('   - Token exists: ${storedToken != null}');
        if (storedToken != null) {
          debugPrint('   - Token length: ${storedToken.length}');
          debugPrint('   - isAuthenticated: ${ApiClient().isAuthenticated}');
        }

        await fetchProfile();
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Login failed';
        return false;
      }
    } catch (e) {
      debugPrint('Invalid credential');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> registerWithId({required String id}) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // Store the signup ID locally
      _storage.write('signupId', id);
      _storage.write('hasSignedUp', true);

      debugPrint('ID stored for signup: $id');
      return true;
    } catch (e) {
      debugPrint('Signup error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
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
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      if (response.success && response.data != null) {
        _currentUser.value = response.data;
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);

        // Save user for offline access
        await _offlineStorage.saveUser(response.data!);

        debugPrint('Registration successful');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> switchAccount(User account) async {
    try {
      _currentUser.value = account;
      ApiClient().authToken = account.token ?? '';
    } catch (e) {}
  }

  Future<void> fetchProfile({int retryCount = 0}) async {
    debugPrint(
      '\n🔐 [AUTH CONTROLLER] fetchProfile() called (attempt ${retryCount + 1})',
    );

    // Check token status
    final token = ApiClient().authToken;
    debugPrint('🔑 [TOKEN] Auth token status:');
    if (token != null) {
      debugPrint('   ✅ Token exists (${token.length} chars)');
      final prefix = token.length > 20 ? token.substring(0, 20) : token;
      debugPrint('   ✅ Token prefix: $prefix...');
    } else {
      debugPrint('   ❌ NO TOKEN FOUND');
      debugPrint('   ❌ User is not authenticated!');

      // If this is a retry, don't retry anymore
      if (retryCount >= 2) {
        debugPrint('❌ No token after retries');
        return;
      }

      // Retry after a short delay
      debugPrint('Retrying...');
      await Future.delayed(const Duration(milliseconds: 500));
      return fetchProfile(retryCount: retryCount + 1);
    }

    try {
      final ConnectivityService connectivityService =
          Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        debugPrint('Offline mode: Loading from cache');
        _currentUser.value = _offlineStorage.getUser();
        return;
      }

      debugPrint('[API] Calling getProfile() from API service');
      // Fetch user profile from /me endpoint
      final response = await _apiService.getProfile();

      debugPrint('[API] getProfile() response received');
      debugPrint('   - Success: ${response.success}');
      debugPrint('   - Message: ${response.message}');

      if (response.success && response.data != null) {
        final user = response.data!;
        _currentUser.value = user;
        _isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);

        // Save user locally for offline access
        await _offlineStorage.saveUser(user);

        debugPrint('✅ [SUCCESS] User profile fetched from API:');
        debugPrint('   - ID: ${user.id}');
        debugPrint('   - Name: ${user.fullName}');
        debugPrint('   - Email: ${user.email}');
        debugPrint('   - Phone: ${user.phone}');
        debugPrint('   - Profile Image: ${user.profileImage}');
        debugPrint('   - Premium: ${user.isPremium}');
        debugPrint('   - Created: ${user.createdAt}');
        debugPrint('   - Updated: ${user.createdAt}');
      } else {
        debugPrint('❌ [FAILED] Failed to fetch profile: ${response.message}');

        // If 401, it might be a token issue - retry once
        if (response.message?.contains('401') == true && retryCount < 1) {
          debugPrint('⏳ Got 401 error, retrying after delay...');
          await Future.delayed(const Duration(milliseconds: 500));
          return fetchProfile(retryCount: retryCount + 1);
        }
      }
    } catch (e) {
      debugPrint('❌ [ERROR] Exception in fetchProfile: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
    }
  }

  /// Get stored signup ID
  String? getSignupId() {
    return _storage.read('signupId');
  }

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
    } catch (e) {
      // Ignore API errors on logout
      debugPrint('Error on logout: $e');
    }

    // Clear local state
    _currentUser.value = null;
    _isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
    await _offlineStorage.clearUser();

    _isLoading.value = false;
    debugPrint('Logged out');
  }

  void loginOffline() {
    _isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
    debugPrint('Quick offline login');
  }

  /// Update user profile locally
  void updateLocalUser(User user) {
    _currentUser.value = user;
    _offlineStorage.saveUser(user);
  }

  /// Update current user (alias for updateLocalUser)
  void updateCurrentUser(User user) {
    updateLocalUser(user);
  }

  /// Refresh user profile from server
  Future<bool> refreshUserProfile() async {
    try {
      final ConnectivityService connectivityService =
          Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        debugPrint('⚠ Offline mode: Cannot refresh profile');
        return false;
      }

      await fetchProfile();
      return _currentUser.value != null;
    } catch (e) {
      debugPrint('✗ Failed to refresh profile: $e');
      return false;
    }
  }

  /// Get current logged-in user
  User? getCurrentUser() {
    return _currentUser.value;
  }

  /// Check if current user has required fields
  bool hasCompleteProfile() {
    final user = _currentUser.value;
    if (user == null) return false;
    return user.email.isNotEmpty &&
        user.name != null &&
        user.name!.isNotEmpty &&
        user.phone != null &&
        user.phone!.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════
  // ║                   PROFILE MANAGEMENT                            ║
  // ═══════════════════════════════════════════════════════════════════

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        _errorMessage.value = 'Internet connection required to update profile.';
        return false;
      }

      final response = await _apiService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );

      if (response.success && response.data != null) {
        _currentUser.value = response.data;
        await _offlineStorage.saveUser(response.data!);
        debugPrint('✅ Profile updated successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Upload profile image
  Future<bool> uploadProfileImage(String imagePath) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        _errorMessage.value = 'Internet connection required to upload image.';
        return false;
      }

      final response = await _apiService.uploadProfileImage(imagePath);

      if (response.success && response.data != null) {
        _currentUser.value = response.data;
        await _offlineStorage.saveUser(response.data!);
        debugPrint('✅ Profile image uploaded successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to upload image';
        return false;
      }
    } catch (e) {
      debugPrint('Upload profile image error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        _errorMessage.value =
            'Internet connection required to change password.';
        return false;
      }

      if (newPassword != confirmPassword) {
        _errorMessage.value = 'New password and confirmation do not match.';
        return false;
      }

      if (newPassword.length < 8) {
        _errorMessage.value = 'Password must be at least 8 characters long.';
        return false;
      }

      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response.success) {
        debugPrint('✅ Password changed successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to change password';
        return false;
      }
    } catch (e) {
      debugPrint('Change password error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (connectivityService.isOffline) {
        _errorMessage.value = 'Internet connection required to delete account.';
        return false;
      }

      final response = await _apiService.deleteAccount();

      if (response.success) {
        // Clear local state
        _currentUser.value = null;
        _isLoggedIn.value = false;
        _storage.write('isLoggedIn', false);
        await _offlineStorage.clearUser();
        ApiClient().clearTokens();

        debugPrint('Account deleted successfully');
        return true;
      } else {
        _errorMessage.value = response.message ?? 'Failed to delete account';
        return false;
      }
    } catch (e) {
      debugPrint('Delete account error: $e');
      _errorMessage.value = 'An error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
