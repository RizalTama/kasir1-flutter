import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/daos/report_dao.dart';
import '../../core/layout/responsive.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/stat_card.dart';
import 'reports_providers.dart';
import 'widgets/payment_donut_chart.dart';
import 'widgets/period_filter_chips.dart';
import 'widgets/sales_bar_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final tablet = isTabletWidth(width);

    final summaryAsync = ref.watch(reportSummaryProvider);
    final dailySalesAsync = ref.watch(dailySalesProvider);
    final paymentAsync = ref.watch(paymentBreakdownProvider);
    final topProductsAsync = ref.watch(topProductsProvider(tablet ? 3 : null));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.laporanPenjualan),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/reports/export'),
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text(AppStrings.exportExcel),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tablet ? 24 : 16),
        children: [
          const PeriodFilterChips(),
          const SizedBox(height: 16),
          summaryAsync.when(
            data: (summary) {
              final cards = [
                StatCard(
                  label: AppStrings.totalPenjualan,
                  value: formatRupiah(summary.totalSales),
                  dark: true,
                ),
                StatCard(
                  label: AppStrings.jumlahTransaksi,
                  value: '${summary.transactionCount}',
                ),
                StatCard(
                  label: AppStrings.rataRataPerTransaksi,
                  value: formatRupiah(summary.average),
                ),
              ];
              if (tablet) {
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    cards[i],
                  ],
                ],
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => const Text('Gagal memuat ringkasan'),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: AppStrings.penjualanHarian,
            child: dailySalesAsync.when(
              data: (data) => SalesBarChart(data: data),
              loading: () => const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => const Text('Gagal memuat grafik'),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: AppStrings.metodeBayar,
            child: paymentAsync.when(
              data: (data) => PaymentDonutChart(data: data),
              loading: () => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => const Text('Gagal memuat data metode bayar'),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: AppStrings.produkTerlaris,
            trailing: !tablet
                ? null
                : TextButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const _AllTopProductsSheet(),
                    ),
                    child: const Text('Lihat semua'),
                  ),
            child: topProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Belum ada produk terjual',
                  );
                }
                return Column(
                  children: [
                    for (final p in products) _TopProductRow(product: p),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Gagal memuat produk terlaris'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppText.cardTitle)),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({required this.product});

  final TopProduct product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              product.productName,
              style: AppText.bodyStrong,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${product.qtySold} terjual', style: AppText.label),
        ],
      ),
    );
  }
}

class _AllTopProductsSheet extends ConsumerWidget {
  const _AllTopProductsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(topProductsProvider(null));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.produkTerlaris, style: AppText.screenTitle),
            const SizedBox(height: 12),
            Flexible(
              child: productsAsync.when(
                data: (products) => ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in products) _TopProductRow(product: p),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Text('Gagal memuat produk terlaris'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
