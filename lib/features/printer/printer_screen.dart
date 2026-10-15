import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class PrinterScreen extends StatelessWidget {
  const PrinterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.printer)),
      body: const EmptyState(
        icon: Icons.print_outlined,
        title: 'Pengaturan Printer akan dibangun di Fase 5',
      ),
    );
  }
}
