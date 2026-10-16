import 'dart:convert';

import 'package:astron_kasir/features/receipt/receipt_builder.dart';
import 'package:astron_kasir/features/receipt/receipt_data.dart';
import 'package:flutter_test/flutter_test.dart';

ReceiptData _sample() {
  return ReceiptData(
    storeName: 'Kedai Senja',
    storeAddress: 'Jl. Melati No. 12',
    receiptFooter: 'Terima kasih!',
    trxCode: 'TRX-00128',
    createdAt: DateTime(2026, 10, 14, 12, 30),
    items: const [
      ReceiptItem(name: 'Kopi Susu', qty: 2, unitPrice: 18000, lineTotal: 36000),
    ],
    total: 36000,
    paymentMethod: 'cash',
    amountPaid: 50000,
    changeAmount: 14000,
  );
}

void main() {
  group('ReceiptBuilder.toBytes', () {
    test('menghasilkan byte ESC/POS non-kosong untuk 58mm & 80mm', () {
      expect(ReceiptBuilder.toBytes(_sample(), 58), isNotEmpty);
      expect(ReceiptBuilder.toBytes(_sample(), 80), isNotEmpty);
    });

    test('byte diawali perintah inisialisasi ESC @ (0x1B 0x40)', () {
      final bytes = ReceiptBuilder.toBytes(_sample(), 58);
      expect(bytes.take(2), [0x1B, 0x40]);
    });

    test('byte diakhiri perintah potong kertas GS V 0', () {
      final bytes = ReceiptBuilder.toBytes(_sample(), 58);
      expect(bytes.sublist(bytes.length - 3), [0x1D, 0x56, 0x00]);
    });

    test('teks dapat didekode kembali dan memuat isi struk', () {
      final bytes = ReceiptBuilder.toBytes(_sample(), 58);
      final decoded = latin1.decode(bytes, allowInvalid: true);
      expect(decoded, contains('KEDAI SENJA'));
      expect(decoded, contains('TRX-00128'));
      expect(decoded, contains('36.000'));
    });

    test('tidak crash walau nama produk/catatan berisi emoji di luar Latin-1', () {
      final data = ReceiptData(
        storeName: 'Kedai Senja ☕',
        storeAddress: 'Jl. Melati No. 12',
        receiptFooter: 'Terima kasih! 🙏',
        trxCode: 'TRX-00001',
        createdAt: DateTime(2026, 10, 14, 12, 30),
        items: const [
          ReceiptItem(
            name: 'Kopi Susu ☕',
            qty: 1,
            unitPrice: 18000,
            lineTotal: 18000,
            note: 'Less sugar 😊',
          ),
        ],
        total: 18000,
        paymentMethod: 'cash',
        amountPaid: 20000,
        changeAmount: 2000,
      );

      expect(() => ReceiptBuilder.toBytes(data, 58), returnsNormally);
      expect(ReceiptBuilder.toBytes(data, 58), isNotEmpty);
    });
  });
}
