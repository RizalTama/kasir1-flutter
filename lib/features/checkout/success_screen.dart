import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/dark_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/printer_status_tile.dart';
import '../../core/widgets/success_badge.dart';

final _transactionProvider = FutureProvider.family<Transaction?, int>((
  ref,
  id,
) {
  return ref.watch(transactionDaoProvider).getById(id);
});

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key, required this.trxId});

  final String trxId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(trxId);
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.transaksiBerhasil)),
        body: const Center(child: Text('Transaksi tidak ditemukan')),
      );
    }

    final trxAsync = ref.watch(_transactionProvider(id));
    final settingsAsync = ref.watch(storeSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transaksiBerhasil),
        automaticallyImplyLeading: false,
      ),
      body: trxAsync.when(
        data: (trx) {
          if (trx == null) {
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }
          final printerName = settingsAsync.asData?.value.printerName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const SuccessBadge(),
                    const SizedBox(height: 16),
                    Text(
                      formatRupiah(trx.total),
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(label: 'No. transaksi', value: trx.code),
                          _InfoRow(
                            label: 'Metode',
                            value: trx.paymentMethod == 'cash'
                                ? AppStrings.tunai
                                : AppStrings.qris,
                          ),
                          _InfoRow(
                            label: 'Dibayar',
                            value: formatRupiah(trx.amountPaid),
                          ),
                          _InfoRow(
                            label: AppStrings.kembalian,
                            value: formatRupiah(trx.changeAmount),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrinterStatusTile(printerName: printerName),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: DarkButton(
                            label: AppStrings.cetakNota,
                            icon: Icons.print_outlined,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Hubungkan printer dulu di Pengaturan Printer',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: AppStrings.transaksiBaru,
                            onPressed: () => context.go('/pos'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Gagal memuat transaksi')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body),
          Text(value, style: AppText.bodyStrong),
        ],
      ),
    );
  }
}
