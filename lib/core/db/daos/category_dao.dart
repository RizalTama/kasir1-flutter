import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAll() {
    return (select(
      categories,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<List<Category>> getAll() {
    return (select(
      categories,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  Future<int> insertCategory(String name) async {
    final maxOrder = await _maxSortOrder();
    return into(categories).insert(
      CategoriesCompanion.insert(name: name, sortOrder: Value(maxOrder + 1)),
    );
  }

  Future<void> renameCategory(int id, String name) {
    return (update(
      categories,
    )..where((t) => t.id.equals(id))).write(CategoriesCompanion(name: Value(name)));
  }

  /// Simpan urutan baru sesuai posisi [orderedIds] (indeks 0 = sortOrder 0).
  Future<void> reorder(List<int> orderedIds) {
    return transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(
          categories,
        )..where((t) => t.id.equals(orderedIds[i]))).write(
          CategoriesCompanion(sortOrder: Value(i)),
        );
      }
    });
  }

  Future<int> deleteCategory(int id) {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future<int> _maxSortOrder() async {
    final maxExp = categories.sortOrder.max();
    final query = selectOnly(categories)..addColumns([maxExp]);
    final row = await query.getSingle();
    return row.read(maxExp) ?? -1;
  }
}
