import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.daftarProduk)),
      body: const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Kelola Produk akan dibangun di Fase 3',
      ),
    );
  }
}
