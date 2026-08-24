import '../../../core/auth/google_auth_service.dart';
import '../../../core/errors/app_exception.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../repository/auth_repository.dart';

class AuthService {
  const AuthService(this._repository);

  final AuthRepository _repository;

  Future<AuthSession?> getSession() async {
    final data = await _repository.getSession();
    if (data == null) return null;

    try {
      return AuthSession.fromJson(data);
    } on FormatException {
      throw const ParseException('Invalid session response');
    }
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final data = await _repository.signIn(email: email, password: password);
    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      return AuthSession(user: AuthUser.fromJson(userJson), sessionId: '');
    }

    final session = await getSession();
    if (session == null) {
      throw const ParseException('Signed in but session was not returned');
    }
    return session;
  }

  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _repository.signUp(
      name: name,
      email: email,
      password: password,
    );

    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      return AuthSession(user: AuthUser.fromJson(userJson), sessionId: '');
    }

    final session = await getSession();
    if (session == null) {
      throw const ParseException('Signed up but session was not returned');
    }
    return session;
  }

  Future<void> signOut() => _repository.signOut();

  Future<AuthSession> signInWithGoogle() {
    return GoogleAuthService(_repository).signIn();
  }
}
