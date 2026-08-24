import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../core/realtime/realtime_providers.dart';
import '../models/app_notification.dart';
import '../repository/notifications_repository.dart';
import '../service/notifications_service.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(apiClientProvider));
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService(ref.watch(notificationsRepositoryProvider));
});

final notificationsListProvider =
    FutureProvider.autoDispose<NotificationsPage>((ref) {
  ref.watch(realtimeNotificationCountProvider);
  return ref.watch(notificationsServiceProvider).list();
});

final notificationsUnreadCountProvider =
    FutureProvider.autoDispose<int>((ref) {
  ref.watch(realtimeNotificationCountProvider);
  return ref.watch(notificationsServiceProvider).unreadCount();
});

final notificationsActionsProvider = Provider<NotificationsActions>((ref) {
  return NotificationsActions(ref);
});

class NotificationsActions {
  NotificationsActions(this._ref);

  final Ref _ref;

  Future<void> markRead(String id) async {
    await _ref.read(notificationsServiceProvider).markRead(id);
    _ref.invalidate(notificationsListProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
  }

  Future<void> markAllRead() async {
    await _ref.read(notificationsServiceProvider).markAllRead();
    _ref.read(realtimeNotificationCountProvider.notifier).reset();
    _ref.invalidate(notificationsListProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
  }
}
