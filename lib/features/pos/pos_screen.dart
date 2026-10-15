import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.kasir)),
      body: const EmptyState(
        icon: Icons.point_of_sale_outlined,
        title: 'Layar Kasir akan dibangun di Fase 4',
      ),
    );
  }
}
