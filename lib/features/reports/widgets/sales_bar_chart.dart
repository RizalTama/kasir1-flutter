import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/db/daos/report_dao.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Grafik batang penjualan harian; hari tertinggi diberi warna aksen
/// (§6.4 Claude.md). Label hari dipakai untuk rentang <=7 hari, tanggal
/// untuk selebihnya.
class SalesBarChart extends StatelessWidget {
  const SalesBarChart({super.key, required this.data});

  final List<DailySales> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: EmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'Belum ada penjualan di periode ini',
        ),
      );
    }

    final maxTotal = data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final useDayLabel = data.length <= 7;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxTotal == 0 ? 1 : maxTotal * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  final date = data[i].date;
                  final label = useDayLabel
                      ? _dayLabels[date.weekday - 1]
                      : '${date.day}/${date.month}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].total.toDouble(),
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                    color: data[i].total == maxTotal
                        ? AppColors.accent
                        : AppColors.infoSoft,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
