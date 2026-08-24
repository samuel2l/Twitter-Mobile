import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post.dart';
import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../../../utils/widgets/post_card.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/posts_providers.dart';
import 'compose_screen.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  final String postId;

  Future<void> _openCompose(
    BuildContext context, {
    required String type,
    String? replyToId,
    String? quotedPostId,
    Post? quotedPreview,
  }) async {
    await Navigator.of(context).push<Post>(
      MaterialPageRoute(
        builder: (_) => ComposeScreen(
          initialType: type,
          replyToId: replyToId,
          quotedPostId: quotedPostId,
          quotedPreview: quotedPreview,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));
    final repliesAsync = ref.watch(postRepliesProvider(postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: postAsync.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorView(
          message: 'Could not load post',
          onRetry: () {
            ref.invalidate(postDetailProvider(postId));
            ref.invalidate(postRepliesProvider(postId));
          },
        ),
        data: (post) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(postDetailProvider(postId));
              ref.invalidate(postRepliesProvider(postId));
            },
            child: ListView(
              children: [
                PostCard(
                  post: post,
                  showEngagement: true,
                  onTap: null,
                  onAuthorTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(userId: post.author.id),
                      ),
                    );
                  },
                  onReply: () {
                    _openCompose(
                      context,
                      type: 'reply',
                      replyToId: post.id,
                      quotedPreview: post,
                    ).then((_) {
                      ref.invalidate(postRepliesProvider(postId));
                    });
                  },
                  onRepost: () {
                    _openCompose(
                      context,
                      type: 'repost',
                      quotedPostId: post.id,
                      quotedPreview: post,
                    );
                  },
                  onQuote: () {
                    _openCompose(
                      context,
                      type: 'quote',
                      quotedPostId: post.id,
                      quotedPreview: post,
                    );
                  },
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Replies',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                repliesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Could not load replies'),
                  ),
                  data: (replies) {
                    if (replies.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No replies yet')),
                      );
                    }

                    return Column(
                      children: [
                        for (final reply in replies)
                          PostCard(
                            post: reply,
                            showEngagement: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PostDetailScreen(postId: reply.id),
                                ),
                              );
                            },
                            onAuthorTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ProfileScreen(userId: reply.author.id),
                                ),
                              );
                            },
                            onReply: () {
                              _openCompose(
                                context,
                                type: 'reply',
                                replyToId: reply.id,
                                quotedPreview: reply,
                              );
                            },
                            onRepost: () {
                              _openCompose(
                                context,
                                type: 'repost',
                                quotedPostId: reply.id,
                                quotedPreview: reply,
                              );
                            },
                            onQuote: () {
                              _openCompose(
                                context,
                                type: 'quote',
                                quotedPostId: reply.id,
                                quotedPreview: reply,
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final post = postAsync.value;
          if (post == null) return;
          _openCompose(
            context,
            type: 'reply',
            replyToId: post.id,
            quotedPreview: post,
          ).then((_) => ref.invalidate(postRepliesProvider(postId)));
        },
        child: const Icon(Icons.reply),
      ),
    );
  }
}
