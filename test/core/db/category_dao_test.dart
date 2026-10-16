import 'package:astron_kasir/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('CategoryDao', () {
    test('insertCategory assigns incrementing sortOrder automatically', () async {
      final id1 = await db.categoryDao.insertCategory('Minuman');
      final id2 = await db.categoryDao.insertCategory('Makanan');

      final all = await db.categoryDao.getAll();
      expect(all.map((c) => c.id), [id1, id2]);
      expect(all.map((c) => c.sortOrder), [0, 1]);
    });

    test('insertCategory rejects duplicate name (unique constraint)', () async {
      await db.categoryDao.insertCategory('Minuman');
      expect(
        () => db.categoryDao.insertCategory('Minuman'),
        throwsA(anything),
      );
    });

    test('renameCategory updates name without touching sortOrder', () async {
      final id = await db.categoryDao.insertCategory('Minuman');
      await db.categoryDao.renameCategory(id, 'Minuman Dingin');

      final all = await db.categoryDao.getAll();
      expect(all.single.name, 'Minuman Dingin');
      expect(all.single.sortOrder, 0);
    });

    test('reorder persists new sortOrder per given order', () async {
      final a = await db.categoryDao.insertCategory('A');
      final b = await db.categoryDao.insertCategory('B');
      final c = await db.categoryDao.insertCategory('C');

      await db.categoryDao.reorder([c, a, b]);

      final all = await db.categoryDao.getAll();
      expect(all.map((cat) => cat.id), [c, a, b]);
    });

    test('deleteCategory removes the row', () async {
      final id = await db.categoryDao.insertCategory('Minuman');
      await db.categoryDao.deleteCategory(id);
      expect(await db.categoryDao.getAll(), isEmpty);
    });

    test('watchAll emits updates when a category is added', () async {
      expectLater(
        db.categoryDao.watchAll().map((list) => list.length),
        emitsInOrder([0, 1]),
      );
      await db.categoryDao.insertCategory('Minuman');
    });
  });
}
