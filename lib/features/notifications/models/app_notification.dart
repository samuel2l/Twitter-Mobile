import '../../../core/models/post_author.dart';

enum NotificationType {
  like,
  reply,
  quote,
  repost,
  follow;

  static NotificationType fromJson(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NotificationType.like,
    );
  }

  String get label {
    return switch (this) {
      NotificationType.like => 'liked your post',
      NotificationType.reply => 'replied to your post',
      NotificationType.quote => 'quoted your post',
      NotificationType.repost => 'reposted your post',
      NotificationType.follow => 'followed you',
    };
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.actor,
    this.postId,
    this.actorPostId,
    this.readAt,
  });

  final String id;
  final NotificationType type;
  final DateTime createdAt;
  final PostAuthor actor;
  final String? postId;
  final String? actorPostId;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.fromJson(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      actor: PostAuthor.fromJson(json['actor'] as Map<String, dynamic>),
      postId: json['postId'] as String?,
      actorPostId: json['actorPostId'] as String?,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
    );
  }
}

class NotificationsPage {
  const NotificationsPage({
    required this.items,
    this.nextCursor,
  });

  final List<AppNotification> items;
  final String? nextCursor;
}
