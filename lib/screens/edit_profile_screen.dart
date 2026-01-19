import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/utils/app_colors.dart';
import 'package:music_app/widgets/profile_form.dart';
import 'package:music_app/widgets/profile_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final AuthController _authController = Get.find<AuthController>();

  Future<void> _onRefresh() async {
    if (_connectivityService.isOffline) return;
    _authController.currentUser;

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryColor,
        backgroundColor: Colors.black,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ProfileImage(),
              const SizedBox(height: 24),
              ProfileForm(),
            ],
          ),
        ),
      ),
    );
  }
}
