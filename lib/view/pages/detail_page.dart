import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/detail_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../widgets/format.dart';
import '../widgets/state_views.dart';
import '../widgets/wishlist_action.dart';

class DetailPage extends StatelessWidget {
  DetailPage({super.key});

  final DetailController c = Get.find<DetailController>();
  final WishlistController wishlist = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          Obx(() {
            final item = c.item.value;
            if (item == null) return const SizedBox.shrink();
            final active = wishlist.isWishlisted(item.id);
            return IconButton(
              tooltip: active ? 'Hapus dari wishlist' : 'Tambah ke wishlist',
              icon: Icon(active ? Icons.favorite : Icons.favorite_border),
              color: active ? Colors.redAccent : Colors.white,
              onPressed: () => toggleWishlist(context, item),
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
            onRetry: c.fetch,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    item.image,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const LoadingView(),
                    errorBuilder: (context, error, stack) => const Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    prettyCategory(item.category),
                    style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 2),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                formatPrice(item.price),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  _InfoRow(
                    icon: Icons.category,
                    label: 'Kategori',
                    value: prettyCategory(item.category),
                  ),
                  if (item.brand.isNotEmpty)
                    _InfoRow(
                      icon: Icons.sell,
                      label: 'Brand',
                      value: item.brand,
                    ),
                  _InfoRow(
                    icon: Icons.payments,
                    label: 'Harga',
                    value: formatPrice(item.price),
                  ),
                  _InfoRow(
                    icon: Icons.star,
                    label: 'Rating',
                    value: item.rating.toStringAsFixed(1),
                  ),
                  _InfoRow(
                    icon: Icons.percent,
                    label: 'Diskon',
                    value: '${item.discountPercentage.toStringAsFixed(2)}%',
                  ),
                  _InfoRow(
                    icon: Icons.inventory_2,
                    label: 'Stok',
                    value: item.stock > 0 ? '${item.stock} tersedia' : 'Habis',
                    valueColor: item.stock > 0 ? Colors.green.shade700 : Colors.red,
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              const Text(
                'Deskripsi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final active = wishlist.isWishlisted(item.id);
                return FilledButton.icon(
                  onPressed: () => toggleWishlist(context, item),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: active ? Colors.red : scheme.primary,
                  ),
                  icon: Icon(active ? Icons.favorite : Icons.favorite_border),
                  label: Text(
                    active ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: valueColor ?? Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
