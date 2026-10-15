import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.trxId});

  final String trxId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.transaksiBerhasil)),
      body: EmptyState(
        icon: Icons.check_circle_outline,
        title: 'Layar sukses untuk transaksi #$trxId akan dibangun di Fase 4',
      ),
    );
  }
}
