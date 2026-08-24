import 'package:flutter_test/flutter_test.dart';

import 'package:twitter/core/realtime/realtime_message.dart';

void main() {
  test('parses following:new_posts', () {
    final message = RealtimeMessage.fromJson({
      'type': 'following:new_posts',
      'postId': 'post-1',
      'authorId': 'user-2',
    });

    expect(message, isA<FollowingNewPostsMessage>());
    final typed = message as FollowingNewPostsMessage;
    expect(typed.postId, 'post-1');
    expect(typed.authorId, 'user-2');
  });

  test('parses notification messages', () {
    final message = RealtimeMessage.fromJson({
      'type': 'notification:like',
      'notificationId': 'n-1',
      'actorId': 'user-2',
      'postId': 'post-1',
    });

    expect(message, isA<NotificationRealtimeMessage>());
    final typed = message as NotificationRealtimeMessage;
    expect(typed.notificationId, 'n-1');
    expect(typed.type, 'notification:like');
  });

  test('parses connected', () {
    final message = RealtimeMessage.fromJson({
      'type': 'connected',
      'userId': 'user-1',
    });

    expect(message, isA<ConnectedMessage>());
  });
}
