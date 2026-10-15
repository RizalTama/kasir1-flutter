import 'package:astron_kasir/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupiah', () {
    test('formats thousands with dot separator', () {
      expect(formatRupiah(56000), 'Rp56.000');
    });

    test('formats zero', () {
      expect(formatRupiah(0), 'Rp0');
    });

    test('formats millions', () {
      expect(formatRupiah(1250000), 'Rp1.250.000');
    });

    test('formats small amounts without separator', () {
      expect(formatRupiah(500), 'Rp500');
    });
  });
}
