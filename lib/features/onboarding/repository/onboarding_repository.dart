import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class OnboardingRepository {
  const OnboardingRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.onboardingStatus,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> setInterests(List<String> topicIds) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.onboardingInterests,
      data: {'topicIds': topicIds},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> listTopics() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.topics,
    );
    return response.data ?? {};
  }
}
