import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/favorite_controller.dart';
import '../../model/item.dart';
import 'format.dart';

class ItemTile extends StatelessWidget {
  ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onFavoritePressed,
  });

  final Item item;
  final VoidCallback onTap; 
  final VoidCallback? onFavoritePressed; 

  final FavoriteController _fav = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                loadingBuilder: (c, child, p) => p == null
                    ? child
                    : const SizedBox(
                        width: 64,
                        height: 64,
                        child: Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2)))),
                errorBuilder: (c, e, s) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(prettyCategory(item.category),
                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(formatPrice(item.price),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            Obx(() {
              final isFav = _fav.isFavorite(item.id);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey),
                onPressed: onFavoritePressed ?? () => _fav.toggle(item),
              );
            }),
          ]),
        ),
      ),
    );
  }
}
