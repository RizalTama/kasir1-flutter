import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/image_storage.dart';

/// Thumbnail foto produk/QRIS dari path relatif, dengan placeholder kalau
/// belum ada foto.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.imagePath,
    this.size = 56,
    this.radius = 10,
  });

  final String? imagePath;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textSubtle,
        size: size * 0.45,
      ),
    );

    final path = imagePath;
    if (path == null || path.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: FutureBuilder<File>(
        future: resolveStoredImage(path),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return placeholder;
          return Image.file(
            snapshot.data!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );
        },
      ),
    );
  }
}
