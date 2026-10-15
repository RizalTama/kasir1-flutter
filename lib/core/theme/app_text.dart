import 'package:flutter/material.dart';
import 'app_colors.dart';

const _sora = 'Sora';
const _mono = 'JetBrainsMono';

/// Gaya teks tambahan di luar [ThemeData.textTheme], terutama untuk nominal
/// uang, kode transaksi, dan angka statistik (selalu pakai font mono).
abstract final class AppText {
  static const screenTitle = TextStyle(
    fontFamily: _sora,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static const cardTitle = TextStyle(
    fontFamily: _sora,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static const body = TextStyle(
    fontFamily: _sora,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const bodyStrong = TextStyle(
    fontFamily: _sora,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.navy,
  );

  static const label = TextStyle(
    fontFamily: _sora,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSubtle,
  );

  static const money = TextStyle(
    fontFamily: _mono,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );

  static const moneyLarge = TextStyle(
    fontFamily: _mono,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
  );

  static const moneySmallOnDark = TextStyle(
    fontFamily: _mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedOnDark,
  );

  static const code = TextStyle(
    fontFamily: _mono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const statNumber = TextStyle(
    fontFamily: _mono,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );
}
