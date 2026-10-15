import 'package:astron_kasir/core/utils/trx_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatTrxCode', () {
    test('pads to 5 digits', () {
      expect(formatTrxCode(1), 'TRX-00001');
      expect(formatTrxCode(128), 'TRX-00128');
    });

    test('handles numbers beyond 5 digits without truncation', () {
      expect(formatTrxCode(123456), 'TRX-123456');
    });
  });
}
