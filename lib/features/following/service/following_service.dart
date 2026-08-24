import '../../../core/errors/app_exception.dart';
import '../../../core/models/post.dart';
import '../models/following_feed_page.dart';
import '../repository/following_repository.dart';

class FollowingService {
  const FollowingService(this._repository);

  final FollowingRepository _repository;

  Future<FollowingFeedPage> getFeed({
    String? cursor,
    int limit = 20,
  }) async {
    final data = await _repository.fetchFeed(cursor: cursor, limit: limit);

    try {
      final itemsJson = data['items'];
      final items = itemsJson is List
          ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(Post.fromJson)
              .toList()
          : <Post>[];

      return FollowingFeedPage(
        items: items,
        nextCursor: data['nextCursor'] as String?,
      );
    } on FormatException catch (error) {
      throw ParseException('Invalid following feed response: $error');
    }
  }
}
