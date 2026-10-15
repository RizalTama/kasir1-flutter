import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    final isEdit = productId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? AppStrings.editProduk : AppStrings.tambahProduk),
      ),
      body: const EmptyState(
        icon: Icons.add_box_outlined,
        title: 'Form Produk akan dibangun di Fase 3',
      ),
    );
  }
}
