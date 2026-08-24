import '../models/explore_feed_page.dart';
import '../repository/explore_repository.dart';

class ExploreService {
  const ExploreService(this._repository);

  final ExploreRepository _repository;

  Future<ExploreFeedPage> getFeed({
    String? cursor,
    String? sessionId,
    int limit = 20,
    bool refresh = false,
  }) async {
    final data = await _repository.fetchFeed(
      cursor: cursor,
      sessionId: sessionId,
      limit: limit,
      refresh: refresh,
    );
    return ExploreFeedPage.fromJson(data);
  }

  Future<ExploreFeedPage> refreshFeed() async {
    final data = await _repository.refreshFeed();
    return ExploreFeedPage.fromJson(data);
  }

  Future<ExploreNewCount> getNewCount(String sessionId) async {
    final data = await _repository.fetchNewCount(sessionId);

    return ExploreNewCount(
      count: data['count'] as int? ?? 0,
      sessionId: data['sessionId'] as String? ?? sessionId,
    );
  }

  Future<void> recordImpressions(List<String> postIds) async {
    await _repository.recordImpressions(postIds);
  }
}
