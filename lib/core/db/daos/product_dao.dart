import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase>
    with _$ProductDaoMixin {
  ProductDao(super.db);

  Stream<List<Product>> watchActive({int? categoryId, String? query}) {
    final stmt = select(products)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (categoryId != null) {
      stmt.where((t) => t.categoryId.equals(categoryId));
    }
    if (query != null && query.isNotEmpty) {
      stmt.where((t) => t.name.lower().contains(query.toLowerCase()));
    }
    return stmt.watch();
  }

  Future<Product?> getById(int id) {
    return (select(
      products,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertProduct(ProductsCompanion entry) {
    return into(products).insert(entry);
  }

  Future<bool> updateProduct(ProductsCompanion entry) {
    return update(products).replace(entry);
  }

  /// Soft delete: produk yang pernah terjual tidak boleh dihapus permanen.
  Future<int> softDelete(int id) {
    return (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Jumlah produk (aktif maupun tidak) yang masih terhubung ke kategori
  /// ini, dipakai validasi "hapus kategori hanya jika kosong".
  Future<int> countInCategory(int categoryId) async {
    final countExp = products.id.count();
    final query = selectOnly(products)
      ..addColumns([countExp])
      ..where(products.categoryId.equals(categoryId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }
}
