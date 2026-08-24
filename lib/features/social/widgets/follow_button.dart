import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/theme/app_colors.dart';
import '../providers/social_providers.dart';

class FollowButton extends ConsumerWidget {
  const FollowButton({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(followStatusProvider(userId));

    return status.when(
      loading: () => const SizedBox(
        width: 88,
        height: 32,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => OutlinedButton(
        onPressed: () {
          ref.invalidate(followStatusProvider(userId));
        },
        child: const Text('Retry'),
      ),
      data: (following) {
        if (following) {
          return OutlinedButton(
            onPressed: () {
              ref.read(followActionsProvider).toggle(userId);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onBackground,
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('Following'),
          );
        }

        return FilledButton(
          onPressed: () {
            ref.read(followActionsProvider).toggle(userId);
          },
          child: const Text('Follow'),
        );
      },
    );
  }
}
