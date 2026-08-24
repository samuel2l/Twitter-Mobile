import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../models/following_feed_state.dart';
import 'following_feed_controller.dart';
import '../repository/following_repository.dart';
import '../service/following_service.dart';

final followingRepositoryProvider = Provider<FollowingRepository>((ref) {
  return FollowingRepository(ref.watch(apiClientProvider));
});

final followingServiceProvider = Provider<FollowingService>((ref) {
  return FollowingService(ref.watch(followingRepositoryProvider));
});

final followingFeedControllerProvider =
    AsyncNotifierProvider<FollowingFeedController, FollowingFeedState>(
  FollowingFeedController.new,
);
