import 'package:astron_kasir/core/db/app_database.dart';
import 'package:astron_kasir/core/db/providers.dart';
import 'package:astron_kasir/core/strings.dart';
import 'package:astron_kasir/features/checkout/checkout_screen.dart';
import 'package:astron_kasir/features/pos/cart_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'tombol Selesai & Cetak Nota nonaktif sampai uang diterima mencukupi',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      container
          .read(cartProvider.notifier)
          .addProduct(
            Product(
              id: 1,
              name: 'Kopi Susu',
              price: 20000,
              categoryId: null,
              imagePath: null,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CheckoutScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final finishButton = find.widgetWithText(
        ElevatedButton,
        AppStrings.selesaiCetakNota,
      );
      expect(finishButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(finishButton).onPressed, isNull);

      await tester.enterText(find.byType(TextField).first, '15000');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(finishButton).onPressed, isNull);

      await tester.enterText(find.byType(TextField).first, '20000');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(finishButton).onPressed, isNotNull);
    },
  );
}
