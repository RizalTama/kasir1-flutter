import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/db/app_database.dart';
import '../../core/db/providers.dart';
import '../../core/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../receipt/receipt_builder.dart';
import '../receipt/receipt_data.dart';

class PrinterScreen extends ConsumerStatefulWidget {
  const PrinterScreen({super.key});

  @override
  ConsumerState<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends ConsumerState<PrinterScreen> {
  List<BluetoothInfo> _devices = [];
  bool _loading = true;
  bool _testing = false;
  String? _connectedAddress;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final devices = await PrintBluetoothThermal.pairedBluetooths;
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _loading = false;
    });
  }

  Future<void> _selectDevice(BluetoothInfo device) async {
    await ref
        .read(storeSettingsDaoProvider)
        .save(
          StoreSettingsCompanion(
            printerName: Value(device.name),
            printerAddress: Value(device.macAdress),
          ),
        );
    if (!mounted) return;
    setState(() => _connectedAddress = null);
  }

  Future<void> _selectPaperWidth(int width) async {
    await ref
        .read(storeSettingsDaoProvider)
        .save(StoreSettingsCompanion(paperWidthMm: Value(width)));
  }

  Future<void> _testPrint(String address, int paperWidthMm) async {
    setState(() => _testing = true);
    try {
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: address,
      );
      if (!connected) {
        _showMessage('Gagal terhubung ke printer');
        return;
      }
      if (mounted) setState(() => _connectedAddress = address);

      final testData = ReceiptData(
        storeName: 'Tes Cetak',
        storeAddress: 'Astron Kasir',
        receiptFooter: 'Printer siap dipakai!',
        trxCode: 'TRX-00000',
        createdAt: DateTime.now(),
        items: const [
          ReceiptItem(
            name: 'Contoh Produk',
            qty: 1,
            unitPrice: 10000,
            lineTotal: 10000,
          ),
        ],
        total: 10000,
        paymentMethod: 'cash',
        amountPaid: 10000,
        changeAmount: 0,
      );
      final bytes = ReceiptBuilder.toBytes(testData, paperWidthMm);
      final sent = await PrintBluetoothThermal.writeBytes(bytes);
      _showMessage(sent ? 'Tes cetak berhasil' : 'Gagal mengirim data cetak');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(storeSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.printer)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : settingsAsync.when(
              data: (settings) => _buildBody(settings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  const Center(child: Text('Gagal memuat pengaturan')),
            ),
    );
  }

  Widget _buildBody(StoreSetting settings) {
    if (_devices.isEmpty) {
      return const EmptyState(
        icon: Icons.print_disabled_outlined,
        title: 'Belum ada printer Bluetooth yang di-pair.\n'
            'Pair printer lewat Pengaturan Bluetooth HP dulu, lalu buka layar ini lagi.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(AppStrings.ukuranKertas, style: AppText.label),
        const SizedBox(height: 8),
        Row(
          children: [
            _PaperChip(
              label: '58 mm',
              selected: settings.paperWidthMm == 58,
              onTap: () => _selectPaperWidth(58),
            ),
            const SizedBox(width: 8),
            _PaperChip(
              label: '80 mm',
              selected: settings.paperWidthMm == 80,
              onTap: () => _selectPaperWidth(80),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Pilih Printer', style: AppText.label),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<String>(
            groupValue: settings.printerAddress,
            onChanged: (address) {
              for (final device in _devices) {
                if (device.macAdress == address) {
                  _selectDevice(device);
                  break;
                }
              }
            },
            child: Column(
              children: [
                for (final device in _devices)
                  RadioListTile<String>(
                    value: device.macAdress,
                    title: Text(device.name, style: AppText.bodyStrong),
                    subtitle: Text(device.macAdress, style: AppText.label),
                    secondary:
                        device.macAdress == settings.printerAddress &&
                            _connectedAddress == device.macAdress
                        ? const _ConnectedDot()
                        : null,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (settings.printerAddress != null)
          PrimaryButton(
            label: AppStrings.tesCetak,
            icon: Icons.print_outlined,
            onPressed: _testing
                ? null
                : () => _testPrint(settings.printerAddress!, settings.paperWidthMm),
          ),
      ],
    );
  }
}

class _ConnectedDot extends StatelessWidget {
  const _ConnectedDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.info,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        const Text(AppStrings.terhubung, style: AppText.label),
      ],
    );
  }
}

class _PaperChip extends StatelessWidget {
  const _PaperChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : AppColors.chip,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.textOnDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
