import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';

class SelectedCategory extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategory, int?>(
  SelectedCategory.new,
);

class PosSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final posSearchQueryProvider = NotifierProvider<PosSearchQuery, String>(
  PosSearchQuery.new,
);

final posProductListProvider = StreamProvider<List<Product>>((ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(posSearchQueryProvider);
  return ref
      .watch(productDaoProvider)
      .watchActive(categoryId: categoryId, query: query);
});

/// Metode bayar yang dipilih dari panel pesanan (tablet) sebelum masuk ke
/// layar Pembayaran; dipakai sebagai tab awal di CheckoutScreen.
class CheckoutMethodSelection extends Notifier<String> {
  @override
  String build() => 'cash';

  void select(String method) => state = method;
}

final checkoutMethodProvider =
    NotifierProvider<CheckoutMethodSelection, String>(
      CheckoutMethodSelection.new,
    );
