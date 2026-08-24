import 'package:flutter_test/flutter_test.dart';

import 'package:twitter/features/explore/models/explore_feed_page.dart';

void main() {
  test('ExploreFeedPage.fromJson parses for-you feed', () {
    final page = ExploreFeedPage.fromJson({
      'sessionId': 'session-1',
      'nextCursor': 'personalized:20',
      'tier': 'personalized',
      'source': 'recommended',
      'items': [
        {
          'id': 'post-1',
          'userId': 'user-1',
          'text': 'Explore post',
          'type': 'original',
          'createdAt': '2026-01-15T12:00:00.000Z',
          'author': {
            'id': 'user-1',
            'name': 'Sam',
            'image': null,
          },
          'media': [],
        },
      ],
    });

    expect(page.sessionId, 'session-1');
    expect(page.items, hasLength(1));
    expect(page.items.first.displayText, 'Explore post');
    expect(page.nextCursor, 'personalized:20');
    expect(page.source, 'recommended');
  });
}
