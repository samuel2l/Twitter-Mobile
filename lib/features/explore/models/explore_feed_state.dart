import '../../../core/models/post.dart';

class ExploreFeedState {
  const ExploreFeedState({
    required this.posts,
    required this.sessionId,
    this.nextCursor,
    this.tier,
    this.source,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.newCount = 0,
  });

  final List<Post> posts;
  final String sessionId;
  final String? nextCursor;
  final String? tier;
  final String? source;
  final bool isLoadingMore;
  final bool isRefreshing;
  final int newCount;

  bool get hasMore => nextCursor != null;

  ExploreFeedState copyWith({
    List<Post>? posts,
    String? sessionId,
    String? nextCursor,
    bool clearNextCursor = false,
    String? tier,
    String? source,
    bool? isLoadingMore,
    bool? isRefreshing,
    int? newCount,
  }) {
    return ExploreFeedState(
      posts: posts ?? this.posts,
      sessionId: sessionId ?? this.sessionId,
      nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
      tier: tier ?? this.tier,
      source: source ?? this.source,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      newCount: newCount ?? this.newCount,
    );
  }
}
