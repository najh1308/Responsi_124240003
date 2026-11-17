import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../controller/item_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/format.dart';
import '../widgets/item_tile.dart';
import '../widgets/state_views.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ItemController c = Get.find<ItemController>();
  final AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() => Text(
                'Halo, ${auth.displayName}! Mau cari apa hari ini?',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: scheme.onPrimaryContainer),
              )),
        ),
      ),


      // ---- [3] Chip filter kategori (geser horizontal) ----------------------
      SizedBox(
        height: 48,
        child: Obx(() {
          // Daftar chip = "Semua" + semua kategori dari API
          final slugs = ['', ...c.categories];
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

      // ---- [4] Isi: loading / error / kosong / list -------------------------
      Expanded(
        child: Obx(() {
          if (c.isLoading.value) return const LoadingView();

          if (c.errorMessage.value != null) {
            return ErrorView(
                message: c.errorMessage.value!, onRetry: () => c.fetchInitial());
          }

          if (c.items.isEmpty) {
            return const EmptyView(
              icon: Icons.search_off,
              title: 'Data tidak ditemukan',
              subtitle: 'Coba ubah filter atau kata kunci pencarian.',
            );
          }

          // RefreshIndicator = tarik ke bawah untuk refresh
          return RefreshIndicator(
            onRefresh: () async {
              final ok = await c.fetchInitial(silent: true);
              if (!ok && context.mounted) {
                showAppSnackBar(context, 'Gagal memperbarui data.');
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
    ]);
  }

  // Footer list: spinner saat memuat halaman berikutnya / tombol coba lagi
  Widget _footer() {
    return Obx(() {
      if (c.isLoadingMore.value) {
        return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()));
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
