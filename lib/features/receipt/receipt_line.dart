/// Baris struk dalam bentuk terstruktur — satu sumber kebenaran yang
/// dipakai baik untuk pratinjau di layar ([ReceiptPreview]) maupun untuk
/// di-encode jadi byte ESC/POS.
sealed class ReceiptLine {
  const ReceiptLine();
}

class ReceiptText extends ReceiptLine {
  const ReceiptText(this.text, {this.bold = false, this.center = false});

  final String text;
  final bool bold;
  final bool center;
}

/// Baris dua kolom rata kiri-kanan, mis. "2 x 18.000" ... "36.000".
class ReceiptTwoColumn extends ReceiptLine {
  const ReceiptTwoColumn(this.left, this.right, {this.bold = false});

  final String left;
  final String right;
  final bool bold;
}

class ReceiptDivider extends ReceiptLine {
  const ReceiptDivider();
}
