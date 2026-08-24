import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twitter/app.dart';
import 'package:twitter/core/push/push_providers.dart';
import 'package:twitter/core/realtime/realtime_providers.dart';
import 'package:twitter/features/auth/models/auth_session.dart';
import 'package:twitter/features/auth/models/auth_user.dart';
import 'package:twitter/features/auth/providers/auth_controller.dart';
import 'package:twitter/features/auth/providers/auth_providers.dart';
import 'package:twitter/features/explore/models/explore_feed_state.dart';
import 'package:twitter/features/explore/providers/explore_feed_controller.dart';
import 'package:twitter/features/explore/providers/explore_providers.dart';
import 'package:twitter/features/following/models/following_feed_state.dart';
import 'package:twitter/features/following/providers/following_feed_controller.dart';
import 'package:twitter/features/following/providers/following_providers.dart';
import 'package:twitter/features/notifications/providers/notifications_providers.dart';
import 'package:twitter/features/onboarding/models/topic.dart';
import 'package:twitter/features/onboarding/providers/onboarding_providers.dart';

class _LoggedOutAuthController extends AuthController {
  @override
  Future<AuthSession?> build() async => null;
}

class _LoggedInAuthController extends AuthController {
  @override
  Future<AuthSession?> build() async {
    return const AuthSession(
      user: AuthUser(
        id: 'user-1',
        name: 'Sam',
        email: 'sam@example.com',
      ),
      sessionId: 'session-1',
    );
  }
}

class _EmptyFollowingFeedController extends FollowingFeedController {
  @override
  Future<FollowingFeedState> build() async {
    return const FollowingFeedState(posts: []);
  }
}

class _EmptyExploreFeedController extends ExploreFeedController {
  @override
  Future<ExploreFeedState> build() async {
    return const ExploreFeedState(posts: [], sessionId: 'session-1');
  }
}

void main() {
  testWidgets('shows login when logged out', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_LoggedOutAuthController.new),
        ],
        child: const TwitterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in to Twitter'), findsOneWidget);
  });

  testWidgets('shows home tabs when logged in', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_LoggedInAuthController.new),
          followingFeedControllerProvider.overrideWith(
            _EmptyFollowingFeedController.new,
          ),
          exploreFeedControllerProvider.overrideWith(
            _EmptyExploreFeedController.new,
          ),
          onboardingStatusProvider.overrideWith(
            (ref) async => const OnboardingStatus(completed: true),
          ),
          notificationsUnreadCountProvider.overrideWith(
            (ref) async => 0,
          ),
          realtimeLifecycleProvider.overrideWith((ref) {}),
          pushLifecycleProvider.overrideWith((ref) {}),
        ],
        child: const TwitterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
