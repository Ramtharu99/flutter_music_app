import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_app/authScreen/sign_in_screen.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/core/api/api_client.dart';
import 'package:music_app/screens/downloaded_songs_screen.dart';
import 'package:music_app/screens/help_center_screen.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/utils/app_colors.dart';
import 'package:music_app/widgets/custom_text_field.dart';

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
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _imageFile;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  /// Load current user data from server
  Future<void> _loadUserData() async {
    debugPrint('\n📱 [ACCOUNT SCREEN] _loadUserData() called');

    // Check token status
    final token = ApiClient().authToken;
    debugPrint('🔑 [TOKEN] Current auth token:');
    if (token != null) {
      debugPrint('   ✅ Token exists (${token.length} chars)');
      final prefix = token.length > 20 ? token.substring(0, 20) : token;
      debugPrint('   ✅ Token prefix: $prefix...');
    } else {
      debugPrint('   ❌ NO TOKEN FOUND - This will cause 401 error!');
    }

    if (_connectivityService.isOffline) {
      debugPrint('⚠️  Offline mode: Using cached user data');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 [API] Fetching from /me endpoint...');
      // Fetch fresh user data from /me endpoint
      final response = await _apiService.getProfile();

      debugPrint('📥 [API] Response received:');
      debugPrint('   - Success: ${response.success}');
      debugPrint('   - Message: ${response.message}');
      debugPrint('   - Data: ${response.data}');

      if (response.success && response.data != null && mounted) {
        final user = response.data!;
        debugPrint('✅ [SUCCESS] User profile loaded:');
        debugPrint('   - ID: ${user.id}');
        debugPrint('   - Name: ${user.name}');
        debugPrint('   - Email: ${user.email}');
        debugPrint('   - Phone: ${user.phone}');
        debugPrint('   - Profile Image: ${user.profileImage}');
        debugPrint('   - Premium: ${user.isPremium}');
        debugPrint('   - Created: ${user.createdAt}');

        _authController.updateCurrentUser(user);
        _initializeControllers();
        debugPrint('✓ UI Controllers initialized with user data');
      } else {
        if (mounted) {
          debugPrint('❌ [FAILED] Profile fetch failed: ${response.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('❌ [ERROR] Exception during profile load: $e');
        debugPrint('   Stack trace: ${StackTrace.current}');
      }
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
    debugPrint('\n🔄 [REFRESH] Pull-to-refresh triggered');

    // Check token - try multiple ways to debug
    final token = ApiClient().authToken;
    debugPrint('🔑 [TOKEN] Token from ApiClient:');
    debugPrint('   authToken = $token');
    debugPrint('   isAuthenticated = ${ApiClient().isAuthenticated}');

    if (token != null) {
      debugPrint('   ✅ Token exists (length: ${token.length})');
    } else {
      debugPrint('   ❌ NO TOKEN - Refresh will fail with 401!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Not authenticated. Please log in again.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_connectivityService.isOffline) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No internet connection')));
      return;
    }

    // Refresh user profile from server
    final success = await _authController.refreshUserProfile();

    if (success) {
      _initializeControllers();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Profile refreshed')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to refresh profile')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _uploadProfileImage(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Image picking error: $e");
    }
  }

  Future<void> _uploadProfileImage(String imagePath) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final response = await _apiService.uploadProfileImage(imagePath);

      if (response.success && response.data != null) {
        _authController.updateCurrentUser(response.data!);
      } else {
        debugPrint('Error on uploading profile');
        setState(() {
          _imageFile = null;
        });
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      setState(() {
        _imageFile = null;
      });
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email cannot be empty')));
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phone cannot be empty')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (response.success && response.data != null) {
        _authController.updateCurrentUser(response.data!);

        if (mounted) {
          setState(() {
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Profile updated successfully'),
                ],
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to update profile'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        debugPrint('✗ Failed to update profile: ${response.message}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      debugPrint('✗ Save profile error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelEditing() {
    _initializeControllers();
    setState(() {
      _isEditing = false;
    });
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
          // Loading overlay when fetching user data
          if (_isLoading && _authController.currentUser == null)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
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
            Stack(
              children: [
                Obx(() {
                  final user = _authController.currentUser;
                  final imageProvider = _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : (user?.profileImage != null &&
                            user!.profileImage!.isNotEmpty)
                      ? NetworkImage(user.profileImage!) as ImageProvider
                      : null;

                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingImage ? null : _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: _isUploadingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Display mode
            if (!_isEditing)
              Column(
                children: [
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
                  if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.phone!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
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
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
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
              )
            else
              // Edit mode
              Column(
                children: [
                  // Name field
                  CustomTextField(
                    labelText: 'Full name',
                    controller: _nameController,
                    initialValue: user?.name ?? user?.fullName,
                    prefixIcon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your new name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your new email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    labelText: 'Phone',
                    controller: _phoneController,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your new phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _cancelEditing,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.white70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
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
                }
              },
            ),
          );
        }).toList(),
      ),
    );
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
                color: Colors.red.withValues(alpha: 0.1),
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
                  child: ElevatedButton(
                    onPressed: () async {
                      await _authController.logout();
                      Get.offAll(() => const SignInScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
}
