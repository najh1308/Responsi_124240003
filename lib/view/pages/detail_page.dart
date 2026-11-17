import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/detail_controller.dart';
import '../../controller/favorite_controller.dart';
import '../../model/item.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/format.dart';
import '../widgets/state_views.dart';

class DetailPage extends StatelessWidget {
  DetailPage({super.key});

  final DetailController c = Get.find<DetailController>();
  final FavoriteController fav = Get.find<FavoriteController>();

  // Toggle favorit lalu tampilkan snackbar sesuai hasilnya
  Future<void> _toggleFavorite(BuildContext context, Item item) async {
    final added = await fav.toggle(item); // true = ditambahkan
    if (!context.mounted) return; // cek context setelah await
    showAppSnackBar(
        context,
        added
            ? '${item.title} ditambahkan ke favorit'
            : '${item.title} dihapus dari favorit');
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(c.selected.title), // dari data kiriman Home, langsung ada
        actions: [
          // Ikon hati di AppBar: berubah sesuai status favorit
          Obx(() {
            final item = c.item.value;
            if (item == null) return const SizedBox.shrink();
            final isFav = fav.isFavorite(item.id);
            return IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              color: isFav ? Colors.redAccent : null,
              onPressed: () => _toggleFavorite(context, item),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) return const LoadingView();

        final item = c.item.value;
        if (c.errorMessage.value != null || item == null) {
          return ErrorView(
              message: c.errorMessage.value ?? 'Data tidak tersedia.',
              onRetry: c.fetch);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ---- Gambar besar ----
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                height: 260,
                child: Image.network(item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image,
                        size: 64, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(formatPrice(item.price),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            // ---- Info ----
            Card(
              child: Column(children: [
                _InfoRow(icon: Icons.category, label: 'Kategori', value: prettyCategory(item.category)),
                _InfoRow(icon: Icons.sell, label: 'Brand', value: item.brand),
                _InfoRow(icon: Icons.star, label: 'Rating', value: item.rating.toStringAsFixed(1)),
              ]),
            ),
            const SizedBox(height: 12),
            Text(item.description, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 20),
            // ---- Tombol aksi ----
            const SizedBox(height: 8),
            Obx(() {
              final isFav = fav.isFavorite(item.id);
              return OutlinedButton.icon(
                onPressed: () => _toggleFavorite(context, item),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? const Color.fromARGB(255, 244, 54, 54) : null),
                label: Text(isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist'),
              );
            }),
          ]),
        );
      }),
    );
  }
}

// Satu baris info (ikon + label + nilai). Private (awalan _) = hanya dipakai di file ini.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        subtitle: Text(value,
            style: const TextStyle(
                color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
      );
}
