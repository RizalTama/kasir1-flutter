/// Format nomor urut transaksi jadi kode `TRX-00001` (§6.2 Claude.md).
String formatTrxCode(int number) {
  return 'TRX-${number.toString().padLeft(5, '0')}';
}
