import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/item.dart';
import '../service/api_service.dart';

class ItemController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<Item> items = <Item>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool moreError = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString selectedCategory = ''.obs;
  final RxString searchQuery = ''.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  int _skip = 0;
  bool hasNext = true;
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    debounce(searchQuery, (_) => fetchInitial(),
        time: const Duration(milliseconds: 500));
    fetchCategories();
    fetchInitial();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMore();
  }

  void onSearchChanged(String v) {
    if (v.isNotEmpty) selectedCategory.value = '';
    searchQuery.value = v.trim();
  }

  void setCategory(String slug) {
    if (selectedCategory.value == slug && searchQuery.value.isEmpty) return;
    selectedCategory.value = slug;
    if (searchQuery.value.isNotEmpty) clearSearch();
    fetchInitial();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> fetchCategories() async {
    try {
      categories.assignAll(await _api.fetchCategories());
    } catch (_) {}
  }

  Future<bool> fetchInitial({bool silent = false}) async {
    final id = ++_requestId;
    if (!silent) isLoading.value = true;
    errorMessage.value = null;
    moreError.value = false;
    isLoadingMore.value = false;
    _skip = 0;

    try {
      final r = await _api.fetchItems(
        skip: 0,
        category: selectedCategory.value,
        query: searchQuery.value,
      );
      if (id != _requestId) return true;
      items.assignAll(r.items);
      _skip = r.items.length;
      hasNext = r.hasNext;
      return true;
    } catch (e) {
      if (id != _requestId) return false;
      if (!silent || items.isEmpty) {
        items.clear();
        errorMessage.value =
            e is ApiException ? e.message : 'Terjadi kesalahan tak terduga.';
      }
      return false;
    } finally {
      if (id == _requestId) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasNext) return;
    final id = _requestId;
    isLoadingMore.value = true;
    moreError.value = false;

    try {
      final r = await _api.fetchItems(
        skip: _skip,
        category: selectedCategory.value,
        query: searchQuery.value,
      );
      if (id != _requestId) return;
      items.addAll(r.items);
      _skip += r.items.length;
      hasNext = r.hasNext;
    } catch (_) {
      if (id == _requestId) moreError.value = true;
    } finally {
      if (id == _requestId) isLoadingMore.value = false;
    }
  }
}
