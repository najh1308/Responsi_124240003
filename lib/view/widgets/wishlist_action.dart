import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/wishlist_controller.dart';
import '../../model/item.dart';
import 'app_snackbar.dart';

Future<void> toggleWishlist(BuildContext context, Item item) async {
  final messenger = ScaffoldMessenger.of(context);
  final added = await Get.find<WishlistController>().toggle(item);

  if (added) {
    showMessengerSnackBar(
      messenger,
      '${item.title} ditambahkan ke wishlist',
      color: Colors.green.shade600,
    );
  } else {
    showMessengerSnackBar(
      messenger,
      '${item.title} dihapus dari wishlist',
      color: Colors.red.shade600,
    );
  }
}
