import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/widgets/empty_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.kelolaKategori)),
      body: const EmptyState(
        icon: Icons.category_outlined,
        title: 'Kelola Kategori akan dibangun di Fase 3',
      ),
    );
  }
}
