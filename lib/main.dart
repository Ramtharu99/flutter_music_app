import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/navigation_controller.dart';
import 'package:music_app/controllers/theme_controller.dart';
import 'package:music_app/screens/downloaded_songs_screen.dart';
import 'package:music_app/screens/splash_screen.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/notification_service.dart';
import 'package:music_app/utils/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      Get.to(() => DownloadedSongsScreen());
    },
  );

  await dotenv.load(fileName: '.env');

  final stripePublicKey = dotenv.get('STRIPE_PUBLIC_KEY');

  Stripe.publishableKey = stripePublicKey;
  Stripe.instance.applySettings().catchError((e) {
    debugPrint('Stripe init error: $e');
  });

  await GetStorage.init();

  Get.put(ConnectivityService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(NavigationController(), permanent: true);
  Get.put(DownloadController(), permanent: true);

  NotificationService.init().catchError((e) {
    debugPrint('Notification init error: $e');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navakarna',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.fade,
      /*home: VideoPlayerScreen(),*/
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/downloaded_songs', page: () => const SplashScreen()),
      ],
    );
  }
}
