import '../../../core/models/post.dart';

class FollowingFeedPage {
  const FollowingFeedPage({
    required this.items,
    this.nextCursor,
  });

  final List<Post> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}
