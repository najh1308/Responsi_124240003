import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/item.dart';
import '../service/api_service.dart';

class ItemController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<Item> items = <Item>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs; // loading layar penuh (halaman pertama)
  final RxBool isLoadingMore = false.obs; // loading kecil di bawah list
  final RxBool moreError = false.obs;
  final RxnString errorMessage = RxnString(); // null = tidak ada error
  final RxString selectedCategory = ''.obs; // '' = semua
  final RxString searchQuery = ''.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  int _skip = 0; // berapa data yang sudah diambil
  bool hasNext = true; // masih ada halaman lagi?
  int _requestId = 0; // penanda request terbaru (cegah response basi menimpa)

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    // debounce: tunggu 500 ms setelah user BERHENTI mengetik baru request,
    // supaya tidak kirim request di setiap huruf
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

  // Dipanggil setiap scroll: jika tinggal 300px dari dasar, muat halaman berikut
  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMore();
  }

  void onSearchChanged(String v) {
    // Endpoint search tidak bisa digabung kategori -> reset kategori
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
      if (id != _requestId) return true; // ada request yang lebih baru, abaikan
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

  // ---- INFINITE SCROLL: halaman berikutnya ----------------------------------
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
      items.addAll(r.items); // addAll = tambah ke belakang, bukan ganti
      _skip += r.items.length;
      hasNext = r.hasNext;
    } catch (_) {
      if (id == _requestId) moreError.value = true;
    } finally {
      if (id == _requestId) isLoadingMore.value = false;
    }
  }
}
