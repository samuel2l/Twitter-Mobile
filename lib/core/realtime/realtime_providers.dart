import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/following/providers/following_providers.dart';
import '../network/api_client_provider.dart';
import 'realtime_client.dart';
import 'realtime_message.dart';

final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  final client = RealtimeClient(apiClient: ref.watch(apiClientProvider));
  ref.onDispose(client.dispose);
  return client;
});

/// Keeps the WebSocket connected while a session exists and fans messages out.
final realtimeLifecycleProvider = Provider<void>((ref) {
  final session = ref.watch(authControllerProvider).value;
  final client = ref.watch(realtimeClientProvider);

  if (session == null) {
    unawaited(client.stop());
    return;
  }

  unawaited(client.start());

  final subscription = client.messages.listen((message) {
    switch (message) {
      case FollowingNewPostsMessage():
        ref
            .read(followingFeedControllerProvider.notifier)
            .onRealtimeNewPost(message.postId);
      case NotificationRealtimeMessage():
        ref.read(realtimeNotificationCountProvider.notifier).increment();
      case ConnectedMessage() || UnknownRealtimeMessage():
        break;
    }
  });

  ref.onDispose(() {
    unawaited(subscription.cancel());
  });
});

final realtimeNotificationCountProvider =
    NotifierProvider<RealtimeNotificationCount, int>(
  RealtimeNotificationCount.new,
);

class RealtimeNotificationCount extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state += 1;

  void reset() => state = 0;
}
