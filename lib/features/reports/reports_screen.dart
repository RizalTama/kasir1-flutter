import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.laporanPenjualan)),
      body: const EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'Laporan Penjualan akan dibangun di Fase 6',
      ),
    );
  }
}
