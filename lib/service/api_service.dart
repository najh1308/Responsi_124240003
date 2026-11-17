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

  Future<dynamic> _getJson(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw ApiException('Server bermasalah (kode ${response.statusCode}).');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Silakan coba lagi.');
    } catch (_) {
      throw ApiException('Gagal terhubung ke server. Periksa koneksi internet.');
    }
  }

  Future<PagedResult<Item>> fetchItems({
    int skip = 0,
    String category = '',
    String query = '',
  }) async {
    String path = '/products';
    final params = <String, String>{
      'limit': '${AppConfig.pageSize}',
      'skip': '$skip',
    };

    if (query.isNotEmpty) {
      path = '/products/search';
      params['q'] = query;
    } else if (category.isNotEmpty) {
      path = '/products/category/$category';
    }

    final json = await _getJson(Uri.https(AppConfig.apiHost, path, params))
        as Map<String, dynamic>;

    final items = (json['products'] as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();

    final total = json['total'] as int;
    return PagedResult<Item>(items, skip + items.length < total);
  }

  Future<Item> fetchItem(int id) async {
    final json = await _getJson(Uri.https(AppConfig.apiHost, '/products/$id'))
        as Map<String, dynamic>;
    return Item.fromJson(json);
  }

  Future<List<String>> fetchCategories() async {
    final json =
        await _getJson(Uri.https(AppConfig.apiHost, '/products/category-list'));
    return (json as List).map((e) => e.toString()).toList();
  }
}
