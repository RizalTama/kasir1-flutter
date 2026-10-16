import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Ikon printer, nama, status dot info + "Terhubung" (§4.4).
class PrinterStatusTile extends StatelessWidget {
  const PrinterStatusTile({super.key, required this.printerName});

  /// Null/kosong = belum ada printer tersimpan.
  final String? printerName;

  @override
  Widget build(BuildContext context) {
    final connected = printerName != null && printerName!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.print_outlined, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              connected ? printerName! : 'Printer belum diatur',
              style: AppText.bodyStrong,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (connected) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(AppStrings.terhubung, style: AppText.label),
          ],
        ],
      ),
    );
  }
}
