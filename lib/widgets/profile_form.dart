import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/services/api_service.dart';
import 'package:music_app/utils/app_colors.dart';
import 'package:music_app/widgets/custom_text_field.dart';

class ProfileForm extends StatefulWidget {
  final String label;
  final String? value;
  final IconData icon;

  const ProfileForm({
    super.key,
    required this.label,
    this.value,
    required this.icon,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final AuthController _authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty');
      return;
    }
    if (_emailController.text.isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (response.success && response.data != null) {
        // Update current user
        _authController.updateCurrentUser(response.data!);

        // Refresh the form fields
        _nameController.text = response.data!.fullName;
        _emailController.text = response.data!.email;
        _phoneController.text = response.data!.phone ?? '';

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update profile',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Save profile error: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          CustomTextField(
            labelText: 'Full Name',
            controller: _nameController,
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Email',
            controller: _emailController,
            prefixIcon: Icons.email,
            enabled: false,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Phone Number',
            controller: _phoneController,
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
