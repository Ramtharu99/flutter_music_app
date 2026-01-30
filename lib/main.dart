import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/navigation_controller.dart';
import 'package:music_app/controllers/theme_controller.dart';
import 'package:music_app/controllers/video_controller.dart';
import 'package:music_app/screens/splash_screen.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: '.env');
  final stripePublicKey = dotenv.get('STRIPE_PUBLIC_KEY', fallback: '');
  if (stripePublicKey.isEmpty) {
    debugPrint('⚠️ Stripe key missing!');
  }

  // Stripe
  Stripe.publishableKey = stripePublicKey;
  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint('Stripe init error: $e');
  }

  // Storage
  await GetStorage.init();

  // Controllers
  Get.put(ConnectivityService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(NavigationController(), permanent: true);
  Get.put(DownloadController(), permanent: true);
  Get.put(VideoController(), permanent: true);

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
      home: const SplashScreen(),
    );
  }
}
