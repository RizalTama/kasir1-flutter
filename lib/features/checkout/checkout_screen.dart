import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pembayaran)),
      body: const EmptyState(
        icon: Icons.payments_outlined,
        title: 'Layar Pembayaran akan dibangun di Fase 4',
      ),
    );
  }
}
