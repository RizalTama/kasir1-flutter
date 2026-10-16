import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/image_storage.dart';
import '../../core/widgets/image_picker_sheet.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _step = 0;
  String? _qrisPath;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _goToQrisStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  Future<void> _pickQris() async {
    final path = await pickImageFromSheet(context);
    if (path == null || !mounted) return;
    final String saved;
    try {
      saved = await saveQrisImage(path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses gambar, coba foto lain')),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() => _qrisPath = saved);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref
        .read(storeSettingsDaoProvider)
        .save(
          StoreSettingsCompanion(
            storeName: Value(_nameController.text.trim()),
            storeAddress: Value(_addressController.text.trim()),
            qrisImagePath: Value(_qrisPath),
            onboardingDone: const Value(true),
          ),
        );
    // Router redirect ke /pos terjadi otomatis lewat onboardingDoneProvider.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: _step == 0 ? _buildStoreStep() : _buildQrisStep(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreStep() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.setupJudul, style: AppText.screenTitle),
          const SizedBox(height: 6),
          Text(AppStrings.setupSubjudul, style: AppText.body),
          const SizedBox(height: 24),
          Text(AppStrings.namaToko, style: AppText.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'mis. Kedai Senja'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama toko wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          Text(AppStrings.alamatToko, style: AppText.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'mis. Jl. Melati No. 12'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: AppStrings.lanjut, onPressed: _goToQrisStep),
        ],
      ),
    );
  }

  Widget _buildQrisStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.setupQrisJudul, style: AppText.screenTitle),
        const SizedBox(height: 6),
        Text(AppStrings.setupQrisSubjudul, style: AppText.body),
        const SizedBox(height: 20),
        if (_qrisPath != null)
          FutureBuilder<File>(
            future: resolveStoredImage(_qrisPath!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 180);
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  snapshot.data!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              );
            },
          )
        else
          InkWell(
            onTap: _pickQris,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2_outlined, size: 36, color: AppColors.textSubtle),
                  SizedBox(height: 8),
                  Text(AppStrings.unggahGambarQris, style: AppText.bodyStrong),
                ],
              ),
            ),
          ),
        if (_qrisPath != null) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: _pickQris, child: const Text(AppStrings.ganti)),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          label: _qrisPath == null ? AppStrings.lewati : AppStrings.selesai,
          onPressed: _saving ? null : _finish,
        ),
      ],
    );
  }
}
