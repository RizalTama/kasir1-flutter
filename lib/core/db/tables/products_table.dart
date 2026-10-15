import 'package:drift/drift.dart';
import 'categories_table.dart';

@TableIndex(name: 'idx_products_category_active', columns: {#categoryId, #isActive})
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get price => integer()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
