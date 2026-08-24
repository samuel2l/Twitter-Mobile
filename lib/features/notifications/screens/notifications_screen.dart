import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../../posts/screens/post_detail_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../models/app_notification.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(notificationsListProvider);
      ref.invalidate(notificationsUnreadCountProvider);
    });
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    if (notification.isUnread) {
      await ref.read(notificationsActionsProvider).markRead(notification.id);
    }

    if (!context.mounted) return;

    if (notification.type == NotificationType.follow) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProfileScreen(userId: notification.actor.id),
        ),
      );
      return;
    }

    final postId = notification.postId ?? notification.actorPostId;
    if (postId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PostDetailScreen(postId: postId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsActionsProvider).markAllRead();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const AppLoading(message: 'Loading notifications…'),
        error: (_, __) => AppErrorView(
          message: 'Could not load notifications',
          onRetry: () => ref.invalidate(notificationsListProvider),
        ),
        data: (page) {
          if (page.items.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsListProvider);
              ref.invalidate(notificationsUnreadCountProvider);
            },
            child: ListView.separated(
              itemCount: page.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = page.items[index];
                return NotificationTile(
                  notification: item,
                  onTap: () => _openNotification(context, ref, item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
