import 'package:astron_kasir/core/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> insertProduct(
    String name, {
    int price = 10000,
    int? categoryId,
  }) {
    return db.productDao.insertProduct(
      ProductsCompanion.insert(
        name: name,
        price: price,
        categoryId: Value(categoryId),
      ),
    );
  }

  group('ProductDao', () {
    test('watchActive only returns active products, ordered by name', () async {
      await insertProduct('Nasi Goreng');
      await insertProduct('Es Teh');

      final list = await db.productDao.watchActive().first;
      expect(list.map((p) => p.name), ['Es Teh', 'Nasi Goreng']);
    });

    test('watchActive filters case-insensitively by query', () async {
      await insertProduct('Kopi Susu');
      await insertProduct('Es Teh');

      final list = await db.productDao.watchActive(query: 'KOPI').first;
      expect(list.map((p) => p.name), ['Kopi Susu']);
    });

    test('watchActive filters by categoryId', () async {
      final catId = await db.categoryDao.insertCategory('Minuman');
      await insertProduct('Kopi Susu', categoryId: catId);
      await insertProduct('Nasi Goreng');

      final list = await db.productDao.watchActive(categoryId: catId).first;
      expect(list.map((p) => p.name), ['Kopi Susu']);
    });

    test('softDelete hides product from watchActive but keeps the row', () async {
      final id = await insertProduct('Kopi Susu');
      await db.productDao.softDelete(id);

      expect(await db.productDao.watchActive().first, isEmpty);
      final stillThere = await db.productDao.getById(id);
      expect(stillThere, isNotNull);
      expect(stillThere!.isActive, isFalse);
    });

    test('countInCategory counts active and inactive products', () async {
      final catId = await db.categoryDao.insertCategory('Minuman');
      final p1 = await insertProduct('Kopi Susu', categoryId: catId);
      await insertProduct('Es Teh', categoryId: catId);
      await db.productDao.softDelete(p1);

      expect(await db.productDao.countInCategory(catId), 2);
    });

    test('countInCategory returns 0 for category with no products', () async {
      final catId = await db.categoryDao.insertCategory('Minuman');
      expect(await db.productDao.countInCategory(catId), 0);
    });

    test('updateProduct persists changed fields', () async {
      final id = await insertProduct('Kopi Susu', price: 15000);
      final product = await db.productDao.getById(id);

      await db.productDao.updateProduct(
        product!.toCompanion(true).copyWith(price: const Value(18000)),
      );

      final updated = await db.productDao.getById(id);
      expect(updated!.price, 18000);
    });
  });
}
