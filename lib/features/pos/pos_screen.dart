import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_card.dart';
import '../products/products_providers.dart';
import 'cart_provider.dart';
import 'pos_providers.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final tablet = isTabletWidth(width);

    final content = _ProductArea(tablet: tablet);

    if (tablet) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(child: content),
            const _CartPanel(),
          ],
        ),
      );
    }

    final itemCount = ref.watch(cartItemCountProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      body: content,
      bottomNavigationBar: itemCount == 0
          ? null
          : SafeArea(
              child: Container(
                color: AppColors.navy,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$itemCount item',
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedOnDark,
                            ),
                          ),
                          Text(
                            formatRupiah(total),
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => context.push('/pos/cart'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Bayar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProductArea extends ConsumerWidget {
  const _ProductArea({required this.tablet});

  final bool tablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(posProductListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      bottom: !tablet,
      child: Padding(
        padding: EdgeInsets.all(tablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tablet) ...[
              Text(AppStrings.kasir, style: AppText.screenTitle),
              const SizedBox(height: 16),
            ],
            TextField(
              onChanged: (v) =>
                  ref.read(posSearchQueryProvider.notifier).set(v),
              decoration: const InputDecoration(
                hintText: AppStrings.cariProduk,
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: categoriesAsync.when(
                data: (categories) => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: AppStrings.semua,
                        selected: selectedCategory == null,
                        onTap: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .select(null),
                      ),
                    ),
                    for (final c in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: c.name,
                          selected: selectedCategory == c.id,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .select(c.id),
                        ),
                      ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'Belum ada produk',
                      action: FilledButton(
                        onPressed: () => context.push('/products/new'),
                        child: const Text(AppStrings.tambahProdukAjakan),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: productGridColumns(width),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      final product = products[i];
                      final qty = ref.watch(
                        cartQtyForProductProvider(product.id),
                      );
                      return ProductCard(
                        name: product.name,
                        price: product.price,
                        imagePath: product.imagePath,
                        qtyInCart: qty,
                        onTap: () =>
                            ref.read(cartProvider.notifier).addProduct(product),
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
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final method = ref.watch(checkoutMethodProvider);

    return Container(
      width: 300,
      color: AppColors.card,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(AppStrings.pesanan, style: AppText.cardTitle),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () => ref.read(cartProvider.notifier).clear(),
                      child: const Text(AppStrings.hapusSemua),
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Keranjang masih kosong',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 24),
                      itemBuilder: (context, i) => _CartPanelRow(item: items[i]),
                    ),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MethodButton(
                            label: AppStrings.tunai,
                            selected: method == 'cash',
                            onTap: () => ref
                                .read(checkoutMethodProvider.notifier)
                                .select('cash'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MethodButton(
                            label: AppStrings.qris,
                            selected: method == 'qris',
                            onTap: () => ref
                                .read(checkoutMethodProvider.notifier)
                                .select('qris'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.push('/pos/checkout'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Bayar ${formatRupiah(total)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartPanelRow extends ConsumerWidget {
  const _CartPanelRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: AppText.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(formatRupiah(item.lineTotal), style: AppText.money),
            ],
          ),
        ),
        Text('x${item.qty}', style: AppText.label),
      ],
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.chip,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? AppColors.textOnDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
