import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Kartu laporan: varian gelap (navy, dipakai untuk total penjualan) &
/// terang (putih, dipakai untuk stat lain) — §4.4.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.dark = false,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? AppColors.navy : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: dark ? null : Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: dark ? AppColors.mutedOnDark : AppColors.textSubtle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: dark ? AppColors.accent : AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
