import 'package:drift/drift.dart';
import '../../utils/date_range.dart';
import '../app_database.dart';
import '../tables/transaction_items_table.dart';
import '../tables/transactions_table.dart';

part 'report_dao.g.dart';

class ReportSummary {
  const ReportSummary({
    required this.totalSales,
    required this.transactionCount,
  });

  final int totalSales;
  final int transactionCount;

  /// Dibulatkan ke bawah; 0 kalau tidak ada transaksi (§6.4).
  int get average =>
      transactionCount == 0 ? 0 : totalSales ~/ transactionCount;
}

class DailySales {
  const DailySales({required this.date, required this.total});

  final DateTime date;
  final int total;
}

class PaymentMethodSummary {
  const PaymentMethodSummary({
    required this.method,
    required this.count,
    required this.total,
  });

  final String method;
  final int count;
  final int total;
}

class TopProduct {
  const TopProduct({
    required this.productName,
    required this.qtySold,
    required this.totalSales,
  });

  final String productName;
  final int qtySold;
  final int totalSales;
}

@DriftAccessor(tables: [Transactions, TransactionItems])
class ReportDao extends DatabaseAccessor<AppDatabase> with _$ReportDaoMixin {
  ReportDao(super.db);

  Expression<bool> _inRange(DateRange range) {
    return transactions.createdAt.isBetweenValues(range.start, range.end);
  }

  Future<ReportSummary> getSummary(DateRange range) async {
    final totalExp = transactions.total.sum();
    final countExp = transactions.id.count();
    final query = selectOnly(transactions)
      ..addColumns([totalExp, countExp])
      ..where(_inRange(range));
    final row = await query.getSingle();
    return ReportSummary(
      totalSales: row.read(totalExp) ?? 0,
      transactionCount: row.read(countExp) ?? 0,
    );
  }

  /// Dikelompokkan per hari kalender lokal. Pengelompokan dilakukan di DAO
  /// (bukan loop di UI, §5) — setelah query dasar terfilter rentang waktu.
  Future<List<DailySales>> getDailySales(DateRange range) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.createdAt, transactions.total])
      ..where(_inRange(range))
      ..orderBy([OrderingTerm.asc(transactions.createdAt)]);
    final rows = await query.get();

    final byDay = <DateTime, int>{};
    for (final row in rows) {
      final createdAt = row.read(transactions.createdAt)!;
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      byDay[day] = (byDay[day] ?? 0) + row.read(transactions.total)!;
    }
    final result = [
      for (final entry in byDay.entries)
        DailySales(date: entry.key, total: entry.value),
    ];
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  Future<List<PaymentMethodSummary>> getPaymentMethodBreakdown(
    DateRange range,
  ) async {
    final countExp = transactions.id.count();
    final totalExp = transactions.total.sum();
    final query = selectOnly(transactions)
      ..addColumns([transactions.paymentMethod, countExp, totalExp])
      ..where(_inRange(range))
      ..groupBy([transactions.paymentMethod]);
    final rows = await query.get();
    return [
      for (final row in rows)
        PaymentMethodSummary(
          method: row.read(transactions.paymentMethod)!,
          count: row.read(countExp) ?? 0,
          total: row.read(totalExp) ?? 0,
        ),
    ];
  }

  Future<List<TopProduct>> getTopProducts(DateRange range, {int? limit}) async {
    final qtyExp = transactionItems.qty.sum();
    final totalExp = transactionItems.lineTotal.sum();
    final query =
        selectOnly(transactionItems).join([
            innerJoin(
              transactions,
              transactions.id.equalsExp(transactionItems.transactionId),
            ),
          ])
          ..addColumns([transactionItems.productName, qtyExp, totalExp])
          ..where(_inRange(range))
          ..groupBy([transactionItems.productName])
          ..orderBy([OrderingTerm.desc(qtyExp)]);
    if (limit != null) query.limit(limit);
    final rows = await query.get();
    return [
      for (final row in rows)
        TopProduct(
          productName: row.read(transactionItems.productName)!,
          qtySold: row.read(qtyExp) ?? 0,
          totalSales: row.read(totalExp) ?? 0,
        ),
    ];
  }

  /// Transaksi mentah dalam rentang, dipakai sheet "Transaksi" Export Excel.
  Future<List<Transaction>> getTransactionsInRange(DateRange range) {
    return (select(transactions)
          ..where((t) => t.createdAt.isBetweenValues(range.start, range.end))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }
}
