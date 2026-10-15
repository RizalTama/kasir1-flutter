import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/layout/responsive.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/image_storage.dart';
import '../../core/widgets/image_picker_sheet.dart';
import '../../core/widgets/primary_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _footerController = TextEditingController();

  bool _initialized = false;
  bool _saving = false;
  String? _qrisPath;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _applySettings(StoreSetting s) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = s.storeName;
    _addressController.text = s.storeAddress;
    _footerController.text = s.receiptFooter;
    _qrisPath = s.qrisImagePath;
  }

  Future<void> _pickQris() async {
    final path = await pickImageFromSheet(context);
    if (path == null || !mounted) return;
    final saved = await saveQrisImage(path);
    if (!mounted) return;
    final old = _qrisPath;
    setState(() => _qrisPath = saved);
    await deleteStoredImage(old);
  }

  Future<void> _removeQris() async {
    final old = _qrisPath;
    setState(() => _qrisPath = null);
    await deleteStoredImage(old);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final footer = _footerController.text.trim();
    await ref
        .read(storeSettingsDaoProvider)
        .save(
          StoreSettingsCompanion(
            storeName: Value(_nameController.text.trim()),
            storeAddress: Value(_addressController.text.trim()),
            receiptFooter: Value(footer.isEmpty ? 'Terima kasih!' : footer),
            qrisImagePath: Value(_qrisPath),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.pengaturanTersimpan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(storeSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.pengaturanToko)),
      body: settingsAsync.when(
        data: (s) {
          _applySettings(s);
          return _buildForm(context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            const Center(child: Text('Gagal memuat pengaturan toko')),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = isTabletWidth(width) ? 24.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.namaToko, style: AppText.label),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'mis. Kedai Senja'),
            ),
            const SizedBox(height: 16),
            Text(AppStrings.alamatToko, style: AppText.label),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'mis. Jl. Melati No. 12',
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.gambarQrisToko, style: AppText.label),
            const SizedBox(height: 8),
            _buildQrisPicker(),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text(AppStrings.printer),
                subtitle: const Text('Pilih printer & ukuran kertas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/printer'),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.teksKakiStruk, style: AppText.label),
            const SizedBox(height: 6),
            TextField(
              controller: _footerController,
              decoration: const InputDecoration(hintText: 'Terima kasih!'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: AppStrings.simpanPengaturan,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisPicker() {
    if (_qrisPath == null) {
      return OutlinedButton.icon(
        onPressed: _pickQris,
        icon: const Icon(Icons.qr_code_2_outlined),
        label: const Text(AppStrings.unggahGambarQris),
      );
    }
    return FutureBuilder<File>(
      future: resolveStoredImage(_qrisPath!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(snapshot.data!, height: 180, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(onPressed: _pickQris, child: const Text(AppStrings.ganti)),
                TextButton(onPressed: _removeQris, child: const Text(AppStrings.hapus)),
              ],
            ),
          ],
        );
      },
    );
  }
}
