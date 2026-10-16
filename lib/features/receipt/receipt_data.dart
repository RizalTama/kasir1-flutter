/// Input murni untuk [ReceiptBuilder] — snapshot transaksi + pengaturan
/// toko, tidak bergantung pada DB/drift supaya mudah di-unit-test.
class ReceiptData {
  const ReceiptData({
    required this.storeName,
    required this.storeAddress,
    required this.receiptFooter,
    required this.trxCode,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.changeAmount,
  });

  final String storeName;
  final String storeAddress;
  final String receiptFooter;
  final String trxCode;
  final DateTime createdAt;
  final List<ReceiptItem> items;
  final int total;

  /// 'cash' | 'qris'
  final String paymentMethod;
  final int amountPaid;
  final int changeAmount;
}

class ReceiptItem {
  const ReceiptItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    this.note,
  });

  final String name;
  final int qty;
  final int unitPrice;
  final int lineTotal;
  final String? note;
}
