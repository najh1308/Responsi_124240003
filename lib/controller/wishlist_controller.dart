import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../model/item.dart';
import 'auth_controller.dart';

class WishlistController extends GetxController {
  final RxList<Item> wishlist = <Item>[].obs;

  Box<String> get _box => Hive.box<String>(AppConfig.wishlistBox);

  String get _key => Get.find<AuthController>().username.value.toLowerCase();

  void load() {
    final raw = _box.get(_key);
    if (raw == null) {
      wishlist.clear();
      return;
    }
    wishlist.assignAll(
      (jsonDecode(raw) as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>)),
    );
  }

  void clear() => wishlist.clear();

  bool isWishlisted(int id) => wishlist.any((i) => i.id == id);

  Future<bool> toggle(Item item) async {
    final index = wishlist.indexWhere((i) => i.id == item.id);
    final added = index == -1;
    if (added) {
      wishlist.add(item);
    } else {
      wishlist.removeAt(index);
    }
    await _save();
    return added;
  }

  Future<void> _save() =>
      _box.put(_key, jsonEncode(wishlist.map((i) => i.toJson()).toList()));
}
