import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxController {
  static ConnectivityService get instance => Get.find<ConnectivityService>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool _isOnline = true.obs;
  bool get isOnline => _isOnline.value;
  bool get isOffline => !_isOnline.value;

  final Rx<ConnectivityResult> _connectionType = ConnectivityResult.none.obs;
  ConnectivityResult get connectionType => _connectionType.value;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startListening();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Connectivity init error: $e');
      _isOnline.value = true;
    }
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (e) {
        debugPrint('Connectivity stream error: $e');
      },
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOnline.value = false;
      _connectionType.value = ConnectivityResult.none;
      debugPrint('📡 Network: OFFLINE');
    } else {
      _isOnline.value = true;
      _connectionType.value = results.first;
      debugPrint('📡 Network: ONLINE (${results.first.name})');
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isOnline.value;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return true;
    }
  }

  String get connectionTypeString {
    switch (_connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  void showOfflineSnackbar() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      'No Internet Connection',
      'You are currently offline. Some features may not be available.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void showOnlineSnackbar() {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      'Back Online',
      'Your internet connection has been restored.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
