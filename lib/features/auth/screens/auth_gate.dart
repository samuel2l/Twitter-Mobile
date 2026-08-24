import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/push/push_providers.dart';
import '../../../core/realtime/realtime_providers.dart';
import '../../onboarding/screens/onboarding_gate.dart';
import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../providers/auth_providers.dart';
import '../screens/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return auth.when(
      loading: () => const Scaffold(body: AppLoading(message: 'Loading…')),
      error: (error, _) => Scaffold(
        body: AppErrorView(
          message: 'Could not load session',
          onRetry: () {
            ref.read(authControllerProvider.notifier).refreshSession();
          },
        ),
      ),
      data: (session) {
        if (session == null) return const LoginScreen();

        ref.watch(realtimeLifecycleProvider);
        ref.watch(pushLifecycleProvider);

        return const OnboardingGate();
      },
    );
  }
}
