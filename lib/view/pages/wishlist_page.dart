import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/wishlist_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/item_tile.dart';
import '../widgets/state_views.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  final WishlistController wishlist = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Obx(() {
        if (wishlist.wishlist.isEmpty) {
          return const EmptyView(
            icon: Icons.favorite_border,
            title: 'Wishlist masih kosong',
            subtitle: 'Ketuk ikon hati pada produk untuk menambahkannya.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: wishlist.wishlist.length,
          itemBuilder: (context, index) {
            final item = wishlist.wishlist[index];
            return ItemTile(
              key: ValueKey(item.id),
              item: item,
              onTap: () => Get.toNamed(AppRoutes.detail, arguments: item),
            );
          },
        );
      }),
    );
  }
}
