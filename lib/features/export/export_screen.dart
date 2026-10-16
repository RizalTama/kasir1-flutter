import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/app_database.dart';
import '../../core/db/daos/report_dao.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/primary_button.dart';
import '../reports/reports_providers.dart';
import '../reports/widgets/period_filter_chips.dart';
import 'excel_report_builder.dart';
import 'period_file_label.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _includeTransactions = true;
  bool _includeProductRecap = true;
  bool _includePaymentRecap = true;
  bool _exporting = false;

  bool get _hasAnySection =>
      _includeTransactions || _includeProductRecap || _includePaymentRecap;

  Future<void> _export() async {
    if (!_hasAnySection || _exporting) return;
    setState(() => _exporting = true);

    try {
      final range = ref.read(currentDateRangeProvider);
      final dao = ref.read(reportDaoProvider);

      final List<Transaction> transactions = _includeTransactions
          ? await dao.getTransactionsInRange(range)
          : const [];
      final List<TopProduct> productRecap = _includeProductRecap
          ? await dao.getTopProducts(range)
          : const [];
      final List<PaymentMethodSummary> paymentRecap = _includePaymentRecap
          ? await dao.getPaymentMethodBreakdown(range)
          : const [];

      final excel = ExcelReportBuilder.build(
        options: ExcelReportOptions(
          includeTransactions: _includeTransactions,
          includeProductRecap: _includeProductRecap,
          includePaymentRecap: _includePaymentRecap,
        ),
        transactions: transactions,
        productRecap: productRecap,
        paymentRecap: paymentRecap,
      );
      final bytes = Uint8List.fromList(excel.encode()!);
      final fileName = 'Laporan_${periodFileLabel(range)}';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tersimpan: $fileName.xlsx'),
          action: SnackBarAction(
            label: 'Bagikan',
            onPressed: () => SharePlus.instance.share(
              ShareParams(
                files: [
                  XFile.fromData(
                    bytes,
                    name: '$fileName.xlsx',
                    mimeType:
                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exportLaporan)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppStrings.periode, style: AppText.label),
          const SizedBox(height: 8),
          const PeriodFilterChips(),
          const SizedBox(height: 24),
          Text(AppStrings.isiLaporan, style: AppText.label),
          const SizedBox(height: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _includeTransactions,
            onChanged: (v) => setState(() => _includeTransactions = v ?? false),
            title: const Text('Rincian transaksi'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _includeProductRecap,
            onChanged: (v) => setState(() => _includeProductRecap = v ?? false),
            title: const Text('Rekap per produk'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _includePaymentRecap,
            onChanged: (v) => setState(() => _includePaymentRecap = v ?? false),
            title: const Text('Rekap metode bayar'),
          ),
          const SizedBox(height: 12),
          Text(AppStrings.format, style: AppText.label),
          const SizedBox(height: 6),
          const Text('Excel (.xlsx)', style: AppText.bodyStrong),
          const SizedBox(height: 28),
          PrimaryButton(
            label: AppStrings.exportKeExcel,
            icon: Icons.ios_share_outlined,
            onPressed: (_hasAnySection && !_exporting) ? _export : null,
          ),
        ],
      ),
    );
  }
}
