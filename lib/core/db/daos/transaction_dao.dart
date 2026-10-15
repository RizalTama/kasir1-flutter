import 'package:drift/drift.dart';
import '../../utils/trx_code.dart';
import '../app_database.dart';
import '../tables/store_settings_table.dart';
import '../tables/transaction_items_table.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

class NewTransactionItem {
  NewTransactionItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.qty,
    this.note,
  });

  final int? productId;
  final String productName;
  final int unitPrice;
  final int qty;
  final String? note;

  int get lineTotal => unitPrice * qty;
}

@DriftAccessor(tables: [Transactions, TransactionItems, StoreSettings])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Simpan transaksi + item-nya dan naikkan nomor urut TRX, semua dalam
  /// satu DB transaction (lihat §6.2 Claude.md).
  Future<Transaction> saveTransaction({
    required List<NewTransactionItem> items,
    required String paymentMethod,
    required int amountPaid,
  }) {
    return transaction(() async {
      final settings = await (select(
        storeSettings,
      )..where((t) => t.id.equals(1))).getSingle();
      final nextNumber = settings.lastTrxNumber + 1;
      final code = formatTrxCode(nextNumber);

      final total = items.fold<int>(0, (sum, it) => sum + it.lineTotal);
      final changeAmount = paymentMethod == 'cash' ? amountPaid - total : 0;

      final trxId = await into(transactions).insert(
        TransactionsCompanion.insert(
          code: code,
          total: total,
          paymentMethod: paymentMethod,
          amountPaid: amountPaid,
          changeAmount: changeAmount,
          itemCount: items.length,
        ),
      );

      for (final item in items) {
        await into(transactionItems).insert(
          TransactionItemsCompanion.insert(
            transactionId: trxId,
            productId: Value(item.productId),
            productName: item.productName,
            unitPrice: item.unitPrice,
            qty: item.qty,
            note: Value(item.note),
            lineTotal: item.lineTotal,
          ),
        );
      }

      await (update(
        storeSettings,
      )..where((t) => t.id.equals(1))).write(
        StoreSettingsCompanion(lastTrxNumber: Value(nextNumber)),
      );

      return (select(
        transactions,
      )..where((t) => t.id.equals(trxId))).getSingle();
    });
  }

  Future<Transaction?> getById(int id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<TransactionItem>> getItems(int transactionId) {
    return (select(
      transactionItems,
    )..where((t) => t.transactionId.equals(transactionId))).get();
  }

  Stream<List<Transaction>> watchRecent({int limit = 50}) {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch();
  }
}
