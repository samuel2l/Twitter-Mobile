import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post.dart';
import '../../../utils/widgets/post_card.dart';
import '../providers/explore_providers.dart';

class ExploreImpressionPostCard extends ConsumerStatefulWidget {
  const ExploreImpressionPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onAuthorTap,
    this.onReply,
    this.onRepost,
    this.onQuote,
  });

  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onQuote;

  @override
  ConsumerState<ExploreImpressionPostCard> createState() =>
      _ExploreImpressionPostCardState();
}

class _ExploreImpressionPostCardState
    extends ConsumerState<ExploreImpressionPostCard> {
  var _recorded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _recorded) return;
      _recorded = true;
      ref
          .read(exploreFeedControllerProvider.notifier)
          .markImpression(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: widget.post,
      showEngagement: true,
      onTap: widget.onTap,
      onAuthorTap: widget.onAuthorTap,
      onReply: widget.onReply,
      onRepost: widget.onRepost,
      onQuote: widget.onQuote,
    );
  }
}
