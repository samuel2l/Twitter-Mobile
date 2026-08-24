import '../models/engagement_state.dart';
import '../repository/engagement_repository.dart';

class EngagementService {
  const EngagementService(this._repository);

  final EngagementRepository _repository;

  Future<EngagementState> load(String postId) async {
    EngagementCounts counts = const EngagementCounts(
      likes: 0,
      bookmarks: 0,
      shares: 0,
      views: 0,
    );
    MyInteractions mine = const MyInteractions(
      liked: false,
      bookmarked: false,
      shared: false,
    );

    try {
      counts = EngagementCounts.fromJson(await _repository.counts(postId));
    } catch (_) {
      // Counts are optional — still show action buttons.
    }

    try {
      mine = MyInteractions.fromJson(await _repository.mine(postId));
    } catch (_) {
      // Unauthenticated or transient errors should not hide the bar.
    }

    return EngagementState(counts: counts, mine: mine);
  }

  Future<void> like(String postId) => _repository.like(postId);

  Future<void> unlike(String postId) => _repository.unlike(postId);

  Future<void> bookmark(String postId) => _repository.bookmark(postId);

  Future<void> unbookmark(String postId) => _repository.unbookmark(postId);

  Future<void> share(String postId) => _repository.share(postId);
}
