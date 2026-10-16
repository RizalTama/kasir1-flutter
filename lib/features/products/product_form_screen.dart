import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/image_storage.dart';
import '../../core/widgets/image_picker_sheet.dart';
import '../../core/widgets/primary_button.dart';
import 'products_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  int? _categoryId;
  String? _imagePath;
  bool _loading = true;
  bool _saving = false;
  Product? _existing;

  int? get _id =>
      widget.productId == null ? null : int.tryParse(widget.productId!);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _id;
    if (id != null) {
      final product = await ref.read(productDaoProvider).getById(id);
      if (!mounted) return;
      if (product != null) {
        _existing = product;
        _nameController.text = product.name;
        _priceController.text = product.price.toString();
        _categoryId = product.categoryId;
        _imagePath = product.imagePath;
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await pickImageFromSheet(context);
    if (path == null || !mounted) return;
    final String saved;
    try {
      saved = await saveProductImage(path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses gambar, coba foto lain')),
        );
      }
      return;
    }
    if (!mounted) return;
    final old = _imagePath;
    setState(() => _imagePath = saved);
    await deleteStoredImage(old);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final price = int.parse(_priceController.text.trim());
    final dao = ref.read(productDaoProvider);

    if (_existing == null) {
      await dao.insertProduct(
        ProductsCompanion.insert(
          name: name,
          price: price,
          categoryId: Value(_categoryId),
          imagePath: Value(_imagePath),
        ),
      );
    } else {
      await dao.updateProduct(
        _existing!
            .toCompanion(true)
            .copyWith(
              name: Value(name),
              price: Value(price),
              categoryId: Value(_categoryId),
              imagePath: Value(_imagePath),
              updatedAt: Value(DateTime.now()),
            ),
      );
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('"${_existing!.name}" akan disembunyikan dari Kasir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.hapus),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(productDaoProvider).softDelete(_existing!.id);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing != null;
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? AppStrings.editProduk : AppStrings.tambahProduk),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildImagePicker()),
                      const SizedBox(height: 24),
                      Text('Nama Produk', style: AppText.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'mis. Kopi Susu',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama produk wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Kategori', style: AppText.label),
                      const SizedBox(height: 6),
                      categoriesAsync.when(
                        data: (categories) => DropdownButtonFormField<int?>(
                          initialValue: _categoryId,
                          decoration: const InputDecoration(),
                          hint: const Text('Tanpa kategori'),
                          items: [
                            const DropdownMenuItem(
                              child: Text('Tanpa kategori'),
                            ),
                            for (final c in categories)
                              DropdownMenuItem(value: c.id, child: Text(c.name)),
                          ],
                          onChanged: (v) => setState(() => _categoryId = v),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (e, st) => const Text('Gagal memuat kategori'),
                      ),
                      const SizedBox(height: 16),
                      Text('Harga Jual', style: AppText.label),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          prefixText: 'Rp ',
                          hintText: '0',
                        ),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n <= 0) {
                            return 'Harga harus lebih dari 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: AppStrings.simpanProduk,
                        onPressed: _saving ? null : _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(14),
        ),
        child: _imagePath != null
            ? _ImagePreview(path: _imagePath!)
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.textSubtle,
                    size: 28,
                  ),
                  SizedBox(height: 6),
                  Text(AppStrings.unggahFotoProduk, style: AppText.label, textAlign: TextAlign.center),
                ],
              ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: resolveStoredImage(path),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            snapshot.data!,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
