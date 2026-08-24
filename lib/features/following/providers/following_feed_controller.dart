import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/following_feed_state.dart';
import 'following_providers.dart';

class FollowingFeedController extends AsyncNotifier<FollowingFeedState> {
  final Set<String> _pendingPostIds = {};

  @override
  Future<FollowingFeedState> build() => _loadInitial();

  Future<FollowingFeedState> _loadInitial() async {
    _pendingPostIds.clear();
    final page = await ref.read(followingServiceProvider).getFeed();
    return FollowingFeedState(
      posts: page.items,
      nextCursor: page.nextCursor,
    );
  }

  void onRealtimeNewPost(String postId) {
    final current = state.value;
    if (current == null) return;
    if (_pendingPostIds.contains(postId)) return;
    if (current.posts.any((post) => post.id == postId)) return;

    _pendingPostIds.add(postId);
    state = AsyncData(
      current.copyWith(pendingNewCount: _pendingPostIds.length),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadInitial);
  }

  Future<void> applyPendingPosts() => refresh();

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasMore ||
        state.isLoading) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await ref.read(followingServiceProvider).getFeed(
            cursor: current.nextCursor,
          );

      final existingIds = current.posts.map((post) => post.id).toSet();
      final newPosts = page.items
          .where((post) => !existingIds.contains(post.id))
          .toList();

      state = AsyncData(
        current.copyWith(
          posts: [...current.posts, ...newPosts],
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
