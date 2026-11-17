import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/wishlist_controller.dart';
import '../../model/item.dart';
import 'format.dart';
import 'wishlist_action.dart';

class ItemTile extends StatelessWidget {
  ItemTile({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  final WishlistController _wishlist = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prettyCategory(item.category),
                      style: TextStyle(
                          fontSize: 11, color: scheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(item.price),
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              final active = _wishlist.isWishlisted(item.id);
              return IconButton(
                tooltip: active ? 'Hapus dari wishlist' : 'Tambah ke wishlist',
                icon: Icon(
                  active ? Icons.favorite : Icons.favorite_border,
                  color: active ? Colors.red : Colors.grey,
                ),
                onPressed: () => toggleWishlist(context, item),
              );
            }),
          ]),
        ),
      ),
    );
  }
}
