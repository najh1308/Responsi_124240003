import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/main_controller.dart';
import 'favorite_page.dart';
import 'home_page.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final MainController c = Get.find<MainController>();
  final AuthController auth = Get.find<AuthController>();

  static const _titles = ['', 'Favorit'];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(c.index.value == 0
              ? 'Hi, ${auth.displayName} '
              : _titles[c.index.value]),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: c.index.value,
          onTap: c.changeTab,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          ],
        ),
      ),
    );
  }
}
