import 'package:astron_kasir/core/utils/date_range.dart';
import 'package:astron_kasir/features/export/period_file_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('periodFileLabel', () {
    test('matches spec example: 1-7 Oct 2026 -> 1-7Okt2026', () {
      final range = DateRange(DateTime(2026, 10, 1), DateTime(2026, 10, 7));
      expect(periodFileLabel(range), '1-7Okt2026');
    });

    test('single day range', () {
      final range = DateRange(DateTime(2026, 10, 14), DateTime(2026, 10, 14));
      expect(periodFileLabel(range), '14Okt2026');
    });

    test('spans two months in the same year', () {
      final range = DateRange(DateTime(2026, 9, 28), DateTime(2026, 10, 3));
      expect(periodFileLabel(range), '28Sep-3Okt2026');
    });

    test('spans two years', () {
      final range = DateRange(DateTime(2026, 12, 28), DateTime(2027, 1, 3));
      expect(periodFileLabel(range), '28Des2026-3Jan2027');
    });
  });
}
