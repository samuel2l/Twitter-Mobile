import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post_author.dart';
import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../../../utils/widgets/post_card.dart';
import '../../../utils/widgets/user_avatar.dart';
import '../../auth/providers/auth_providers.dart';
import '../../posts/providers/posts_providers.dart';
import '../../posts/screens/compose_screen.dart';
import '../../posts/screens/post_detail_screen.dart';
import '../../social/providers/social_providers.dart';
import '../../social/screens/follow_list_screen.dart';
import '../../social/widgets/follow_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value;
    final isSelf = session?.user.id == userId;
    final userAsync = ref.watch(socialUserProvider(userId));
    final postsAsync = ref.watch(userPostsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: userAsync.maybeWhen(
          data: (user) => Text(user.name),
          orElse: () => const Text('Profile'),
        ),
      ),
      body: userAsync.when(
        loading: () => const AppLoading(),
        error: (_, __) => AppErrorView(
          message: 'Could not load profile',
          onRetry: () => ref.invalidate(socialUserProvider(userId)),
        ),
        data: (user) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(socialUserProvider(userId));
              ref.invalidate(userPostsProvider(userId));
              ref.invalidate(followersProvider(userId));
              ref.invalidate(followingProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(
                              author: PostAuthor(
                                id: user.id,
                                name: user.name,
                                image: user.image,
                              ),
                              radius: 32,
                            ),
                            const Spacer(),
                            if (!isSelf) FollowButton(userId: userId),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => FollowListScreen(
                                      userId: userId,
                                      mode: FollowListMode.following,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Following'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => FollowListScreen(
                                      userId: userId,
                                      mode: FollowListMode.followers,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Followers'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider(height: 1)),
                postsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Could not load posts'),
                    ),
                  ),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('No posts yet')),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            showEngagement: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      PostDetailScreen(postId: post.id),
                                ),
                              );
                            },
                            onReply: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ComposeScreen(
                                    initialType: 'reply',
                                    replyToId: post.id,
                                    quotedPreview: post,
                                  ),
                                ),
                              );
                            },
                            onRepost: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ComposeScreen(
                                    initialType: 'repost',
                                    quotedPostId: post.id,
                                    quotedPreview: post,
                                  ),
                                ),
                              );
                            },
                            onQuote: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ComposeScreen(
                                    initialType: 'quote',
                                    quotedPostId: post.id,
                                    quotedPreview: post,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
