import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/daos/report_dao.dart';
import '../../core/db/providers.dart';
import '../../core/utils/date_range.dart';

class ReportPeriodSelection extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.today;

  void select(ReportPeriod period) => state = period;
}

final reportPeriodProvider =
    NotifierProvider<ReportPeriodSelection, ReportPeriod>(
      ReportPeriodSelection.new,
    );

class CustomDateRangeSelection extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void select(DateTimeRange range) => state = range;
}

final customDateRangeProvider =
    NotifierProvider<CustomDateRangeSelection, DateTimeRange?>(
      CustomDateRangeSelection.new,
    );

final currentDateRangeProvider = Provider<DateRange>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final custom = ref.watch(customDateRangeProvider);
  return resolveDateRange(
    period,
    customStart: custom?.start,
    customEnd: custom?.end,
  );
});

final reportSummaryProvider = FutureProvider<ReportSummary>((ref) {
  final range = ref.watch(currentDateRangeProvider);
  return ref.watch(reportDaoProvider).getSummary(range);
});

final dailySalesProvider = FutureProvider<List<DailySales>>((ref) {
  final range = ref.watch(currentDateRangeProvider);
  return ref.watch(reportDaoProvider).getDailySales(range);
});

final paymentBreakdownProvider = FutureProvider<List<PaymentMethodSummary>>((
  ref,
) {
  final range = ref.watch(currentDateRangeProvider);
  return ref.watch(reportDaoProvider).getPaymentMethodBreakdown(range);
});

final topProductsProvider = FutureProvider.family<List<TopProduct>, int?>((
  ref,
  limit,
) {
  final range = ref.watch(currentDateRangeProvider);
  return ref.watch(reportDaoProvider).getTopProducts(range, limit: limit);
});
