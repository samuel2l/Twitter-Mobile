import '../config/app_env.dart';

abstract final class ApiConstants {
  static String get baseUrl => AppEnv.apiBaseUrl;

  static String get websocketUrl {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/ws',
    ).toString();
  }

  static const session = '/api/session';
  static const me = '/api/me';

  static const signInEmail = '/api/auth/sign-in/email';
  static const signUpEmail = '/api/auth/sign-up/email';
  static const signOut = '/api/auth/sign-out';
  static const signInSocial = '/api/auth/sign-in/social';

  static String get googleClientId => AppEnv.googleClientId;

  static const followingFeed = '/api/timeline/following';
  static const forYouFeed = '/api/timeline/for-you';
  static const forYouNewCount = '/api/timeline/for-you/new-count';
  static const forYouRefresh = '/api/timeline/for-you/refresh';
  static const timelineImpressions = '/api/timeline/impressions';

  static const posts = '/api/posts';
  static String postById(String id) => '/api/posts/$id';
  static String postReplies(String id) => '/api/posts/$id/replies';
  static String postsByUser(String userId) => '/api/posts/user/$userId';

  static const mediaUpload = '/api/media/upload';

  static String like(String postId) => '/api/posts/$postId/like';
  static String bookmark(String postId) => '/api/posts/$postId/bookmark';
  static String share(String postId) => '/api/posts/$postId/share';
  static String myInteractions(String postId) =>
      '/api/posts/$postId/interactions/me';
  static String interactionCounts(String postId) =>
      '/api/posts/$postId/interactions';

  static String follow(String userId) => '/api/social/follow/$userId';
  static String followStatus(String userId) =>
      '/api/social/following/$userId/status';
  static String followers(String userId) => '/api/social/followers/$userId';
  static String following(String userId) => '/api/social/following/$userId';
  static String socialUser(String userId) => '/api/social/users/$userId';

  static const notifications = '/api/notifications';
  static const notificationsUnreadCount = '/api/notifications/unread-count';
  static const notificationsReadAll = '/api/notifications/read-all';
  static String notificationRead(String id) => '/api/notifications/$id/read';

  static const topics = '/api/topics';
  static const onboardingStatus = '/api/onboarding/status';
  static const onboardingInterests = '/api/onboarding/interests';

  static const devices = '/api/devices';
  static const devicesUnregister = '/api/devices/unregister';

  static const health = '/health';
}
