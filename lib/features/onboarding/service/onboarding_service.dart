import '../models/topic.dart';
import '../repository/onboarding_repository.dart';

class OnboardingService {
  const OnboardingService(this._repository);

  final OnboardingRepository _repository;

  Future<OnboardingStatus> getStatus() async {
    final data = await _repository.getStatus();
    return OnboardingStatus.fromJson(data);
  }

  Future<List<Topic>> listTopics() async {
    final data = await _repository.listTopics();
    final items = data['items'];
    if (items is! List) return const [];
    return items.whereType<Map<String, dynamic>>().map(Topic.fromJson).toList();
  }

  Future<void> setInterests(List<String> topicIds) async {
    await _repository.setInterests(topicIds);
  }
}
