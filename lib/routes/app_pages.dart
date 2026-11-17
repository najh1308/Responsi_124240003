import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/detail_controller.dart';
import '../controller/item_controller.dart';
import '../controller/wishlist_controller.dart';
import '../view/pages/detail_page.dart';
import '../view/pages/home_page.dart';
import '../view/pages/login_page.dart';
import '../view/pages/wishlist_page.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final loggedIn = Get.find<AuthController>().isLoggedIn.value;
    return loggedIn ? null : const RouteSettings(name: AppRoutes.login);
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<WishlistController>().load();
    Get.lazyPut<ItemController>(() => ItemController());
  }
}

class DetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailController>(() => DetailController());
  }
}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => WishlistPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => DetailPage(),
      binding: DetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
