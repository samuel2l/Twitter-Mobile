import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class FollowingRepository {
  const FollowingRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchFeed({
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.followingFeed,
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return response.data ?? {};
  }
}
