import 'package:astron_kasir/core/utils/date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 16, 14, 30);

  group('resolveDateRange', () {
    test('today covers 00:00 to 23:59:59.999', () {
      final r = resolveDateRange(ReportPeriod.today, now: now);
      expect(r.start, DateTime(2026, 10, 16));
      expect(r.end, DateTime(2026, 10, 16, 23, 59, 59, 999));
    });

    test('last7Days includes today and 6 days before', () {
      final r = resolveDateRange(ReportPeriod.last7Days, now: now);
      expect(r.start, DateTime(2026, 10, 10));
      expect(r.end, DateTime(2026, 10, 16, 23, 59, 59, 999));
    });

    test('thisMonth starts on the 1st through today', () {
      final r = resolveDateRange(ReportPeriod.thisMonth, now: now);
      expect(r.start, DateTime(2026, 10, 1));
      expect(r.end, DateTime(2026, 10, 16, 23, 59, 59, 999));
    });

    test('custom range is inclusive of both end dates', () {
      final r = resolveDateRange(
        ReportPeriod.custom,
        now: now,
        customStart: DateTime(2026, 10, 1),
        customEnd: DateTime(2026, 10, 7),
      );
      expect(r.start, DateTime(2026, 10, 1));
      expect(r.end, DateTime(2026, 10, 7, 23, 59, 59, 999));
    });

    test('custom range throws without start/end', () {
      expect(
        () => resolveDateRange(ReportPeriod.custom, now: now),
        throwsArgumentError,
      );
    });
  });
}
