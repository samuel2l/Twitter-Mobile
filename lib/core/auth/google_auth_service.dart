import 'package:google_sign_in/google_sign_in.dart';

import '../errors/app_exception.dart';
import '../../features/auth/models/auth_session.dart';
import '../../features/auth/models/auth_user.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../utils/constants/api_constants.dart';

class GoogleAuthService {
  GoogleAuthService(this._repository);

  final AuthRepository _repository;

  static Future<void>? _initFuture;

  Future<void> _ensureInitialized() {
    if (ApiConstants.googleClientId.isEmpty) {
      return Future.error(
        const NetworkException(
          'Google sign-in requires GOOGLE_CLIENT_ID dart-define',
        ),
      );
    }

    return _initFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: ApiConstants.googleClientId,
    );
  }

  Future<AuthSession> signIn() async {
    await _ensureInitialized();

    GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const NetworkException('Google sign-in cancelled');
      }
      throw NetworkException(error.description ?? 'Google sign-in failed');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ParseException('Google did not return an ID token');
    }

    final data = await _repository.signInWithGoogle(idToken: idToken);
    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      return AuthSession(user: AuthUser.fromJson(userJson), sessionId: '');
    }

    final session = await _repository.getSession();
    if (session == null) {
      throw const ParseException('Signed in but session was not returned');
    }
    return AuthSession.fromJson(session);
  }
}
