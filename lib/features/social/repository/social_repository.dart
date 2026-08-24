import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class SocialRepository {
  const SocialRepository(this._client);

  final ApiClient _client;

  Future<void> follow(String userId) async {
    await _client.post<Map<String, dynamic>>(ApiConstants.follow(userId));
  }

  Future<void> unfollow(String userId) async {
    await _client.delete<void>(ApiConstants.follow(userId));
  }

  Future<Map<String, dynamic>> followStatus(String userId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.followStatus(userId),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.socialUser(userId),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getFollowers(String userId, {int limit = 50}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.followers(userId),
      queryParameters: {'limit': limit},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getFollowing(String userId, {int limit = 50}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.following(userId),
      queryParameters: {'limit': limit},
    );
    return response.data ?? {};
  }
}
