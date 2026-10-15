import 'package:drift/drift.dart';

/// Baris tunggal (id selalu 1) berisi pengaturan toko.
class StoreSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get storeName => text().withDefault(const Constant(''))();
  TextColumn get storeAddress => text().withDefault(const Constant(''))();
  TextColumn get receiptFooter =>
      text().withDefault(const Constant('Terima kasih!'))();
  TextColumn get qrisImagePath => text().nullable()();
  TextColumn get printerName => text().nullable()();
  TextColumn get printerAddress => text().nullable()();
  IntColumn get paperWidthMm => integer().withDefault(const Constant(58))();
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();
  IntColumn get lastTrxNumber => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
