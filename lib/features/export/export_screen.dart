import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exportLaporan)),
      body: const EmptyState(
        icon: Icons.ios_share_outlined,
        title: 'Export Excel akan dibangun di Fase 6',
      ),
    );
  }
}
