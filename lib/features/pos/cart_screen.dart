import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/cart_item_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/total_card.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) async {
    final controller = TextEditingController(text: item.note);
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.productName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'mis. Less sugar'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (note == null) return;
    ref.read(cartProvider.notifier).setNote(item.productId, note);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.keranjang),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clear(),
              child: const Text(
                AppStrings.hapusSemua,
                style: TextStyle(color: AppColors.navy),
              ),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Keranjang masih kosong',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 28),
              itemBuilder: (context, i) {
                final item = items[i];
                return CartItemTile(
                  imagePath: item.imagePath,
                  name: item.productName,
                  note: item.note,
                  qty: item.qty,
                  lineTotal: item.lineTotal,
                  onIncrement: () =>
                      ref.read(cartProvider.notifier).increment(item.productId),
                  onDecrement: () =>
                      ref.read(cartProvider.notifier).decrement(item.productId),
                  onEditNote: () => _editNote(context, ref, item),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TotalCard(label: AppStrings.totalTagihan, amount: total),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: AppStrings.lanjutBayar,
                      onPressed: () => context.push('/pos/checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
