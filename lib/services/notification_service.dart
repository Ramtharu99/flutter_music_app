import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future<void> showDownloadNotification(String title) async {
    const androidDetails = AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Song downloads',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      indeterminate: true,
      ongoing: true,
    );

    await _notifications.show(
      0,
      'Downloading',
      title,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> completeDownload(String title) async {
    const androidDetails = AndroidNotificationDetails(
      'downloads',
      'Downloads',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.show(
      0,
      'Download completed',
      title,
      const NotificationDetails(android: androidDetails),
    );
  }
}
