import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../../home/screens/home_screen.dart';
import '../providers/onboarding_providers.dart';
import '../screens/onboarding_screen.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingStatusProvider);

    return status.when(
      loading: () => const Scaffold(
        body: AppLoading(message: 'Checking onboarding…'),
      ),
      error: (_, __) => Scaffold(
        body: AppErrorView(
          message: 'Could not load onboarding status',
          onRetry: () => ref.invalidate(onboardingStatusProvider),
        ),
      ),
      data: (value) {
        if (!value.completed) return const OnboardingScreen();
        return const HomeScreen();
      },
    );
  }
}
