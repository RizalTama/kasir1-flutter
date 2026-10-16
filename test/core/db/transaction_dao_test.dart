import 'package:astron_kasir/core/db/app_database.dart';
import 'package:astron_kasir/core/db/daos/transaction_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('TransactionDao.saveTransaction', () {
    test('first transaction gets code TRX-00001', () async {
      final trx = await db.transactionDao.saveTransaction(
        items: [
          NewTransactionItem(
            productId: null,
            productName: 'Kopi Susu',
            unitPrice: 18000,
            qty: 2,
          ),
        ],
        paymentMethod: 'cash',
        amountPaid: 50000,
      );

      expect(trx.code, 'TRX-00001');
      expect(trx.total, 36000);
      expect(trx.amountPaid, 50000);
      expect(trx.changeAmount, 14000);
      expect(trx.itemCount, 1);
    });

    test('trx code increments sequentially across calls', () async {
      final items = [
        NewTransactionItem(
          productId: null,
          productName: 'Es Teh',
          unitPrice: 8000,
          qty: 1,
        ),
      ];
      final first = await db.transactionDao.saveTransaction(
        items: items,
        paymentMethod: 'cash',
        amountPaid: 8000,
      );
      final second = await db.transactionDao.saveTransaction(
        items: items,
        paymentMethod: 'cash',
        amountPaid: 8000,
      );

      expect(first.code, 'TRX-00001');
      expect(second.code, 'TRX-00002');
    });

    test('QRIS payment sets amountPaid = total and changeAmount = 0', () async {
      final trx = await db.transactionDao.saveTransaction(
        items: [
          NewTransactionItem(
            productId: null,
            productName: 'Kopi Susu',
            unitPrice: 18000,
            qty: 1,
          ),
        ],
        paymentMethod: 'qris',
        amountPaid: 18000,
      );

      expect(trx.amountPaid, 18000);
      expect(trx.changeAmount, 0);
    });

    test('persists item snapshots (name/price) and note', () async {
      final trx = await db.transactionDao.saveTransaction(
        items: [
          NewTransactionItem(
            productId: 42,
            productName: 'Kopi Susu',
            unitPrice: 18000,
            qty: 2,
            note: 'Less sugar',
          ),
        ],
        paymentMethod: 'cash',
        amountPaid: 40000,
      );

      final items = await db.transactionDao.getItems(trx.id);
      expect(items.single.productId, 42);
      expect(items.single.productName, 'Kopi Susu');
      expect(items.single.unitPrice, 18000);
      expect(items.single.qty, 2);
      expect(items.single.note, 'Less sugar');
      expect(items.single.lineTotal, 36000);
    });

    test('total is the sum of all line totals across multiple items', () async {
      final trx = await db.transactionDao.saveTransaction(
        items: [
          NewTransactionItem(
            productId: null,
            productName: 'Kopi Susu',
            unitPrice: 18000,
            qty: 2,
          ),
          NewTransactionItem(
            productId: null,
            productName: 'Roti Bakar',
            unitPrice: 15000,
            qty: 1,
          ),
        ],
        paymentMethod: 'cash',
        amountPaid: 100000,
      );

      expect(trx.total, 51000);
      expect(trx.itemCount, 2);
    });

    test('getById returns null for a non-existent id', () async {
      expect(await db.transactionDao.getById(999), isNull);
    });
  });
}
