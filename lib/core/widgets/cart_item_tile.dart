import 'package:flutter/material.dart';
import '../theme/app_text.dart';
import '../utils/money.dart';
import 'product_thumbnail.dart';
import 'qty_stepper.dart';

/// Baris item keranjang: thumbnail, nama, catatan, subtotal mono,
/// [QtyStepper] (§4.4).
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.imagePath,
    required this.name,
    required this.note,
    required this.qty,
    required this.lineTotal,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEditNote,
  });

  final String? imagePath;
  final String name;
  final String? note;
  final int qty;
  final int lineTotal;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEditNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductThumbnail(imagePath: imagePath, size: 52),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppText.bodyStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: onEditNote,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    note == null || note!.isEmpty ? '+ Tambah catatan' : note!,
                    style: AppText.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(formatRupiah(lineTotal), style: AppText.money),
            ],
          ),
        ),
        const SizedBox(width: 8),
        QtyStepper(
          qty: qty,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
      ],
    );
  }
}
