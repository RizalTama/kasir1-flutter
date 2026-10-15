import 'package:flutter/material.dart';
import '../../core/widgets/empty_state.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        icon: Icons.storefront_outlined,
        title: 'Setup awal akan dibangun di Fase 2',
      ),
    );
  }
}
