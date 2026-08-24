import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/post_author.dart';
import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../../../utils/widgets/user_avatar.dart';
import '../../auth/providers/auth_providers.dart';
import '../../profile/screens/profile_screen.dart';
import '../models/social_user.dart';
import '../providers/social_providers.dart';
import '../widgets/follow_button.dart';

enum FollowListMode { followers, following }

class FollowListScreen extends ConsumerWidget {
  const FollowListScreen({
    super.key,
    required this.userId,
    required this.mode,
  });

  final String userId;
  final FollowListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = mode == FollowListMode.followers
        ? ref.watch(followersProvider(userId))
        : ref.watch(followingProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == FollowListMode.followers ? 'Followers' : 'Following',
        ),
      ),
      body: asyncUsers.when(
        loading: () => const AppLoading(),
        error: (_, __) => AppErrorView(
          message: 'Could not load list',
          onRetry: () {
            if (mode == FollowListMode.followers) {
              ref.invalidate(followersProvider(userId));
            } else {
              ref.invalidate(followingProvider(userId));
            }
          },
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Text(
                mode == FollowListMode.followers
                    ? 'No followers yet'
                    : 'Not following anyone yet',
              ),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserTile(user: user);
            },
          );
        },
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});

  final SocialUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).value?.user.id;
    final isSelf = me == user.id;

    return ListTile(
      leading: UserAvatar(
        author: PostAuthor(id: user.id, name: user.name, image: user.image),
      ),
      title: Text(user.name),
      trailing: isSelf ? null : FollowButton(userId: user.id),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProfileScreen(userId: user.id),
          ),
        );
      },
    );
  }
}
