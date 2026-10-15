import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/product_thumbnail.dart';
import 'products_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final query = ref.watch(productSearchQueryProvider);

    final categoryNames = <int, String>{
      for (final c in categoriesAsync.asData?.value ?? const <Category>[])
        c.id: c.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.daftarProduk),
        actions: [
          IconButton(
            tooltip: AppStrings.kelolaKategori,
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.push('/products/categories'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/new'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.tambahProduk),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) =>
                  ref.read(productSearchQueryProvider.notifier).set(v),
              decoration: InputDecoration(
                hintText: AppStrings.cariProduk,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => ref
                            .read(productSearchQueryProvider.notifier)
                            .set(''),
                      ),
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: query.isEmpty
                        ? 'Belum ada produk'
                        : 'Produk "$query" tidak ditemukan',
                    action: query.isEmpty
                        ? PrimaryButton(
                            label: AppStrings.tambahProdukAjakan,
                            onPressed: () => context.push('/products/new'),
                          )
                        : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final product = products[i];
                    final categoryName = product.categoryId == null
                        ? 'Tanpa kategori'
                        : (categoryNames[product.categoryId] ?? '—');
                    return _ProductRow(
                      product: product,
                      categoryName: categoryName,
                      onTap: () => context.push('/products/${product.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  const Center(child: Text('Gagal memuat produk')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.categoryName,
    required this.onTap,
  });

  final Product product;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              ProductThumbnail(imagePath: product.imagePath, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppText.bodyStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryName,
                      style: AppText.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(formatRupiah(product.price), style: AppText.money),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSubtle),
            ],
          ),
        ),
      ),
    );
  }
}
