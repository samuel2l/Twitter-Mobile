import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/theme/app_colors.dart';
import '../models/engagement_state.dart';
import '../providers/engagement_providers.dart';

class EngagementBar extends ConsumerWidget {
  const EngagementBar({
    super.key,
    required this.postId,
    this.onReply,
    this.onRepost,
    this.onQuote,
    this.compact = false,
  });

  final String postId;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onQuote;
  final bool compact;

  static const _emptyState = EngagementState(
    counts: EngagementCounts(
      likes: 0,
      bookmarks: 0,
      shares: 0,
      views: 0,
    ),
    mine: MyInteractions(
      liked: false,
      bookmarked: false,
      shared: false,
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engagement = ref.watch(engagementControllerProvider(postId));
    final controller = ref.read(engagementControllerProvider(postId).notifier);

    return engagement.when(
      loading: () => _Bar(
        state: _emptyState,
        compact: compact,
        onReply: onReply,
        onRepost: onRepost,
        onQuote: onQuote,
      ),
      error: (_, __) => _Bar(
        state: _emptyState,
        compact: compact,
        onReply: onReply,
        onRepost: onRepost,
        onQuote: onQuote,
        onToggleLike: controller.toggleLike,
        onToggleBookmark: controller.toggleBookmark,
        onShare: controller.share,
      ),
      data: (state) => _Bar(
        state: state,
        compact: compact,
        onReply: onReply,
        onRepost: onRepost,
        onQuote: onQuote,
        onToggleLike: controller.toggleLike,
        onToggleBookmark: controller.toggleBookmark,
        onShare: controller.share,
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.state,
    required this.compact,
    this.onReply,
    this.onRepost,
    this.onQuote,
    this.onToggleLike,
    this.onToggleBookmark,
    this.onShare,
  });

  final EngagementState state;
  final bool compact;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onQuote;
  final VoidCallback? onToggleLike;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onShare;

  void _showRepostSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Repost'),
                onTap: () {
                  Navigator.pop(context);
                  onRepost?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_quote),
                title: const Text('Quote'),
                onTap: () {
                  Navigator.pop(context);
                  onQuote?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: compact ? 8 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Action(
            icon: Icons.chat_bubble_outline,
            onTap: onReply,
          ),
          _Action(
            icon: state.mine.liked ? Icons.favorite : Icons.favorite_border,
            color: state.mine.liked ? AppColors.error : null,
            label: '${state.counts.likes}',
            onTap: onToggleLike,
          ),
          _Action(
            icon: Icons.repeat,
            onTap: () => _showRepostSheet(context),
          ),
          _Action(
            icon: state.mine.bookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: state.mine.bookmarked ? AppColors.primary : null,
            label: '${state.counts.bookmarks}',
            onTap: onToggleBookmark,
          ),
          _Action(
            icon: Icons.ios_share,
            label: '${state.counts.shares}',
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.onTap,
    this.label,
    this.color,
  });

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? AppColors.onBackgroundMuted),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
