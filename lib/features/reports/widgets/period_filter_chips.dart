import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_range.dart';
import '../../../core/widgets/category_chip.dart';
import '../reports_providers.dart';

/// Chip filter periode laporan: Hari ini / 7 hari terakhir / Bulan ini /
/// Pilih tanggal (§6.4) — dipakai di Laporan & Export Excel.
class PeriodFilterChips extends ConsumerWidget {
  const PeriodFilterChips({super.key});

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      ),
    );
    if (picked == null) return;
    ref.read(customDateRangeProvider.notifier).select(picked);
    ref.read(reportPeriodProvider.notifier).select(ReportPeriod.custom);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryChip(
            label: 'Hari ini',
            selected: period == ReportPeriod.today,
            onTap: () => ref
                .read(reportPeriodProvider.notifier)
                .select(ReportPeriod.today),
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: '7 hari terakhir',
            selected: period == ReportPeriod.last7Days,
            onTap: () => ref
                .read(reportPeriodProvider.notifier)
                .select(ReportPeriod.last7Days),
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Bulan ini',
            selected: period == ReportPeriod.thisMonth,
            onTap: () => ref
                .read(reportPeriodProvider.notifier)
                .select(ReportPeriod.thisMonth),
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Pilih tanggal',
            selected: period == ReportPeriod.custom,
            onTap: () => _pickCustomRange(context, ref),
          ),
        ],
      ),
    );
  }
}
