import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/item_controller.dart';
import '../../controller/wishlist_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/format.dart';
import '../widgets/item_tile.dart';
import '../widgets/state_views.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ItemController c = Get.find<ItemController>();
  final AuthController auth = Get.find<AuthController>();
  final WishlistController wishlist = Get.find<WishlistController>();

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok == true) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  auth.username.value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Wishlist',
              icon: Badge(
                isLabelVisible: wishlist.wishlist.isNotEmpty,
                label: Text('${wishlist.wishlist.length}'),
                child: const Icon(Icons.favorite),
              ),
              onPressed: () => Get.toNamed(AppRoutes.wishlist),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: c.searchController,
            onChanged: c.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: c.searchController,
                builder: (context, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: c.clearSearch,
                      ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: Obx(() {
            final slugs = ['', ...c.categories];
            return ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              children: slugs.map((slug) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(slug.isEmpty ? 'Semua' : prettyCategory(slug)),
                    selected: c.selectedCategory.value == slug,
                    onSelected: (_) => c.setCategory(slug),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            if (c.isLoading.value) return const LoadingView();

            if (c.errorMessage.value != null) {
              return ErrorView(
                message: c.errorMessage.value!,
                onRetry: () => c.fetchInitial(),
              );
            }

            if (c.items.isEmpty) {
              return const EmptyView(
                icon: Icons.search_off,
                title: 'Produk tidak ditemukan',
                subtitle: 'Coba ubah kategori atau kata kunci pencarian.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final ok = await c.fetchInitial(silent: true);
                if (!ok && context.mounted) {
                  showAppSnackBar(context, 'Gagal memperbarui data.',
                      color: Colors.red.shade600);
                }
              },
              child: ListView.builder(
                controller: c.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: c.items.length + 1,
                itemBuilder: (context, index) {
                  if (index == c.items.length) return _footer();
                  final item = c.items[index];
                  return ItemTile(
                    item: item,
                    onTap: () => Get.toNamed(AppRoutes.detail, arguments: item),
                  );
                },
              ),
            );
          }),
        ),
      ]),
    );
  }

  Widget _footer() {
    return Obx(() {
      if (c.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (c.moreError.value) {
        return TextButton.icon(
          onPressed: c.loadMore,
          icon: const Icon(Icons.refresh),
          label: const Text('Gagal memuat, ketuk untuk coba lagi'),
        );
      }
      return const SizedBox(height: 16);
    });
  }
}
