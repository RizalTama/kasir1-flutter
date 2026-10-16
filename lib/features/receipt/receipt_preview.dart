import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'receipt_builder.dart';
import 'receipt_data.dart';

/// Pratinjau struk di layar — teks yang sama persis dengan yang dikirim
/// ke printer (lewat [ReceiptBuilder.renderText]).
class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.data, required this.columns});

  final ReceiptData data;

  /// 32 kolom (58mm) atau 48 kolom (80mm).
  final int columns;

  @override
  Widget build(BuildContext context) {
    final text = ReceiptBuilder.renderText(
      ReceiptBuilder.buildLines(data),
      columns,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 11.5,
          height: 1.4,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
