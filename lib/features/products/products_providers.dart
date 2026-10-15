import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';

class ProductSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final productSearchQueryProvider = NotifierProvider<ProductSearchQuery, String>(
  ProductSearchQuery.new,
);

final productListProvider = StreamProvider<List<Product>>((ref) {
  final query = ref.watch(productSearchQueryProvider);
  return ref.watch(productDaoProvider).watchActive(query: query);
});

final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryDaoProvider).watchAll();
});
