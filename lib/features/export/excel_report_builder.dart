import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_database.dart';
import '../../core/db/daos/report_dao.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _timeFormat = DateFormat('HH:mm');

class ExcelReportOptions {
  const ExcelReportOptions({
    this.includeTransactions = true,
    this.includeProductRecap = true,
    this.includePaymentRecap = true,
  });

  final bool includeTransactions;
  final bool includeProductRecap;
  final bool includePaymentRecap;

  bool get hasAnySection =>
      includeTransactions || includeProductRecap || includePaymentRecap;
}

final _headerStyle = CellStyle(
  bold: true,
  fontColorHex: ExcelColor.white,
  backgroundColorHex: ExcelColor.fromHexString('FF0B1026'),
);

final _totalStyle = CellStyle(
  bold: true,
  backgroundColorHex: ExcelColor.fromHexString('FFFFF4E0'),
);

const _moneyFormat = NumFormat.standard_3; // "#,##0"

/// Susun workbook Excel (§6.5 Claude.md). Input sudah berupa hasil query
/// DAO (transaksi mentah + rekap), builder ini cuma menata jadi sheet.
abstract final class ExcelReportBuilder {
  static Excel build({
    required ExcelReportOptions options,
    required List<Transaction> transactions,
    required List<TopProduct> productRecap,
    required List<PaymentMethodSummary> paymentRecap,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();

    if (options.includeTransactions) {
      _buildTransactionsSheet(excel['Transaksi'], transactions);
    }
    if (options.includeProductRecap) {
      _buildProductSheet(excel['Per Produk'], productRecap);
    }
    if (options.includePaymentRecap) {
      _buildPaymentSheet(excel['Metode Bayar'], paymentRecap);
    }
    if (defaultSheet != null && excel.tables.length > 1) {
      excel.delete(defaultSheet);
    }
    return excel;
  }

  static void _buildTransactionsSheet(
    Sheet sheet,
    List<Transaction> transactions,
  ) {
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Tanggal'),
      TextCellValue('Jam'),
      TextCellValue('No. Transaksi'),
      TextCellValue('Metode'),
      TextCellValue('Item'),
      TextCellValue('Total'),
    ]);
    _styleRow(sheet, 0, 7, _headerStyle);

    var total = 0;
    for (var i = 0; i < transactions.length; i++) {
      final trx = transactions[i];
      total += trx.total;
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(_dateFormat.format(trx.createdAt)),
        TextCellValue(_timeFormat.format(trx.createdAt)),
        TextCellValue(trx.code),
        TextCellValue(trx.paymentMethod == 'cash' ? 'Tunai' : 'QRIS'),
        IntCellValue(trx.itemCount),
        IntCellValue(trx.total),
      ]);
      _setMoneyFormat(sheet, 6, i + 1);
    }

    final totalRow = transactions.length + 1;
    sheet.appendRow([
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(transactions.length),
      IntCellValue(total),
    ]);
    _styleRow(sheet, totalRow, 7, _totalStyle);
    _setMoneyFormat(sheet, 6, totalRow);

    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 12);
    sheet.setColumnWidth(2, 8);
    sheet.setColumnWidth(3, 14);
    sheet.setColumnWidth(4, 10);
    sheet.setColumnWidth(5, 8);
    sheet.setColumnWidth(6, 14);
  }

  static void _buildProductSheet(Sheet sheet, List<TopProduct> products) {
    sheet.appendRow([
      TextCellValue('No'),
      TextCellValue('Produk'),
      TextCellValue('Qty Terjual'),
      TextCellValue('Total Penjualan'),
    ]);
    _styleRow(sheet, 0, 4, _headerStyle);

    final sorted = [...products]
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    var totalQty = 0;
    var totalSales = 0;
    for (var i = 0; i < sorted.length; i++) {
      final p = sorted[i];
      totalQty += p.qtySold;
      totalSales += p.totalSales;
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(p.productName),
        IntCellValue(p.qtySold),
        IntCellValue(p.totalSales),
      ]);
      _setMoneyFormat(sheet, 3, i + 1);
    }

    final totalRow = sorted.length + 1;
    sheet.appendRow([
      TextCellValue('TOTAL'),
      TextCellValue(''),
      IntCellValue(totalQty),
      IntCellValue(totalSales),
    ]);
    _styleRow(sheet, totalRow, 4, _totalStyle);
    _setMoneyFormat(sheet, 3, totalRow);

    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 12);
    sheet.setColumnWidth(3, 16);
  }

  static void _buildPaymentSheet(
    Sheet sheet,
    List<PaymentMethodSummary> payments,
  ) {
    sheet.appendRow([
      TextCellValue('Metode'),
      TextCellValue('Jumlah Transaksi'),
      TextCellValue('Total'),
      TextCellValue('Persentase'),
    ]);
    _styleRow(sheet, 0, 4, _headerStyle);

    final grandTotal = payments.fold<int>(0, (s, p) => s + p.total);
    for (var i = 0; i < payments.length; i++) {
      final p = payments[i];
      final percent = grandTotal == 0 ? 0 : (p.total / grandTotal * 100);
      sheet.appendRow([
        TextCellValue(p.method == 'cash' ? 'Tunai' : 'QRIS'),
        IntCellValue(p.count),
        IntCellValue(p.total),
        TextCellValue('${percent.toStringAsFixed(1)}%'),
      ]);
      _setMoneyFormat(sheet, 2, i + 1);
    }

    sheet.setColumnWidth(0, 12);
    sheet.setColumnWidth(1, 16);
    sheet.setColumnWidth(2, 14);
    sheet.setColumnWidth(3, 12);
  }

  static void _styleRow(Sheet sheet, int row, int columnCount, CellStyle style) {
    for (var c = 0; c < columnCount; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
          .cellStyle = style;
    }
  }

  static void _setMoneyFormat(Sheet sheet, int column, int row) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
    );
    cell.cellStyle = (cell.cellStyle ?? CellStyle()).copyWith(
      numberFormat: _moneyFormat,
    );
  }
}
