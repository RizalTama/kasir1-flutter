import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/daos/transaction_dao.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/image_storage.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/total_card.dart';
import '../pos/cart_provider.dart';
import '../pos/pos_providers.dart';
import 'cash_suggestions.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _amountController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initialMethod = ref.read(checkoutMethodProvider);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialMethod == 'qris' ? 1 : 0,
    );
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  List<NewTransactionItem> _cartToItems(List<CartItem> cart) {
    return cart
        .map(
          (c) => NewTransactionItem(
            productId: c.productId,
            productName: c.productName,
            unitPrice: c.unitPrice,
            qty: c.qty,
            note: (c.note == null || c.note!.isEmpty) ? null : c.note,
          ),
        )
        .toList();
  }

  Future<void> _finishCash(int total) async {
    final amountPaid = int.tryParse(_amountController.text) ?? 0;
    if (amountPaid < total || _saving) return;
    setState(() => _saving = true);

    // Ambil referensi notifier sebelum await — aman dipakai walau widget
    // sempat ter-dispose selagi menunggu, beda dengan ref.read() yang butuh
    // widget masih hidup.
    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.read(cartProvider);
    final trx = await ref
        .read(transactionDaoProvider)
        .saveTransaction(
          items: _cartToItems(cart),
          paymentMethod: 'cash',
          amountPaid: amountPaid,
        );

    // Clear keranjang segera setelah transaksi tersimpan supaya item yang
    // sama tidak bisa ke-checkout dobel, terlepas dari status mounted.
    cartNotifier.clear();
    if (!mounted) return;
    context.replace('/pos/success/${trx.id}');
  }

  Future<void> _confirmQris(int total) async {
    final checked = ValueNotifier(false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.konfirmasiPembayaranQris),
        content: ValueListenableBuilder<bool>(
          valueListenable: checked,
          builder: (context, value, _) => CheckboxListTile(
            value: value,
            onChanged: (v) => checked.value = v ?? false,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(AppStrings.danaSudahSayaCek),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.belum),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: checked,
            builder: (context, value, _) => FilledButton(
              onPressed: value
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              child: const Text(AppStrings.yaSudahMasuk),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _saving) return;
    setState(() => _saving = true);

    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.read(cartProvider);
    final trx = await ref
        .read(transactionDaoProvider)
        .saveTransaction(
          items: _cartToItems(cart),
          paymentMethod: 'qris',
          amountPaid: total,
        );

    cartNotifier.clear();
    if (!mounted) return;
    context.replace('/pos/success/${trx.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final settingsAsync = ref.watch(storeSettingsStreamProvider);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.pembayaran)),
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/pos'),
            child: const Text('Keranjang kosong, kembali ke Kasir'),
          ),
        ),
      );
    }

    final hasQris = (settingsAsync.asData?.value.qrisImagePath ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pembayaran),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          indicatorColor: AppColors.accent,
          tabs: [
            const Tab(text: AppStrings.tunai),
            Tab(text: hasQris ? AppStrings.qris : '${AppStrings.qris} 🔒'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CashTab(
            total: total,
            amountController: _amountController,
            saving: _saving,
            onConfirm: () => _finishCash(total),
          ),
          hasQris
              ? _QrisTab(
                  total: total,
                  storeName: settingsAsync.asData?.value.storeName ?? '',
                  qrisImagePath: settingsAsync.asData!.value.qrisImagePath!,
                  saving: _saving,
                  onConfirm: () => _confirmQris(total),
                )
              : _QrisUnavailable(onOpenSettings: () => context.push('/settings')),
        ],
      ),
    );
  }
}

class _CashTab extends StatelessWidget {
  const _CashTab({
    required this.total,
    required this.amountController,
    required this.saving,
    required this.onConfirm,
  });

  final int total;
  final TextEditingController amountController;
  final bool saving;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final amountPaid = int.tryParse(amountController.text) ?? 0;
    final change = amountPaid - total;
    final canFinish = amountPaid >= total && !saving;
    final suggestions = cashSuggestions(total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TotalCard(label: AppStrings.totalTagihan, amount: total),
            const SizedBox(height: 20),
            Text(AppStrings.uangDiterima, style: AppText.label),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(prefixText: 'Rp ', hintText: '0'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < suggestions.length; i++)
                  OutlinedButton(
                    onPressed: () => amountController.text = suggestions[i]
                        .toString(),
                    child: Text(
                      i == 0 ? AppStrings.uangPas : formatRupiah(suggestions[i]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.kembalian, style: AppText.bodyStrong),
                  Text(
                    formatRupiah(change < 0 ? 0 : change),
                    style: AppText.money,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: AppStrings.selesaiCetakNota,
              onPressed: canFinish ? onConfirm : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _QrisTab extends StatelessWidget {
  const _QrisTab({
    required this.total,
    required this.storeName,
    required this.qrisImagePath,
    required this.saving,
    required this.onConfirm,
  });

  final int total;
  final String storeName;
  final String qrisImagePath;
  final bool saving;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            Text(AppStrings.totalYangHarusDibayar, style: AppText.label),
            const SizedBox(height: 6),
            Text(
              formatRupiah(total),
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: FutureBuilder<File>(
                future: resolveStoredImage(qrisImagePath),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 240,
                      width: 240,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Image.file(
                    snapshot.data!,
                    height: 240,
                    width: 240,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (storeName.isNotEmpty)
              Text(storeName, style: AppText.cardTitle),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Minta pelanggan memasukkan nominal persis ${formatRupiah(total)}',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: AppStrings.konfirmasiSudahDibayar,
              onPressed: saving ? null : onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _QrisUnavailable extends StatelessWidget {
  const _QrisUnavailable({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.qr_code_2_outlined,
      title: 'QRIS toko belum diunggah',
      action: OutlinedButton(
        onPressed: onOpenSettings,
        child: const Text('Buka Pengaturan Toko'),
      ),
    );
  }
}
