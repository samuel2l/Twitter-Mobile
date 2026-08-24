import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../network/api_client_provider.dart';
import 'devices_repository.dart';
import 'push_service.dart';

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  return DevicesRepository(ref.watch(apiClientProvider));
});

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService(ref.watch(devicesRepositoryProvider));
});

/// Registers / unregisters the FCM token with auth session changes.
final pushLifecycleProvider = Provider<void>((ref) {
  final session = ref.watch(authControllerProvider).value;
  final push = ref.watch(pushServiceProvider);

  if (session == null) {
    unawaited(push.unregisterCurrentDevice());
    return;
  }

  unawaited(push.registerCurrentDevice());
});
