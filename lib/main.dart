import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'controller/auth_controller.dart';
import 'controller/wishlist_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'service/local_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDb.init();

  final prefs = await SharedPreferences.getInstance();

  Get.put(AuthController(prefs), permanent: true);
  Get.put(WishlistController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = Get.find<AuthController>().isLoggedIn.value;
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF5E35B1));

    return GetMaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F4F8),
      ),
      initialRoute: loggedIn ? AppRoutes.home : AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
