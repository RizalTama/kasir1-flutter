import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/store_settings_table.dart';

part 'store_settings_dao.g.dart';

@DriftAccessor(tables: [StoreSettings])
class StoreSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$StoreSettingsDaoMixin {
  StoreSettingsDao(super.db);

  Stream<StoreSetting> watch() {
    return (select(
      storeSettings,
    )..where((t) => t.id.equals(1))).watchSingle();
  }

  Future<StoreSetting> get() {
    return (select(
      storeSettings,
    )..where((t) => t.id.equals(1))).getSingle();
  }

  Future<void> save(StoreSettingsCompanion entry) {
    return (update(
      storeSettings,
    )..where((t) => t.id.equals(1))).write(entry);
  }
}
