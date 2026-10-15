import 'package:intl/intl.dart';

final _rupiahFormat = NumberFormat.decimalPattern('id_ID');

/// Format [amount] rupiah jadi `Rp56.000` (tanpa spasi, titik ribuan).
String formatRupiah(int amount) {
  return 'Rp${_rupiahFormat.format(amount)}';
}
