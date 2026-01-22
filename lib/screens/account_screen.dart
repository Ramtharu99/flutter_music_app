import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/authScreen/sign_in_screen.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/screens/downloaded_songs_screen.dart';
import 'package:music_app/screens/edit_profile_screen.dart';
import 'package:music_app/screens/help_center_screen.dart';
import 'package:music_app/screens/manage_account_screen.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/utils/app_colors.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  /// Load current user data from server
  Future<void> _loadUserData() async {
    if (_connectivityService.isOffline) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getProfile();
      if (response.success && response.data != null && mounted) {
        _authController.updateCurrentUser(response.data!);
        _initializeControllers();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeControllers() {
    final user = _authController.currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_connectivityService.isOffline) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No internet connection')));
      return;
    }

    final success = await _authController.refreshUserProfile();
    if (success && mounted) {
      _initializeControllers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Profile refreshed',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: _authController.isLoading
                          ? null
                          : () async {
                              await _authController.logout();
                              Get.offAll(() => SignInScreen());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _authController.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Obx(() {
      final user = _authController.currentUser;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade800,
              backgroundImage:
                  (user?.profileImage != null &&
                      (user?.profileImage ?? '').isNotEmpty)
                  ? NetworkImage(user!.profileImage!)
                  : null,
              child:
                  (user?.profileImage == null ||
                      (user?.profileImage ?? '').isEmpty)
                  ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(height: 18),

            // Name
            Text(
              user?.name ?? 'Guest User',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              user?.email ?? 'No email',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),

            // Phone (if available)
            if (user?.phone != null && (user?.phone ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user?.phone ?? '',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],

            // Premium badge
            if (user?.isPremium == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.to(() => EditProfileScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {'icon': Icons.person, 'title': 'Manage Account'},
      {'icon': Icons.download_done, 'title': 'Downloaded Songs'},
      {'icon': Icons.help_outline, 'title': 'Help Center'},
      {'icon': Icons.logout, 'title': 'Logout'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item) {
          final isLogout = item['title'] == 'Logout';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: isLogout ? Colors.red : AppColors.primaryColor,
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: isLogout ? Colors.red : Colors.white,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
              onTap: () {
                if (item['title'] == 'Logout') {
                  _showLogoutDialog(context);
                } else if (item['title'] == 'Help Center') {
                  Get.to(() => const HelpCenterScreen());
                } else if (item['title'] == 'Downloaded Songs') {
                  Get.to(() => const DownloadedSongsScreen());
                } else if (item['title'] == 'Manage Account') {
                  Get.to(() => ManageAccountScreen());
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'My Account',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: [
          Obx(() {
            if (_connectivityService.isOffline) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primaryColor,
            backgroundColor: Colors.black,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildProfileSection(context),
                  const SizedBox(height: 24),
                  _buildMenuSection(context),
                ],
              ),
            ),
          ),
          if (_isLoading && _authController.currentUser == null)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Loading your profile...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
