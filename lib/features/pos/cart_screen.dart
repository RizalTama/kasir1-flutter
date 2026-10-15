import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.keranjang)),
      body: const EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Layar Keranjang akan dibangun di Fase 4',
      ),
    );
  }
}
