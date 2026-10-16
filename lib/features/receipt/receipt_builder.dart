import 'dart:convert';

import 'package:intl/intl.dart';

import '../../core/utils/money.dart';
import 'receipt_data.dart';
import 'receipt_line.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _timeFormat = DateFormat('HH:mm');

// Perintah ESC/POS dasar, dikirim langsung tanpa paket generator pihak
// ketiga: `esc_pos_utils_plus` memuat profil printer dari asset bundle
// (`CapabilityProfile.load()`) yang pada versi yang tersedia (2.0.4) hang
// total karena asset-nya tidak ketemu di path yang didaftarkan paket itu —
// terverifikasi macet >10 menit saat dites. ReceiptBuilder sebisa mungkin
// harus murni & sinkron (§7 Claude.md), jadi encode ESC/POS dilakukan
// manual di sini.
const _escInit = [0x1B, 0x40];
const _feedLine = 0x0A;

List<int> _bold(bool on) => [0x1B, 0x45, on ? 0x01 : 0x00];
List<int> _align(int n) => [0x1B, 0x61, n]; // 0=left 1=center 2=right
List<int> _cut() => [0x1D, 0x56, 0x00];

/// Membangun struk dari [ReceiptData] — §7 Claude.md.
///
/// [buildLines] dan [renderText] murni & sinkron (gampang di-unit-test).
/// [toBytes] juga murni & sinkron — encode [buildLines] jadi byte ESC/POS
/// secara manual (lihat catatan di atas soal kenapa tidak memakai
/// `esc_pos_utils_plus`).
abstract final class ReceiptBuilder {
  static List<ReceiptLine> buildLines(ReceiptData data) {
    final lines = <ReceiptLine>[
      ReceiptText(data.storeName.toUpperCase(), bold: true, center: true),
      if (data.storeAddress.trim().isNotEmpty)
        ReceiptText(data.storeAddress, center: true),
      const ReceiptDivider(),
      ReceiptTwoColumn(
        _dateFormat.format(data.createdAt),
        _timeFormat.format(data.createdAt),
      ),
      ReceiptText('No: ${data.trxCode}'),
      const ReceiptDivider(),
    ];

    for (final item in data.items) {
      lines.add(ReceiptText(item.name));
      lines.add(
        ReceiptTwoColumn(
          '  ${item.qty} x ${formatRupiahPlain(item.unitPrice)}',
          formatRupiahPlain(item.lineTotal),
        ),
      );
      if (item.note != null && item.note!.trim().isNotEmpty) {
        lines.add(ReceiptText('  * ${item.note}'));
      }
    }

    lines.add(const ReceiptDivider());
    lines.add(
      ReceiptTwoColumn('TOTAL', formatRupiahPlain(data.total), bold: true),
    );
    if (data.paymentMethod == 'cash') {
      lines.add(ReceiptTwoColumn('Tunai', formatRupiahPlain(data.amountPaid)));
      lines.add(
        ReceiptTwoColumn('Kembali', formatRupiahPlain(data.changeAmount)),
      );
    } else {
      lines.add(const ReceiptText('Metode QRIS'));
    }
    lines.add(const ReceiptDivider());
    lines.add(ReceiptText(data.receiptFooter, center: true));

    return lines;
  }

  /// Render [lines] jadi teks monospace rata [columns] kolom (32 utk 58mm,
  /// 48 utk 80mm) — dipakai [ReceiptPreview] dan untuk memverifikasi layout
  /// di unit test.
  static String renderText(List<ReceiptLine> lines, int columns) {
    return lines.map((l) => _renderLine(l, columns)).join('\n');
  }

  static String _renderLine(ReceiptLine line, int columns) {
    return switch (line) {
      ReceiptDivider() => '-' * columns,
      ReceiptText(:final text, :final center) =>
        center ? _center(text, columns) : _clip(text, columns),
      ReceiptTwoColumn(:final left, :final right) =>
        _twoColumn(left, right, columns),
    };
  }

  static String _clip(String text, int columns) {
    return text.length > columns ? text.substring(0, columns) : text;
  }

  static String _center(String text, int columns) {
    final clipped = _clip(text, columns);
    final padding = (columns - clipped.length) ~/ 2;
    return ' ' * (padding < 0 ? 0 : padding) + clipped;
  }

  static String _twoColumn(String left, String right, int columns) {
    final maxLeft = columns - right.length - 1;
    final clippedLeft = (maxLeft > 0 && left.length > maxLeft)
        ? left.substring(0, maxLeft)
        : left;
    final gap = columns - clippedLeft.length - right.length;
    return clippedLeft + ' ' * (gap < 1 ? 1 : gap) + right;
  }

  /// Encode [data] jadi byte ESC/POS siap kirim ke printer thermal via
  /// `print_bluetooth_thermal`. [paperWidthMm] 58 (32 kolom) atau 80 (48
  /// kolom).
  static List<int> toBytes(ReceiptData data, int paperWidthMm) {
    final columns = paperWidthMm == 80 ? 48 : 32;
    final bytes = <int>[..._escInit];

    for (final line in buildLines(data)) {
      bytes.addAll(_lineBytes(line, columns));
    }

    bytes.addAll(List.filled(3, _feedLine));
    bytes.addAll(_cut());
    return bytes;
  }

  static List<int> _lineBytes(ReceiptLine line, int columns) {
    switch (line) {
      case ReceiptDivider():
        return [..._encode('-' * columns), _feedLine];
      case ReceiptText(:final text, :final bold, :final center):
        final bytes = <int>[];
        if (center) bytes.addAll(_align(1));
        if (bold) bytes.addAll(_bold(true));
        bytes.addAll(_encode(_clip(text, columns)));
        bytes.add(_feedLine);
        if (bold) bytes.addAll(_bold(false));
        if (center) bytes.addAll(_align(0));
        return bytes;
      case ReceiptTwoColumn(:final left, :final right, :final bold):
        final bytes = <int>[];
        if (bold) bytes.addAll(_bold(true));
        bytes.addAll(_encode(_twoColumn(left, right, columns)));
        bytes.add(_feedLine);
        if (bold) bytes.addAll(_bold(false));
        return bytes;
    }
  }

  /// `latin1.encode` melempar [ArgumentError] untuk karakter di luar Latin-1
  /// (mis. emoji di nama produk/catatan — input bebas dari user). Ganti
  /// karakter semacam itu dengan `?` supaya cetak struk tidak pernah crash.
  static List<int> _encode(String text) {
    final safe = String.fromCharCodes(
      text.codeUnits.map((c) => c <= 0xFF ? c : 0x3F),
    );
    return latin1.encode(safe);
  }
}
