import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/db/daos/report_dao.dart';
import '../../../core/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/empty_state.dart';

/// Donat persentase metode bayar: Tunai (navy) vs QRIS (info) — §6.4.
class PaymentDonutChart extends StatelessWidget {
  const PaymentDonutChart({super.key, required this.data});

  final List<PaymentMethodSummary> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, d) => sum + d.total);
    if (data.isEmpty || total == 0) {
      return const SizedBox(
        height: 160,
        child: EmptyState(
          icon: Icons.pie_chart_outline,
          title: 'Belum ada data metode bayar',
        ),
      );
    }

    final cash = data.where((d) => d.method == 'cash').fold<int>(
      0,
      (s, d) => s + d.total,
    );
    final qris = data.where((d) => d.method == 'qris').fold<int>(
      0,
      (s, d) => s + d.total,
    );

    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: [
                if (cash > 0)
                  PieChartSectionData(
                    value: cash.toDouble(),
                    color: AppColors.navy,
                    showTitle: false,
                    radius: 22,
                  ),
                if (qris > 0)
                  PieChartSectionData(
                    value: qris.toDouble(),
                    color: AppColors.info,
                    showTitle: false,
                    radius: 22,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendRow(
                color: AppColors.navy,
                label: AppStrings.tunai,
                percent: cash / total,
              ),
              const SizedBox(height: 8),
              _LegendRow(
                color: AppColors.info,
                label: AppStrings.qris,
                percent: qris / total,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.percent,
  });

  final Color color;
  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppText.body)),
        Text('${(percent * 100).round()}%', style: AppText.bodyStrong),
      ],
    );
  }
}
