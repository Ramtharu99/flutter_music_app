import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:music_app/controllers/auth_controller.dart';
import 'package:music_app/controllers/download_controller.dart';
import 'package:music_app/controllers/navigation_controller.dart';
import 'package:music_app/controllers/theme_controller.dart';
import 'package:music_app/screens/splash_screen.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/services/notification_service.dart';
import 'package:music_app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String stripe_public_key =
      "pk_test_51Srg46Qkp33zQdtFE7kisbGhP0dvFrrryDzy2xxOaOynjDJuIHObTTQu4nbYJr3Y9fpYiYpGWFTC83dCkeZ6nrx9006L71x6iA";

  String stripe_secret_key =
      "sk_test_51Srg46Qkp33zQdtFrxFEnr1vByMX6jSoCHWv51SvgUAMaKTOiQYgnaKqstOdA75kfoFwnrt6c5EGkdg6AwtoRHtA00Ovbnq8mG";

  Stripe.publishableKey = stripe_public_key;

  await GetStorage.init();

  Get.put(ConnectivityService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(NavigationController(), permanent: true);
  Get.put(DownloadController(), permanent: true);
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      defaultTransition: Transition.fade,
      home: const SplashScreen(),
    );
  }
}
