class EngagementCounts {
  const EngagementCounts({
    required this.likes,
    required this.bookmarks,
    required this.shares,
    required this.views,
  });

  final int likes;
  final int bookmarks;
  final int shares;
  final int views;

  factory EngagementCounts.fromJson(Map<String, dynamic> json) {
    return EngagementCounts(
      likes: json['likes'] as int? ?? 0,
      bookmarks: json['bookmarks'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
    );
  }

  EngagementCounts copyWith({
    int? likes,
    int? bookmarks,
    int? shares,
    int? views,
  }) {
    return EngagementCounts(
      likes: likes ?? this.likes,
      bookmarks: bookmarks ?? this.bookmarks,
      shares: shares ?? this.shares,
      views: views ?? this.views,
    );
  }
}

class MyInteractions {
  const MyInteractions({
    required this.liked,
    required this.bookmarked,
    required this.shared,
  });

  final bool liked;
  final bool bookmarked;
  final bool shared;

  factory MyInteractions.fromJson(Map<String, dynamic> json) {
    return MyInteractions(
      liked: json['liked'] as bool? ?? false,
      bookmarked: json['bookmarked'] as bool? ?? false,
      shared: json['shared'] as bool? ?? false,
    );
  }

  MyInteractions copyWith({
    bool? liked,
    bool? bookmarked,
    bool? shared,
  }) {
    return MyInteractions(
      liked: liked ?? this.liked,
      bookmarked: bookmarked ?? this.bookmarked,
      shared: shared ?? this.shared,
    );
  }
}

class EngagementState {
  const EngagementState({
    required this.counts,
    required this.mine,
  });

  final EngagementCounts counts;
  final MyInteractions mine;

  EngagementState copyWith({
    EngagementCounts? counts,
    MyInteractions? mine,
  }) {
    return EngagementState(
      counts: counts ?? this.counts,
      mine: mine ?? this.mine,
    );
  }
}
