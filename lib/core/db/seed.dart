import 'package:drift/drift.dart';
import 'app_database.dart';

/// Isi data demo untuk mode debug saja (lihat milestone 2 Claude.md).
/// Tidak melakukan apa-apa kalau sudah ada kategori.
Future<void> seedDemoData(AppDatabase db) async {
  final existing = await db.categoryDao.getAll();
  if (existing.isNotEmpty) return;

  final minumanId = await db.categoryDao.insertCategory(
    CategoriesCompanion.insert(name: 'Minuman', sortOrder: Value(0)),
  );
  final makananId = await db.categoryDao.insertCategory(
    CategoriesCompanion.insert(name: 'Makanan', sortOrder: Value(1)),
  );

  final demoProducts = [
    (name: 'Kopi Susu', price: 18000, categoryId: minumanId),
    (name: 'Es Teh Manis', price: 8000, categoryId: minumanId),
    (name: 'Americano', price: 15000, categoryId: minumanId),
    (name: 'Roti Bakar', price: 15000, categoryId: makananId),
    (name: 'Nasi Goreng', price: 22000, categoryId: makananId),
  ];

  for (final p in demoProducts) {
    await db.productDao.insertProduct(
      ProductsCompanion.insert(
        name: p.name,
        price: p.price,
        categoryId: Value(p.categoryId),
      ),
    );
  }
}
