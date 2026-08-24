import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class NotificationsRepository {
  const NotificationsRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> list({int limit = 20}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {'limit': limit},
    );
    return response.data ?? {};
  }

  Future<int> unreadCount() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.notificationsUnreadCount,
    );
    return response.data?['count'] as int? ?? 0;
  }

  Future<void> markRead(String id) async {
    await _client.post<void>(ApiConstants.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _client.post<void>(ApiConstants.notificationsReadAll);
  }
}
