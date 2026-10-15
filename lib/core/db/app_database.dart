import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/category_dao.dart';
import 'daos/product_dao.dart';
import 'daos/store_settings_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/store_settings_table.dart';
import 'tables/transaction_items_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Products,
    Transactions,
    TransactionItems,
    StoreSettings,
  ],
  daos: [CategoryDao, ProductDao, TransactionDao, StoreSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(storeSettings).insert(
        const StoreSettingsCompanion(id: Value(1)),
      );
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'astron_kasir');
  }
}
