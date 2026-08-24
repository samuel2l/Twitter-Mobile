import '../../../core/models/post.dart';

class FollowingFeedState {
  const FollowingFeedState({
    required this.posts,
    this.nextCursor,
    this.isLoadingMore = false,
    this.pendingNewCount = 0,
  });

  final List<Post> posts;
  final String? nextCursor;
  final bool isLoadingMore;
  final int pendingNewCount;

  bool get hasMore => nextCursor != null;

  FollowingFeedState copyWith({
    List<Post>? posts,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
    int? pendingNewCount,
  }) {
    return FollowingFeedState(
      posts: posts ?? this.posts,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pendingNewCount: pendingNewCount ?? this.pendingNewCount,
    );
  }
}
