import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/success_screen.dart';
import '../../features/export/export_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/pos/cart_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/printer/printer_screen.dart';
import '../../features/products/categories_screen.dart';
import '../../features/products/product_form_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../db/providers.dart';
import '../layout/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _GoRouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/pos',
    refreshListenable: refresh,
    redirect: (context, state) {
      final done = ref.read(onboardingDoneProvider).asData?.value;
      if (done == null) return null;
      final atSetup = state.matchedLocation == '/setup';
      if (!done && !atSetup) return '/setup';
      if (done && atSetup) return '/pos';
      return null;
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, _) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/pos', builder: (_, _) => const PosScreen()),
          GoRoute(path: '/pos/cart', builder: (_, _) => const CartScreen()),
          GoRoute(
            path: '/pos/checkout',
            builder: (_, _) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '/pos/success/:trxId',
            builder: (_, state) =>
                SuccessScreen(trxId: state.pathParameters['trxId']!),
          ),
          GoRoute(
            path: '/products',
            builder: (_, _) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/products/new',
            builder: (_, _) => const ProductFormScreen(),
          ),
          GoRoute(
            path: '/products/categories',
            builder: (_, _) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/products/:id',
            builder: (_, state) =>
                ProductFormScreen(productId: state.pathParameters['id']),
          ),
          GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
          GoRoute(
            path: '/reports/export',
            builder: (_, _) => const ExportScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, _) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/printer',
            builder: (_, _) => const PrinterScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Memicu go_router mengevaluasi ulang [GoRouter.redirect] saat status
/// onboarding berubah, tanpa membangun ulang instance [GoRouter].
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    _sub = ref.listen(onboardingDoneProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription<AsyncValue<bool>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
