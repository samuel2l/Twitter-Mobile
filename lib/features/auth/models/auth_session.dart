import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.sessionId,
  });

  final AuthUser user;
  final String sessionId;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Missing user in session response');
    }

    final sessionJson = json['session'];
    final sessionId = sessionJson is Map<String, dynamic>
        ? sessionJson['id'] as String? ?? ''
        : '';

    return AuthSession(
      user: AuthUser.fromJson(userJson),
      sessionId: sessionId,
    );
  }
}
