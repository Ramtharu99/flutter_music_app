/// Splash Screen
/// Handles app initialization and navigation based on:
/// - Logged in user (online or offline) → Main screen
/// - Not logged in → Sign in screen
/// - First time user and not logged in → Sign in screen
///
/// Payment screen and auth main screen are skipped.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/authScreen/sign_in_screen.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/screens/main_screen.dart';
import 'package:music_app/services/connectivity_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  void _startNavigation() async {
    // Wait for storage to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check connectivity
    final connectivityService = Get.find<ConnectivityService>();
    await connectivityService.checkConnectivity();

    final isOffline = connectivityService.isOffline;
    final isLoggedIn = authController.isLoggedIn;

    debugPrint('🚀 Navigation Decision:');
    debugPrint('   - Offline: $isOffline');
    debugPrint('   - Logged In: $isLoggedIn');

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in (works offline too!)
      // Navigate directly to main screen
      Get.offAll(() => const MainScreen());
    } else {
      // First time or not logged in - go to sign in screen
      // Skip payment screen and auth main screen
      if (isOffline) {
        Get.offAll(() => SignInScreen());
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            'Offline Mode',
            'Connect to internet to sign in.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey.shade800,
            colorText: Colors.white,
          );
        });
      } else {
        Get.offAll(() => SignInScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 140,
                  width: 140,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
