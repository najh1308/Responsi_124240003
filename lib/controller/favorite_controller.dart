import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../model/item.dart';
import 'auth_controller.dart';

class FavoriteController extends GetxController {
  FavoriteController(this._prefs);

  final SharedPreferences _prefs;
  final RxList<Item> favorites = <Item>[].obs; // list reaktif

  // Key unik per akun
  String get _key =>
      AppConfig.favoritesKey(Get.find<AuthController>().username.value);

  // Baca favorit milik akun yang sedang login. Dipanggil saat masuk halaman utama.
  void load() {
    final raw = _prefs.getStringList(_key) ?? <String>[];
    favorites.assignAll(
      raw.map((s) => Item.fromJson(jsonDecode(s) as Map<String, dynamic>)),
    );
  }

  // Kosongkan dari memori (dipanggil saat logout)
  void clear() => favorites.clear();

  bool isFavorite(int id) => favorites.any((i) => i.id == id);

  // Tambah jika belum ada, hapus jika sudah ada.
  // Return true = ditambahkan, false = dihapus (dipakai untuk teks snackbar)
  Future<bool> toggle(Item item) async {
    final index = favorites.indexWhere((i) => i.id == item.id);
    final added = index == -1;
    if (added) {
      favorites.add(item);
    } else {
      favorites.removeAt(index);
    }
    await _save();
    return added;
  }

  // Hapus dan kembalikan posisi lama (untuk tombol "Urungkan")
  Future<int> remove(Item item) async {
    final index = favorites.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      favorites.removeAt(index);
      await _save();
    }
    return index;
  }

  Future<void> insertAt(int index, Item item) async {
    if (isFavorite(item.id)) return;
    favorites.insert(index.clamp(0, favorites.length), item);
    await _save();
  }

  Future<void> _save() => _prefs.setStringList(
        _key,
        favorites.map((i) => jsonEncode(i.toJson())).toList(),
      );
}
