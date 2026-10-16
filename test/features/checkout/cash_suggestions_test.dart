import 'package:astron_kasir/features/checkout/cash_suggestions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cashSuggestions', () {
    test('matches the spec example: 56.000 -> pas, 60.000, 100.000', () {
      expect(cashSuggestions(56000), [56000, 60000, 100000]);
    });

    test('always starts with the exact total ("Uang pas")', () {
      expect(cashSuggestions(12345).first, 12345);
    });

    test('returns 3 distinct suggestions, each greater than total', () {
      final result = cashSuggestions(23000);
      expect(result.toSet().length, 3);
      expect(result[1], greaterThan(23000));
      expect(result[2], greaterThan(result[1]));
    });

    test('exact multiple of a denomination still rounds strictly above', () {
      final result = cashSuggestions(50000);
      expect(result, [50000, 55000, 60000]);
    });

    test('small totals round through the smallest denomination first', () {
      final result = cashSuggestions(3000);
      expect(result, [3000, 5000, 10000]);
    });
  });
}
