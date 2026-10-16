import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/money.dart';
import 'product_thumbnail.dart';

/// Kartu produk grid Kasir: putih radius 16, foto cover rasio ±4:3 radius
/// 10, nama w600, harga mono; kalau di keranjang: border accent + badge
/// jumlah (§4.4).
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.qtyInCart,
    required this.onTap,
  });

  final String name;
  final int price;
  final String? imagePath;
  final int qtyInCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inCart = qtyInCart > 0;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: inCart ? AppColors.accent : AppColors.borderLight,
              width: inCart ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ProductThumbnail(
                      imagePath: imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      radius: 10,
                    ),
                  ),
                  if (inCart)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 22,
                          minHeight: 22,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$qtyInCart',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: AppText.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(formatRupiah(price), style: AppText.money),
            ],
          ),
        ),
      ),
    );
  }
}
