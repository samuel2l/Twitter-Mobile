sealed class RealtimeMessage {
  const RealtimeMessage();

  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    return switch (type) {
      'connected' => ConnectedMessage(
          userId: json['userId'] as String? ?? '',
        ),
      'following:new_posts' => FollowingNewPostsMessage(
          postId: json['postId'] as String,
          authorId: json['authorId'] as String,
        ),
      'notification:like' ||
      'notification:reply' ||
      'notification:quote' ||
      'notification:repost' ||
      'notification:follow' =>
        NotificationRealtimeMessage(
          type: type!,
          notificationId: json['notificationId'] as String,
          actorId: json['actorId'] as String,
          postId: json['postId'] as String?,
          actorPostId: json['actorPostId'] as String?,
        ),
      _ => UnknownRealtimeMessage(type: type, raw: json),
    };
  }
}

final class ConnectedMessage extends RealtimeMessage {
  const ConnectedMessage({required this.userId});

  final String userId;
}

final class FollowingNewPostsMessage extends RealtimeMessage {
  const FollowingNewPostsMessage({
    required this.postId,
    required this.authorId,
  });

  final String postId;
  final String authorId;
}

final class NotificationRealtimeMessage extends RealtimeMessage {
  const NotificationRealtimeMessage({
    required this.type,
    required this.notificationId,
    required this.actorId,
    this.postId,
    this.actorPostId,
  });

  final String type;
  final String notificationId;
  final String actorId;
  final String? postId;
  final String? actorPostId;
}

final class UnknownRealtimeMessage extends RealtimeMessage {
  const UnknownRealtimeMessage({this.type, required this.raw});

  final String? type;
  final Map<String, dynamic> raw;
}
