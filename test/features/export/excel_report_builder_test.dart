import 'package:astron_kasir/core/db/app_database.dart';
import 'package:astron_kasir/core/db/daos/report_dao.dart';
import 'package:astron_kasir/features/export/excel_report_builder.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<Transaction> seedTransaction() async {
    final trxId = await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            code: 'TRX-00001',
            createdAt: Value(DateTime(2026, 10, 14, 12, 30)),
            total: 36000,
            paymentMethod: 'cash',
            amountPaid: 50000,
            changeAmount: 14000,
            itemCount: 1,
          ),
        );
    await db
        .into(db.transactionItems)
        .insert(
          TransactionItemsCompanion.insert(
            transactionId: trxId,
            productName: 'Kopi Susu',
            unitPrice: 18000,
            qty: 2,
            lineTotal: 36000,
          ),
        );
    return (db.select(
      db.transactions,
    )..where((t) => t.id.equals(trxId))).getSingle();
  }

  test('build() hanya menyertakan sheet yang dicentang', () {
    final transactions = <Transaction>[];
    const productRecap = <TopProduct>[];
    const paymentRecap = <PaymentMethodSummary>[];

    final excel = ExcelReportBuilder.build(
      options: const ExcelReportOptions(
        includeTransactions: true,
        includeProductRecap: false,
        includePaymentRecap: false,
      ),
      transactions: transactions,
      productRecap: productRecap,
      paymentRecap: paymentRecap,
    );

    expect(excel.tables.keys, ['Transaksi']);
  });

  test('sheet Transaksi berisi header, baris data, dan baris TOTAL', () async {
    final trx = await seedTransaction();

    final excel = ExcelReportBuilder.build(
      options: const ExcelReportOptions(),
      transactions: [trx],
      productRecap: const [
        TopProduct(productName: 'Kopi Susu', qtySold: 2, totalSales: 36000),
      ],
      paymentRecap: const [
        PaymentMethodSummary(method: 'cash', count: 1, total: 36000),
      ],
    );

    expect(excel.tables.keys, containsAll(['Transaksi', 'Per Produk', 'Metode Bayar']));

    final sheet = excel.tables['Transaksi']!;
    expect(sheet.maxRows, 3); // header + 1 transaksi + TOTAL
    expect(
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value,
      TextCellValue('No'),
    );
    expect(
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value,
      TextCellValue('TRX-00001'),
    );
    expect(
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value,
      TextCellValue('TOTAL'),
    );
  });

  test('bytes bisa di-encode (file .xlsx valid)', () async {
    final trx = await seedTransaction();
    final excel = ExcelReportBuilder.build(
      options: const ExcelReportOptions(),
      transactions: [trx],
      productRecap: const [],
      paymentRecap: const [],
    );
    final bytes = excel.encode();
    expect(bytes, isNotNull);
    expect(bytes!, isNotEmpty);
  });
}
