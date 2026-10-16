import 'package:astron_kasir/core/db/app_database.dart';
import 'package:astron_kasir/core/utils/date_range.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> seedTransaction({
    required String code,
    required DateTime createdAt,
    required int total,
    required String paymentMethod,
    required List<(String name, int qty, int unitPrice)> items,
  }) async {
    final trxId = await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            code: code,
            createdAt: Value(createdAt),
            total: total,
            paymentMethod: paymentMethod,
            amountPaid: total,
            changeAmount: 0,
            itemCount: items.length,
          ),
        );
    for (final (name, qty, unitPrice) in items) {
      await db
          .into(db.transactionItems)
          .insert(
            TransactionItemsCompanion.insert(
              transactionId: trxId,
              productName: name,
              unitPrice: unitPrice,
              qty: qty,
              lineTotal: unitPrice * qty,
            ),
          );
    }
  }

  group('ReportDao', () {
    test('getSummary sums total & counts transactions within range', () async {
      await seedTransaction(
        code: 'TRX-00001',
        createdAt: DateTime(2026, 10, 14, 9),
        total: 20000,
        paymentMethod: 'cash',
        items: [('Kopi Susu', 1, 20000)],
      );
      await seedTransaction(
        code: 'TRX-00002',
        createdAt: DateTime(2026, 10, 14, 15),
        total: 30000,
        paymentMethod: 'qris',
        items: [('Roti Bakar', 2, 15000)],
      );
      // Di luar rentang -> tidak ikut terhitung.
      await seedTransaction(
        code: 'TRX-00003',
        createdAt: DateTime(2026, 10, 20),
        total: 99000,
        paymentMethod: 'cash',
        items: [('Nasi Goreng', 1, 99000)],
      );

      final range = resolveDateRange(
        ReportPeriod.custom,
        customStart: DateTime(2026, 10, 14),
        customEnd: DateTime(2026, 10, 14),
      );
      final summary = await db.reportDao.getSummary(range);

      expect(summary.totalSales, 50000);
      expect(summary.transactionCount, 2);
      expect(summary.average, 25000);
    });

    test('getSummary average is 0 when there are no transactions', () async {
      final range = resolveDateRange(ReportPeriod.today);
      final summary = await db.reportDao.getSummary(range);
      expect(summary.totalSales, 0);
      expect(summary.transactionCount, 0);
      expect(summary.average, 0);
    });

    test('getDailySales groups totals per local calendar day', () async {
      await seedTransaction(
        code: 'TRX-00001',
        createdAt: DateTime(2026, 10, 14, 9),
        total: 10000,
        paymentMethod: 'cash',
        items: [('A', 1, 10000)],
      );
      await seedTransaction(
        code: 'TRX-00002',
        createdAt: DateTime(2026, 10, 14, 20),
        total: 5000,
        paymentMethod: 'cash',
        items: [('A', 1, 5000)],
      );
      await seedTransaction(
        code: 'TRX-00003',
        createdAt: DateTime(2026, 10, 15, 9),
        total: 7000,
        paymentMethod: 'qris',
        items: [('B', 1, 7000)],
      );

      final range = resolveDateRange(
        ReportPeriod.custom,
        customStart: DateTime(2026, 10, 14),
        customEnd: DateTime(2026, 10, 15),
      );
      final daily = await db.reportDao.getDailySales(range);

      expect(daily.length, 2);
      expect(daily[0].date, DateTime(2026, 10, 14));
      expect(daily[0].total, 15000);
      expect(daily[1].date, DateTime(2026, 10, 15));
      expect(daily[1].total, 7000);
    });

    test('getPaymentMethodBreakdown groups by method', () async {
      await seedTransaction(
        code: 'TRX-00001',
        createdAt: DateTime(2026, 10, 14),
        total: 10000,
        paymentMethod: 'cash',
        items: [('A', 1, 10000)],
      );
      await seedTransaction(
        code: 'TRX-00002',
        createdAt: DateTime(2026, 10, 14),
        total: 30000,
        paymentMethod: 'qris',
        items: [('B', 1, 30000)],
      );

      final range = resolveDateRange(
        ReportPeriod.custom,
        customStart: DateTime(2026, 10, 14),
        customEnd: DateTime(2026, 10, 14),
      );
      final breakdown = await db.reportDao.getPaymentMethodBreakdown(range);

      final cash = breakdown.firstWhere((b) => b.method == 'cash');
      final qris = breakdown.firstWhere((b) => b.method == 'qris');
      expect(cash.total, 10000);
      expect(cash.count, 1);
      expect(qris.total, 30000);
      expect(qris.count, 1);
    });

    test('getTopProducts sums qty across transactions, sorted desc', () async {
      await seedTransaction(
        code: 'TRX-00001',
        createdAt: DateTime(2026, 10, 14),
        total: 36000,
        paymentMethod: 'cash',
        items: [('Kopi Susu', 2, 18000)],
      );
      await seedTransaction(
        code: 'TRX-00002',
        createdAt: DateTime(2026, 10, 14),
        total: 18000 + 15000,
        paymentMethod: 'cash',
        items: [('Kopi Susu', 1, 18000), ('Roti Bakar', 1, 15000)],
      );

      final range = resolveDateRange(
        ReportPeriod.custom,
        customStart: DateTime(2026, 10, 14),
        customEnd: DateTime(2026, 10, 14),
      );
      final top = await db.reportDao.getTopProducts(range);

      expect(top.first.productName, 'Kopi Susu');
      expect(top.first.qtySold, 3);
      expect(top.first.totalSales, 54000);
      expect(top[1].productName, 'Roti Bakar');
      expect(top[1].qtySold, 1);
    });
  });
}
