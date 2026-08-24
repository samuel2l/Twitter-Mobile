import 'package:flutter_test/flutter_test.dart';

import 'package:twitter/core/models/post.dart';

void main() {
  group('Post.fromJson', () {
    test('parses a post with media and quoted post', () {
      final post = Post.fromJson({
        'id': 'post-1',
        'userId': 'user-1',
        'text': 'Hello world',
        'type': 'quote',
        'replyToId': null,
        'quotedPostId': 'post-2',
        'createdAt': '2026-01-15T12:00:00.000Z',
        'author': {
          'id': 'user-1',
          'name': 'Sam',
          'image': null,
        },
        'media': [
          {
            'id': 'media-1',
            'url': 'https://example.com/image.jpg',
            'type': 'image',
            'sortOrder': 0,
          },
        ],
        'quotedPost': {
          'id': 'post-2',
          'userId': 'user-2',
          'text': 'Quoted text',
          'type': 'original',
          'createdAt': '2026-01-14T12:00:00.000Z',
          'author': {
            'id': 'user-2',
            'name': 'Alex',
            'image': null,
          },
          'media': [],
        },
      });

      expect(post.id, 'post-1');
      expect(post.author.name, 'Sam');
      expect(post.media, hasLength(1));
      expect(post.quotedPost?.text, 'Quoted text');
      expect(post.type, PostType.quote);
    });
  });
}
