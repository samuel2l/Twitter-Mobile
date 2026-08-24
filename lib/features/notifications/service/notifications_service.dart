import '../models/app_notification.dart';
import '../repository/notifications_repository.dart';

class NotificationsService {
  const NotificationsService(this._repository);

  final NotificationsRepository _repository;

  Future<NotificationsPage> list({int limit = 20}) async {
    final data = await _repository.list(limit: limit);
    final itemsJson = data['items'];
    final items = itemsJson is List
        ? itemsJson
            .whereType<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList()
        : <AppNotification>[];

    return NotificationsPage(
      items: items,
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<int> unreadCount() => _repository.unreadCount();

  Future<void> markRead(String id) => _repository.markRead(id);

  Future<void> markAllRead() => _repository.markAllRead();
}
