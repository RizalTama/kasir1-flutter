import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Penyimpanan foto produk & gambar QRIS (§9 Claude.md): disalin ke
/// `getApplicationDocumentsDirectory()/images/` dengan nama unik, path
/// relatif (`images/xxx.jpg`) yang disimpan di DB.

Future<Directory> _imagesDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'images'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

String _uniqueFileName(String prefix) {
  return '${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg';
}

Future<String> _saveCompressed(
  String sourcePath, {
  required String prefix,
  required int maxSide,
  required int quality,
}) async {
  final dir = await _imagesDir();
  final targetPath = p.join(dir.path, _uniqueFileName(prefix));
  final result = await FlutterImageCompress.compressAndGetFile(
    sourcePath,
    targetPath,
    minWidth: maxSide,
    minHeight: maxSide,
    quality: quality,
  );
  if (result == null) {
    throw StateError('Gagal memproses gambar: $sourcePath');
  }
  return p.join('images', p.basename(result.path));
}

/// Foto produk: maks 800px sisi terpanjang, JPEG kualitas ±80.
Future<String> saveProductImage(String sourcePath) {
  return _saveCompressed(
    sourcePath,
    prefix: 'product',
    maxSide: 800,
    quality: 80,
  );
}

/// Gambar QRIS toko: maks 1200px, kualitas tinggi (≥90) agar tetap bisa
/// di-scan — jangan dikompres agresif.
Future<String> saveQrisImage(String sourcePath) {
  return _saveCompressed(sourcePath, prefix: 'qris', maxSide: 1200, quality: 90);
}

/// Hapus file gambar lama berdasarkan path relatif. Aman dipanggil
/// walau file sudah tidak ada.
Future<void> deleteStoredImage(String? relativePath) async {
  if (relativePath == null || relativePath.isEmpty) return;
  final docs = await getApplicationDocumentsDirectory();
  final file = File(p.join(docs.path, relativePath));
  if (await file.exists()) {
    await file.delete();
  }
}

/// Resolve path relatif dari DB jadi [File] absolut untuk ditampilkan.
Future<File> resolveStoredImage(String relativePath) async {
  final docs = await getApplicationDocumentsDirectory();
  return File(p.join(docs.path, relativePath));
}
