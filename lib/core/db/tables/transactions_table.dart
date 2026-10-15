import 'package:drift/drift.dart';

@TableIndex(name: 'idx_transactions_created_at', columns: {#createdAt})
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()(); // TRX-00001
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get total => integer()();
  TextColumn get paymentMethod => text()(); // 'cash' | 'qris'
  IntColumn get amountPaid => integer()();
  IntColumn get changeAmount => integer()();
  IntColumn get itemCount => integer()();
}
