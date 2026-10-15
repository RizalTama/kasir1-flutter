import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pengaturanToko)),
      body: const EmptyState(
        icon: Icons.storefront_outlined,
        title: 'Pengaturan Toko akan dibangun di Fase 2',
      ),
    );
  }
}
