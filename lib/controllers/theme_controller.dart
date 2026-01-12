import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = "isDarkMode";

  @override
  void onInit() {
    super.onInit();
    Get.changeThemeMode(_loadTheme() ? ThemeMode.dark : ThemeMode.light);
  }

  bool _loadTheme() => _box.read(_key) ?? false;

  void toggleTheme() {
    final isDark = !_loadTheme();
    _box.write(_key, isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
