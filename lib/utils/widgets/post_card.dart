import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../../features/engagement/widgets/engagement_bar.dart';
import '../extensions/datetime_extensions.dart';
import '../theme/app_colors.dart';
import 'user_avatar.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onAuthorTap,
    this.onReply,
    this.onRepost,
    this.onQuote,
    this.showEngagement = false,
  });

  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onQuote;
  final bool showEngagement;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onAuthorTap,
              child: UserAvatar(author: post.author),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onAuthorTap,
                    child: _Header(post: post),
                  ),
                  if (post.isRepost) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reposted',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (post.displayText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.displayText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (post.hasMedia) ...[
                    const SizedBox(height: 12),
                    _MediaGrid(media: post.media),
                  ],
                  if (post.showsQuotedPost) ...[
                    const SizedBox(height: 12),
                    _QuotedPostCard(post: post.quotedPost!),
                  ],
                  if (showEngagement)
                    EngagementBar(
                      postId: post.id,
                      compact: true,
                      onReply: onReply,
                      onRepost: onRepost,
                      onQuote: onQuote,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 2,
      children: [
        Text(
          post.author.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          '· ${post.createdAt.toRelativeString()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.media});

  final List<PostMedia> media;

  @override
  Widget build(BuildContext context) {
    if (media.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _MediaTile(item: media.first),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length.clamp(0, 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _MediaTile(item: media[index]),
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item});

  final PostMedia item;

  @override
  Widget build(BuildContext context) {
    if (item.isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.surface),
          const Center(
            child: Icon(Icons.play_circle_outline, size: 48),
          ),
        ],
      );
    }

    return Image.network(
      item.url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}

class _QuotedPostCard extends StatelessWidget {
  const _QuotedPostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.author.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
          ),
          if (post.displayText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              post.displayText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onBackground,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
