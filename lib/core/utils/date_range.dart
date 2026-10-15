/// Periode filter laporan (§6.4 Claude.md).
enum ReportPeriod { today, last7Days, thisMonth, custom }

/// Rentang tanggal inklusif, dihitung di zona waktu lokal perangkat.
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// Hitung [DateRange] untuk [period] relatif terhadap [now] (default:
/// waktu lokal saat ini). Untuk [ReportPeriod.custom], wajib isi
/// [customStart] dan [customEnd].
DateRange resolveDateRange(
  ReportPeriod period, {
  DateTime? now,
  DateTime? customStart,
  DateTime? customEnd,
}) {
  final today = now ?? DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final endOfToday = startOfToday
      .add(const Duration(days: 1))
      .subtract(const Duration(milliseconds: 1));

  switch (period) {
    case ReportPeriod.today:
      return DateRange(startOfToday, endOfToday);
    case ReportPeriod.last7Days:
      return DateRange(
        startOfToday.subtract(const Duration(days: 6)),
        endOfToday,
      );
    case ReportPeriod.thisMonth:
      return DateRange(DateTime(today.year, today.month, 1), endOfToday);
    case ReportPeriod.custom:
      if (customStart == null || customEnd == null) {
        throw ArgumentError(
          'customStart dan customEnd wajib diisi untuk ReportPeriod.custom',
        );
      }
      final start = DateTime(
        customStart.year,
        customStart.month,
        customStart.day,
      );
      final end = DateTime(customEnd.year, customEnd.month, customEnd.day)
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));
      return DateRange(start, end);
  }
}
