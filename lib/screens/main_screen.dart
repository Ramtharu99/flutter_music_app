import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/navigation_controller.dart';
import 'package:music_app/screens/clock_screen.dart';
import 'package:music_app/screens/tuner_screen.dart';
import 'package:music_app/screens/upgrade_screen.dart';
import 'package:music_app/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: const [TunerScreen(), ClockScreen(), UpgradeScreen()],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
