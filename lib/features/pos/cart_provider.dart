import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.imagePath,
    required this.qty,
    this.note,
  });

  final int productId;
  final String productName;
  final int unitPrice;
  final String? imagePath;
  final int qty;
  final String? note;

  int get lineTotal => unitPrice * qty;

  CartItem copyWith({int? qty, String? note}) {
    return CartItem(
      productId: productId,
      productName: productName,
      unitPrice: unitPrice,
      imagePath: imagePath,
      qty: qty ?? this.qty,
      note: note ?? this.note,
    );
  }
}

/// Keranjang: state in-memory (§5 Claude.md), baru ditulis ke DB saat
/// transaksi selesai.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  void addProduct(Product product) {
    final index = state.indexWhere((i) => i.productId == product.id);
    if (index == -1) {
      state = [
        ...state,
        CartItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          imagePath: product.imagePath,
          qty: 1,
        ),
      ];
      return;
    }
    _updateAt(index, state[index].copyWith(qty: state[index].qty + 1));
  }

  void increment(int productId) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index == -1) return;
    _updateAt(index, state[index].copyWith(qty: state[index].qty + 1));
  }

  void decrement(int productId) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index == -1) return;
    final item = state[index];
    if (item.qty <= 1) {
      removeItem(productId);
      return;
    }
    _updateAt(index, item.copyWith(qty: item.qty - 1));
  }

  void setNote(int productId, String? note) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index == -1) return;
    final trimmed = note?.trim();
    _updateAt(
      index,
      state[index].copyWith(note: (trimmed == null || trimmed.isEmpty) ? '' : trimmed),
    );
  }

  void removeItem(int productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void clear() {
    state = const [];
  }

  void _updateAt(int index, CartItem updated) {
    final next = [...state];
    next[index] = updated;
    state = next;
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(0, (sum, i) => sum + i.lineTotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(0, (sum, i) => sum + i.qty);
});

final cartQtyForProductProvider = Provider.family<int, int>((ref, productId) {
  final items = ref.watch(cartProvider);
  final item = items.where((i) => i.productId == productId);
  return item.isEmpty ? 0 : item.first.qty;
});
