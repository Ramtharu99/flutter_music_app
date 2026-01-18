import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/controllers/navigation_controller.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();

    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[800],
        currentIndex: navigationController.currentIndex.value,
        unselectedItemColor: Colors.white,
        unselectedLabelStyle: TextStyle(color: Colors.white),
        onTap: (index) => navigationController.changeIndex(index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            label: 'Tuner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upgrade_outlined),
            label: 'Upgrade',
          ),
        ],
      ),
    );
  }
}
