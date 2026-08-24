import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class ExploreRepository {
  const ExploreRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchFeed({
    String? cursor,
    String? sessionId,
    int limit = 20,
    bool refresh = false,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.forYouFeed,
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (sessionId != null) 'sessionId': sessionId,
        if (refresh) 'refresh': 'true',
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> fetchNewCount(String sessionId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.forYouNewCount,
      queryParameters: {'sessionId': sessionId},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> refreshFeed() async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.forYouRefresh,
    );
    return response.data ?? {};
  }

  Future<void> recordImpressions(List<String> postIds) async {
    await _client.post<void>(
      ApiConstants.timelineImpressions,
      data: {
        'postIds': postIds,
        'feedType': 'for_you',
      },
    );
  }
}
