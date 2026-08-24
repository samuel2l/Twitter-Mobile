import '../../../core/errors/app_exception.dart';
import '../../../core/models/post.dart';

class ExploreFeedPage {
  const ExploreFeedPage({
    required this.items,
    required this.sessionId,
    this.nextCursor,
    this.tier,
    this.source,
  });

  final List<Post> items;
  final String sessionId;
  final String? nextCursor;
  final String? tier;
  final String? source;

  bool get hasMore => nextCursor != null;

  factory ExploreFeedPage.fromJson(Map<String, dynamic> data) {
    try {
      final itemsJson = data['items'];
      final items = itemsJson is List
          ? itemsJson
              .whereType<Map<String, dynamic>>()
              .map(Post.fromJson)
              .toList()
          : <Post>[];

      final sessionId = data['sessionId'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw const FormatException('Missing sessionId in for-you response');
      }

      return ExploreFeedPage(
        items: items,
        sessionId: sessionId,
        nextCursor: data['nextCursor'] as String?,
        tier: data['tier'] as String?,
        source: data['source'] as String?,
      );
    } on FormatException catch (error) {
      throw ParseException('Invalid for-you feed response: $error');
    }
  }
}

class ExploreNewCount {
  const ExploreNewCount({
    required this.count,
    required this.sessionId,
  });

  final int count;
  final String sessionId;
}
