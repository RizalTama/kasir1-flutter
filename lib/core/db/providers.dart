import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final categoryDaoProvider = Provider((ref) => ref.watch(databaseProvider).categoryDao);
final productDaoProvider = Provider((ref) => ref.watch(databaseProvider).productDao);
final transactionDaoProvider = Provider((ref) => ref.watch(databaseProvider).transactionDao);
final storeSettingsDaoProvider = Provider((ref) => ref.watch(databaseProvider).storeSettingsDao);

/// Status onboarding toko, dipakai redirect di [appRouterProvider].
final onboardingDoneProvider = StreamProvider<bool>((ref) {
  return ref.watch(storeSettingsDaoProvider).watch().map((s) => s.onboardingDone);
});

/// Baris store_settings secara utuh, dipakai layar Pengaturan Toko & Kasir.
final storeSettingsStreamProvider = StreamProvider((ref) {
  return ref.watch(storeSettingsDaoProvider).watch();
});
