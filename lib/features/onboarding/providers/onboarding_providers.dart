import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../models/topic.dart';
import '../repository/onboarding_repository.dart';
import '../service/onboarding_service.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(apiClientProvider));
});

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref.watch(onboardingRepositoryProvider));
});

final onboardingStatusProvider =
    FutureProvider.autoDispose<OnboardingStatus>((ref) {
  return ref.watch(onboardingServiceProvider).getStatus();
});

final topicsProvider = FutureProvider.autoDispose<List<Topic>>((ref) {
  return ref.watch(onboardingServiceProvider).listTopics();
});

final onboardingSubmitProvider =
    AsyncNotifierProvider<OnboardingSubmitController, void>(
  OnboardingSubmitController.new,
);

class OnboardingSubmitController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(List<String> topicIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(onboardingServiceProvider).setInterests(topicIds);
      ref.invalidate(onboardingStatusProvider);
    });
  }
}
