import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Lingkaran accent + ikon cek navy (§4.4).
class SuccessBadge extends StatelessWidget {
  const SuccessBadge({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: AppColors.navy, size: size * 0.55),
    );
  }
}
