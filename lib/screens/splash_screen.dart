import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/authScreen/signIn_screen.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/payments/payment_screen.dart';
import 'package:music_app/screens/main_screen.dart';

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

    // Wait Splash animation
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    if (authController.isFirstTime) {
      Get.offAll(() => const PaymentScreen());
    } else if (authController.isLoggedIn) {
      Get.offAll(() => const MainScreen());
    } else {
      Get.offAll(() => SignInScreen());
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
