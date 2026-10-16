import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/money.dart';

/// Kartu total: bg navy, label mutedOnDark, nominal mono accent (§4.4).
class TotalCard extends StatelessWidget {
  const TotalCard({super.key, required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.mutedOnDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(amount),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
