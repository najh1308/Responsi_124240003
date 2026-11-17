import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/favorite_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/item_tile.dart';
import '../widgets/state_views.dart';

class FavoritePage extends StatelessWidget {
  FavoritePage({super.key});

  final FavoriteController fav = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (fav.favorites.isEmpty) {
        return const EmptyView(
          icon: Icons.favorite_border,
          title: 'Belum ada favorit',
          subtitle: 'Ketuk ikon hati pada item untuk menambahkannya.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: fav.favorites.length,
        itemBuilder: (context, index) {
          final item = fav.favorites[index];
          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.horizontal, // kiri & kanan
            background: _bg(Alignment.centerLeft),
            secondaryBackground: _bg(Alignment.centerRight),
            onDismissed: (_) async {
              final oldIndex = await fav.remove(item); // hapus + simpan
              if (!context.mounted) return;
              showAppSnackBar(
                context,
                '${item.title} dihapus dari favorit',
                action: SnackBarAction(
                  label: 'Urungkan',
                  onPressed: () => fav.insertAt(oldIndex, item),
                ),
              );
            },
            child: ItemTile(
              item: item,
              onTap: () => Get.toNamed(AppRoutes.detail, arguments: item),
            ),
          );
        },
      );
    });
  }

  Widget _bg(Alignment a) => Container(
        alignment: a,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      );
}
