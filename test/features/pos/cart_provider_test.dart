import 'package:astron_kasir/core/db/app_database.dart';
import 'package:astron_kasir/core/widgets/product_card.dart';
import 'package:astron_kasir/features/pos/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product({int id = 1, String name = 'Kopi Susu', int price = 18000}) {
  final now = DateTime.now();
  return Product(
    id: id,
    name: name,
    price: price,
    categoryId: null,
    imagePath: null,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CartNotifier', () {
    test('tambah produk yang sama menaikkan qty, bukan baris baru', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(cartProvider.notifier);

      notifier.addProduct(_product());
      notifier.addProduct(_product());

      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.qty, 2);
      expect(container.read(cartTotalProvider), 36000);
      expect(container.read(cartItemCountProvider), 2);
    });

    test('decrement sampai 0 menghapus item dari keranjang', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(cartProvider.notifier);

      notifier.addProduct(_product());
      notifier.decrement(1);

      expect(container.read(cartProvider), isEmpty);
      expect(container.read(cartTotalProvider), 0);
    });
  });

  testWidgets('ketuk ProductCard -> badge jumlah & total keranjang benar', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final product = _product();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                // Proporsi sama seperti GridView (childAspectRatio: 0.7)
                // di layar Kasir sungguhan.
                width: 160,
                height: 160 / 0.7,
                child: Consumer(
                  builder: (context, ref, _) {
                    final qty = ref.watch(
                      cartQtyForProductProvider(product.id),
                    );
                    return ProductCard(
                      name: product.name,
                      price: product.price,
                      imagePath: product.imagePath,
                      qtyInCart: qty,
                      onTap: () =>
                          ref.read(cartProvider.notifier).addProduct(product),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('2'), findsNothing);

    await tester.tap(find.byType(ProductCard));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(container.read(cartTotalProvider), 18000);

    await tester.tap(find.byType(ProductCard));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(container.read(cartTotalProvider), 36000);
  });
}
