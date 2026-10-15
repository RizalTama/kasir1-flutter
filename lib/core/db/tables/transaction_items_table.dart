import 'package:drift/drift.dart';
import 'products_table.dart';
import 'transactions_table.dart';

@TableIndex(
  name: 'idx_transaction_items_transaction_id',
  columns: {#transactionId},
)
class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(Transactions, #id)();
  IntColumn get productId =>
      integer().nullable().references(Products, #id)();
  TextColumn get productName => text()(); // snapshot
  IntColumn get unitPrice => integer()(); // snapshot
  IntColumn get qty => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get lineTotal => integer()();
}
