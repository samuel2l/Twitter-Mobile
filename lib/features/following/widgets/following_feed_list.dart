import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/post.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../../../utils/widgets/new_posts_banner.dart';
import '../../../utils/widgets/post_card.dart';
import '../../posts/screens/compose_screen.dart';
import '../../posts/screens/post_detail_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/following_providers.dart';

class FollowingFeedList extends ConsumerStatefulWidget {
  const FollowingFeedList({super.key});

  @override
  ConsumerState<FollowingFeedList> createState() => _FollowingFeedListState();
}

class _FollowingFeedListState extends ConsumerState<FollowingFeedList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(followingFeedControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openCompose(
    BuildContext context, {
    required String type,
    required Post post,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComposeScreen(
          initialType: type,
          replyToId: type == 'reply' ? post.id : null,
          quotedPostId:
              type == 'quote' || type == 'repost' ? post.id : null,
          quotedPreview: post,
        ),
      ),
    );
  }

  String _messageFromError(Object error) {
    if (error is AppException) return error.message;
    return 'Could not load feed';
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(followingFeedControllerProvider);

    return feed.when(
      loading: () => const AppLoading(message: 'Loading feed…'),
      error: (error, _) => AppErrorView(
        message: _messageFromError(error),
        onRetry: () {
          ref.read(followingFeedControllerProvider.notifier).refresh();
        },
      ),
      data: (state) {
        if (state.posts.isEmpty && state.pendingNewCount == 0) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(followingFeedControllerProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Follow people to see posts here')),
              ],
            ),
          );
        }

        return Column(
          children: [
            NewPostsBanner(
              count: state.pendingNewCount,
              onTap: () {
                ref
                    .read(followingFeedControllerProvider.notifier)
                    .applyPendingPosts();
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(followingFeedControllerProvider.notifier)
                    .refresh(),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      state.posts.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.border,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= state.posts.length) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final post = state.posts[index];
                    return PostCard(
                      post: post,
                      showEngagement: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PostDetailScreen(postId: post.id),
                          ),
                        );
                      },
                      onAuthorTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ProfileScreen(userId: post.author.id),
                          ),
                        );
                      },
                      onReply: () =>
                          _openCompose(context, type: 'reply', post: post),
                      onRepost: () =>
                          _openCompose(context, type: 'repost', post: post),
                      onQuote: () =>
                          _openCompose(context, type: 'quote', post: post),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
