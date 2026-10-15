import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/db/providers.dart';
import 'core/db/seed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final container = ProviderContainer();
  if (kDebugMode) {
    await seedDemoData(container.read(databaseProvider));
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
