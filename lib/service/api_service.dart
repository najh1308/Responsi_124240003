import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../model/item.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class PagedResult<T> {
  final List<T> items;
  final bool hasNext;
  const PagedResult(this.items, this.hasNext);
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  // ---- Fungsi dasar: GET lalu decode JSON ----------------------------------
  // Mengembalikan `dynamic` karena JSON bisa berupa Map {..} ATAU List [..]
  Future<dynamic> _getJson(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Server bermasalah (kode ${response.statusCode}).');
    } on ApiException {
      rethrow; // biarkan error buatan kita lewat apa adanya
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Silakan coba lagi.');
    } catch (_) {
      // internet mati, DNS gagal, JSON rusak, dll.
      throw ApiException('Gagal terhubung ke server. Periksa koneksi internet.');
    }
  }

  // ---- LIST DATA (+ pagination, pencarian, filter kategori) ----------------
  // ▶ UBAH : path endpoint. Contoh Rick&Morty: '/api/character' dan
  //          parameter status/name/page (lihat dokumentasi soal).
  // Pagination DummyJSON memakai limit & skip:
  //   halaman 1 -> skip=0, halaman 2 -> skip=20, dst.
  Future<PagedResult<Item>> fetchItems({
    int skip = 0,
    String category = '',
    String query = '',
  }) async {
    // Pilih endpoint: pencarian > kategori > semua
    String path = 'products';
    final params = <String, String>{
      'limit': '${AppConfig.pageSize}',
      'skip': '$skip',
    };

    final json = await _getJson(Uri.https(AppConfig.apiHost, path, params))
        as Map<String, dynamic>;

    final items = (json['products'] as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = json['total'] as int;
    return PagedResult<Item>(items, skip + items.length < total);
  }

  // ---- DETAIL SATU DATA: GET /products/{id} --------------------------------
  Future<Item> fetchItem(int id) async {
    final json = await _getJson(Uri.https(AppConfig.apiHost, '/products'))
        as Map<String, dynamic>;
    return Item.fromJson(json);
  }

  // ---- DAFTAR KATEGORI untuk chip filter: GET /products/category-list ------
  // Response berupa List<String>, bukan Map.
  Future<List<String>> fetchCategories() async {
    final json =
        await _getJson(Uri.https(AppConfig.apiHost, '/products/category-list'));
    return (json as List).map((e) => e.toString()).toList();
  }
}
