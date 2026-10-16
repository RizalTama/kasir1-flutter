import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/image_storage.dart';

/// Thumbnail foto produk/QRIS dari path relatif, dengan placeholder kalau
/// belum ada foto. Default persegi (pakai [size]); untuk rasio lain, isi
/// [width]/[height] (mis. kartu produk 4:3) — keduanya boleh `double.infinity`
/// untuk mengisi parent (mis. di dalam [AspectRatio]).
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.imagePath,
    double size = 56,
    double? width,
    double? height,
    this.radius = 10,
  }) : width = width ?? size,
       height = height ?? size;

  final String? imagePath;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final iconSize = height.isFinite ? height * 0.45 : 24.0;
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textSubtle,
        size: iconSize,
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
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );
        },
      ),
    );
  }
}
