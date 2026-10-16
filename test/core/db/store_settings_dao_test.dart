import 'package:astron_kasir/core/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('StoreSettingsDao', () {
    test('a single row is seeded on database creation', () async {
      final settings = await db.storeSettingsDao.get();
      expect(settings.id, 1);
      expect(settings.onboardingDone, isFalse);
      expect(settings.paperWidthMm, 58);
      expect(settings.lastTrxNumber, 0);
      expect(settings.receiptFooter, 'Terima kasih!');
    });

    test('save() only overwrites the given fields', () async {
      await db.storeSettingsDao.save(
        const StoreSettingsCompanion(storeName: Value('Kedai Senja')),
      );
      await db.storeSettingsDao.save(
        const StoreSettingsCompanion(storeAddress: Value('Jl. Melati No. 12')),
      );

      final settings = await db.storeSettingsDao.get();
      expect(settings.storeName, 'Kedai Senja');
      expect(settings.storeAddress, 'Jl. Melati No. 12');
    });

    test('watch() emits a new value after save()', () async {
      final values = <bool>[];
      final sub = db.storeSettingsDao.watch().listen(
        (s) => values.add(s.onboardingDone),
      );
      await Future.delayed(Duration.zero); // biarkan emisi awal diterima
      await db.storeSettingsDao.save(
        const StoreSettingsCompanion(onboardingDone: Value(true)),
      );
      await Future.delayed(Duration.zero);
      await sub.cancel();

      expect(values, [false, true]);
    });
  });
}
