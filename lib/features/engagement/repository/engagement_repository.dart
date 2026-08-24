import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class EngagementRepository {
  const EngagementRepository(this._client);

  final ApiClient _client;

  Future<void> like(String postId) async {
    await _client.post<Map<String, dynamic>>(ApiConstants.like(postId));
  }

  Future<void> unlike(String postId) async {
    await _client.delete<void>(ApiConstants.like(postId));
  }

  Future<void> bookmark(String postId) async {
    await _client.post<Map<String, dynamic>>(ApiConstants.bookmark(postId));
  }

  Future<void> unbookmark(String postId) async {
    await _client.delete<void>(ApiConstants.bookmark(postId));
  }

  Future<void> share(String postId) async {
    await _client.post<Map<String, dynamic>>(ApiConstants.share(postId));
  }

  Future<Map<String, dynamic>> mine(String postId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.myInteractions(postId),
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> counts(String postId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.interactionCounts(postId),
    );
    return response.data ?? {};
  }
}
