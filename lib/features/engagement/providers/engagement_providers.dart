import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../models/engagement_state.dart';
import '../repository/engagement_repository.dart';
import '../service/engagement_service.dart';

final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  return EngagementRepository(ref.watch(apiClientProvider));
});

final engagementServiceProvider = Provider<EngagementService>((ref) {
  return EngagementService(ref.watch(engagementRepositoryProvider));
});

final engagementControllerProvider = AsyncNotifierProvider.autoDispose
    .family<EngagementController, EngagementState, String>(
  EngagementController.new,
);

class EngagementController extends AsyncNotifier<EngagementState> {
  EngagementController(this.postId);

  final String postId;

  int _likeGen = 0;
  int _bookmarkGen = 0;
  int _shareGen = 0;

  @override
  Future<EngagementState> build() {
    return ref.read(engagementServiceProvider).load(postId);
  }

  Future<void> toggleLike() {
    return _toggle(
      gen: () => ++_likeGen,
      currentGen: () => _likeGen,
      apply: (current) {
        final liked = !current.mine.liked;
        return current.copyWith(
          mine: current.mine.copyWith(liked: liked),
          counts: current.counts.copyWith(
            likes: _clamped(current.counts.likes + (liked ? 1 : -1)),
          ),
        );
      },
      persist: (liked) {
        final service = ref.read(engagementServiceProvider);
        return liked ? service.like(postId) : service.unlike(postId);
      },
      isOn: (state) => state.mine.liked,
    );
  }

  Future<void> toggleBookmark() {
    return _toggle(
      gen: () => ++_bookmarkGen,
      currentGen: () => _bookmarkGen,
      apply: (current) {
        final bookmarked = !current.mine.bookmarked;
        return current.copyWith(
          mine: current.mine.copyWith(bookmarked: bookmarked),
          counts: current.counts.copyWith(
            bookmarks:
                _clamped(current.counts.bookmarks + (bookmarked ? 1 : -1)),
          ),
        );
      },
      persist: (bookmarked) {
        final service = ref.read(engagementServiceProvider);
        return bookmarked
            ? service.bookmark(postId)
            : service.unbookmark(postId);
      },
      isOn: (state) => state.mine.bookmarked,
    );
  }

  Future<void> share() async {
    final previous = state.value;
    if (previous == null || previous.mine.shared) return;

    final token = ++_shareGen;
    state = AsyncData(
      previous.copyWith(
        mine: previous.mine.copyWith(shared: true),
        counts: previous.counts.copyWith(shares: previous.counts.shares + 1),
      ),
    );

    try {
      await ref.read(engagementServiceProvider).share(postId);
    } catch (_) {
      if (_shareGen == token) {
        state = AsyncData(previous);
      }
    }
  }

  Future<void> _toggle({
    required int Function() gen,
    required int Function() currentGen,
    required EngagementState Function(EngagementState current) apply,
    required Future<void> Function(bool isOn) persist,
    required bool Function(EngagementState state) isOn,
  }) async {
    final previous = state.value;
    if (previous == null) return;

    final next = apply(previous);
    final token = gen();
    state = AsyncData(next);

    try {
      await persist(isOn(next));
    } catch (_) {
      if (currentGen() == token) {
        state = AsyncData(previous);
      }
    }
  }

  int _clamped(int value) => value < 0 ? 0 : value;
}
