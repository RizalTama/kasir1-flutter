import 'package:astron_kasir/features/receipt/receipt_builder.dart';
import 'package:astron_kasir/features/receipt/receipt_data.dart';
import 'package:flutter_test/flutter_test.dart';

ReceiptData _sampleCash() {
  return ReceiptData(
    storeName: 'Kedai Senja',
    storeAddress: 'Jl. Melati No. 12',
    receiptFooter: 'Terima kasih!',
    trxCode: 'TRX-00128',
    createdAt: DateTime(2026, 10, 14, 12, 30),
    items: const [
      ReceiptItem(
        name: 'Kopi Susu',
        qty: 2,
        unitPrice: 18000,
        lineTotal: 36000,
        note: 'Less sugar',
      ),
      ReceiptItem(name: 'Roti Bakar', qty: 1, unitPrice: 15000, lineTotal: 15000),
    ],
    total: 51000,
    paymentMethod: 'cash',
    amountPaid: 100000,
    changeAmount: 49000,
  );
}

void main() {
  group('ReceiptBuilder.buildLines + renderText (58mm / 32 kolom)', () {
    late String text;

    setUp(() {
      final lines = ReceiptBuilder.buildLines(_sampleCash());
      text = ReceiptBuilder.renderText(lines, 32);
    });

    test('header toko tercantum', () {
      expect(text, contains('KEDAI SENJA'));
      expect(text, contains('Jl. Melati No. 12'));
    });

    test('tanggal, jam, dan nomor transaksi tercantum', () {
      expect(text, contains('14/10/2026'));
      expect(text, contains('12:30'));
      expect(text, contains('No: TRX-00128'));
    });

    test('baris item, qty x harga, dan catatan sesuai urutan', () {
      final lines = text.split('\n');
      final kopiIdx = lines.indexWhere((l) => l.contains('Kopi Susu'));
      expect(kopiIdx, greaterThanOrEqualTo(0));
      expect(lines[kopiIdx + 1], contains('2 x 18.000'));
      expect(lines[kopiIdx + 1], contains('36.000'));
      expect(lines[kopiIdx + 2], contains('* Less sugar'));

      final rotiIdx = lines.indexWhere((l) => l.contains('Roti Bakar'));
      expect(lines[rotiIdx + 1], contains('1 x 15.000'));
      expect(lines[rotiIdx + 1], contains('15.000'));
    });

    test('total, tunai, kembali tercantum untuk pembayaran tunai', () {
      expect(text, contains('TOTAL'));
      expect(text, contains('51.000'));
      expect(text, contains('Tunai'));
      expect(text, contains('100.000'));
      expect(text, contains('Kembali'));
      expect(text, contains('49.000'));
    });

    test('teks kaki struk tercantum', () {
      expect(text, contains('Terima kasih!'));
    });

    test('baris dua kolom tidak melebihi lebar kolom', () {
      for (final line in text.split('\n')) {
        expect(line.length, lessThanOrEqualTo(32));
      }
    });
  });

  group('ReceiptBuilder untuk pembayaran QRIS', () {
    test('menampilkan "Metode QRIS" dan tanpa baris Kembali', () {
      final data = ReceiptData(
        storeName: 'Kedai Senja',
        storeAddress: '',
        receiptFooter: 'Terima kasih!',
        trxCode: 'TRX-00001',
        createdAt: DateTime(2026, 10, 14, 12, 30),
        items: const [
          ReceiptItem(name: 'Kopi Susu', qty: 1, unitPrice: 18000, lineTotal: 18000),
        ],
        total: 18000,
        paymentMethod: 'qris',
        amountPaid: 18000,
        changeAmount: 0,
      );
      final text = ReceiptBuilder.renderText(
        ReceiptBuilder.buildLines(data),
        32,
      );
      expect(text, contains('Metode QRIS'));
      expect(text, isNot(contains('Kembali')));
      expect(text, isNot(contains('Tunai')));
    });
  });

  group('ReceiptBuilder 80mm / 48 kolom', () {
    test('baris tidak melebihi 48 kolom', () {
      final text = ReceiptBuilder.renderText(
        ReceiptBuilder.buildLines(_sampleCash()),
        48,
      );
      for (final line in text.split('\n')) {
        expect(line.length, lessThanOrEqualTo(48));
      }
    });
  });
}
