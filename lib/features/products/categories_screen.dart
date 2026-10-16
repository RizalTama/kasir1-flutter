import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/empty_state.dart';
import 'products_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<void> _addCategory(BuildContext context, WidgetRef ref) async {
    final name = await _promptName(context, title: 'Tambah Kategori');
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(categoryDaoProvider).insertCategory(name.trim());
    } catch (_) {
      if (!context.mounted) return;
      _showNameTakenError(context, name.trim());
    }
  }

  Future<void> _renameCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final name = await _promptName(
      context,
      title: 'Ganti Nama Kategori',
      initial: category.name,
    );
    if (name == null || name.trim().isEmpty || name.trim() == category.name) {
      return;
    }
    try {
      await ref
          .read(categoryDaoProvider)
          .renameCategory(category.id, name.trim());
    } catch (_) {
      if (!context.mounted) return;
      _showNameTakenError(context, name.trim());
    }
  }

  void _showNameTakenError(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nama kategori "$name" sudah dipakai')),
    );
  }

  Future<String?> _promptName(
    BuildContext context, {
    required String title,
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final count = await ref
        .read(productDaoProvider)
        .countInCategory(category.id);
    if (count > 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${category.name}" masih punya $count produk, pindahkan dulu sebelum dihapus',
          ),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus kategori?'),
        content: Text('"${category.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.hapus),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(categoryDaoProvider).deleteCategory(category.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.kelolaKategori)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: 'Belum ada kategori',
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: categories.length,
            onReorderItem: (oldIndex, newIndex) async {
              final ids = categories.map((c) => c.id).toList();
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex, moved);
              await ref.read(categoryDaoProvider).reorder(ids);
            },
            itemBuilder: (context, i) {
              final category = categories[i];
              return Card(
                key: ValueKey(category.id),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(
                    Icons.drag_indicator,
                    color: AppColors.textSubtle,
                  ),
                  title: Text(category.name, style: AppText.bodyStrong),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _renameCategory(context, ref, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            _deleteCategory(context, ref, category),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Gagal memuat kategori')),
      ),
    );
  }
}
