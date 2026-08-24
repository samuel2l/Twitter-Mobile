import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/explore_feed_page.dart';
import '../models/explore_feed_state.dart';
import 'explore_providers.dart';

class ExploreFeedController extends AsyncNotifier<ExploreFeedState> {
  final Set<String> _pendingImpressions = {};
  Timer? _flushTimer;

  @override
  Future<ExploreFeedState> build() {
    ref.onDispose(() {
      _flushTimer?.cancel();
      unawaited(_flushImpressions());
    });
    return _loadInitial();
  }

  Future<ExploreFeedState> _loadInitial() async {
    final page = await ref.read(exploreServiceProvider).getFeed();
    final state = _stateFromPage(page);
    await _updateNewCount(state);
    return state;
  }

  ExploreFeedState _stateFromPage(ExploreFeedPage page) {
    return ExploreFeedState(
      posts: page.items,
      sessionId: page.sessionId,
      nextCursor: page.nextCursor,
      tier: page.tier,
      source: page.source,
    );
  }

  void markImpression(String postId) {
    if (_pendingImpressions.contains(postId)) return;
    _pendingImpressions.add(postId);
    _scheduleFlush();
  }

  void _scheduleFlush() {
    _flushTimer ??= Timer(const Duration(seconds: 3), () {
      unawaited(_flushImpressions());
    });
  }

  Future<void> _flushImpressions() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_pendingImpressions.isEmpty) return;

    final batch = _pendingImpressions.take(50).toList();
    _pendingImpressions.removeAll(batch);

    try {
      await ref.read(exploreServiceProvider).recordImpressions(batch);
    } catch (_) {
      _pendingImpressions.addAll(batch);
    }

    if (_pendingImpressions.isNotEmpty) {
      _scheduleFlush();
    }
  }

  Future<void> _updateNewCount(ExploreFeedState state) async {
    if (state.sessionId.isEmpty) return;

    try {
      final result =
          await ref.read(exploreServiceProvider).getNewCount(state.sessionId);
      final current = this.state.value;
      if (current == null) return;

      this.state = AsyncData(current.copyWith(newCount: result.count));
    } catch (_) {
      // Best-effort — banner is optional.
    }
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isRefreshing: true, newCount: 0));
    } else {
      state = const AsyncLoading();
    }

    state = await AsyncValue.guard(() async {
      final page = await ref.read(exploreServiceProvider).refreshFeed();
      return _stateFromPage(page);
    });
  }

  Future<void> checkForNewPosts() async {
    final current = state.value;
    if (current == null || current.sessionId.isEmpty) return;
    await _updateNewCount(current);
  }

  Future<void> applyNewPosts() => refresh();

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
      final page = await ref.read(exploreServiceProvider).getFeed(
            cursor: current.nextCursor,
            sessionId: current.sessionId,
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
          sessionId: page.sessionId,
          tier: page.tier,
          source: page.source,
          isLoadingMore: false,
        ),
      );

      await _updateNewCount(state.value!);
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
