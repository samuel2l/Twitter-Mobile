import '../../../core/network/api_client.dart';
import '../../../utils/constants/api_constants.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>?> getSession() async {
    final response = await _client.get<Map<String, dynamic>?>(
      ApiConstants.session,
    );
    final data = response.data;
    if (data == null) return null;
    return data;
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.signInEmail,
      data: {
        'email': email,
        'password': password,
        'rememberMe': true,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.signUpEmail,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return response.data ?? {};
  }

  Future<void> signOut() async {
    await _client.post<void>(ApiConstants.signOut);
  }

  Future<Map<String, dynamic>> signInWithGoogle({
    required String idToken,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.signInSocial,
      data: {
        'provider': 'google',
        'idToken': {'token': idToken},
      },
    );
    return response.data ?? {};
  }
}
