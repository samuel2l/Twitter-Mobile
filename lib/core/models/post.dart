import 'post_author.dart';

enum PostType {
  original,
  reply,
  quote,
  repost;

  static PostType fromJson(String value) {
    return PostType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PostType.original,
    );
  }
}

class PostMedia {
  const PostMedia({
    required this.id,
    required this.url,
    required this.type,
    required this.sortOrder,
  });

  final String id;
  final String url;
  final String type;
  final int sortOrder;

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  bool get isVideo => type == 'video';
}

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.author,
    required this.media,
    this.replyToId,
    this.quotedPostId,
    this.quotedPost,
  });

  final String id;
  final String userId;
  final String? text;
  final PostType type;
  final DateTime createdAt;
  final PostAuthor author;
  final List<PostMedia> media;
  final String? replyToId;
  final String? quotedPostId;
  final Post? quotedPost;

  factory Post.fromJson(Map<String, dynamic> json) {
    final mediaJson = json['media'];
    final List<PostMedia> media;
    if (mediaJson is List) {
      media = mediaJson
          .whereType<Map<String, dynamic>>()
          .map(PostMedia.fromJson)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } else {
      media = <PostMedia>[];
    }

    final quotedJson = json['quotedPost'];
    final quotedPost = quotedJson is Map<String, dynamic>
        ? Post.fromJson(quotedJson)
        : null;

    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String?,
      type: PostType.fromJson(json['type'] as String? ?? 'original'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: PostAuthor.fromJson(json['author'] as Map<String, dynamic>),
      media: media,
      replyToId: json['replyToId'] as String?,
      quotedPostId: json['quotedPostId'] as String?,
      quotedPost: quotedPost,
    );
  }

  String get displayText => text?.trim() ?? '';

  bool get hasMedia => media.isNotEmpty;

  bool get isRepost => type == PostType.repost;

  bool get showsQuotedPost => quotedPost != null;
}
