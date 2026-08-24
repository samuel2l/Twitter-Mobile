import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../models/social_user.dart';
import '../repository/social_repository.dart';
import '../service/social_service.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(ref.watch(apiClientProvider));
});

final socialServiceProvider = Provider<SocialService>((ref) {
  return SocialService(ref.watch(socialRepositoryProvider));
});

final socialUserProvider =
    FutureProvider.autoDispose.family<SocialUser, String>((ref, userId) {
  return ref.watch(socialServiceProvider).getUser(userId);
});

final followStatusProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) {
  return ref.watch(socialServiceProvider).isFollowing(userId);
});

final followActionsProvider = Provider<FollowActions>((ref) {
  return FollowActions(ref);
});

class FollowActions {
  FollowActions(this._ref);

  final Ref _ref;

  Future<void> toggle(String userId) async {
    final current = await _ref.read(followStatusProvider(userId).future);
    if (current) {
      await _ref.read(socialServiceProvider).unfollow(userId);
    } else {
      await _ref.read(socialServiceProvider).follow(userId);
    }
    _ref.invalidate(followStatusProvider(userId));
  }
}

final followersProvider =
    FutureProvider.autoDispose.family<List<SocialUser>, String>((ref, userId) {
  return ref.watch(socialServiceProvider).getFollowers(userId);
});

final followingProvider =
    FutureProvider.autoDispose.family<List<SocialUser>, String>((ref, userId) {
  return ref.watch(socialServiceProvider).getFollowing(userId);
});
