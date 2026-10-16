import '../../core/utils/date_range.dart';

const _monthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Label periode untuk nama file export, mis. `1-7Okt2026` (§6.5 Claude.md
/// contoh: `Laporan_1-7Okt2026.xlsx`).
String periodFileLabel(DateRange range) {
  final start = range.start;
  final end = range.end;

  if (start.year == end.year && start.month == end.month) {
    final month = _monthAbbr[start.month - 1];
    if (start.day == end.day) {
      return '${start.day}$month${start.year}';
    }
    return '${start.day}-${end.day}$month${start.year}';
  }
  if (start.year == end.year) {
    return '${start.day}${_monthAbbr[start.month - 1]}-'
        '${end.day}${_monthAbbr[end.month - 1]}${end.year}';
  }
  return '${start.day}${_monthAbbr[start.month - 1]}${start.year}-'
      '${end.day}${_monthAbbr[end.month - 1]}${end.year}';
}
