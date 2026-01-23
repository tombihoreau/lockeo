import 'api_client.dart';
import 'auth_session.dart';

class AuthService {
  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirm,
  }) async {
    final decoded = await _api.postJson('/auth/register', body: {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'passwordConfirm': passwordConfirm,
    });

    final token = decoded['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Réponse inattendue (accessToken manquant)');
    }

    AuthSession.instance.accessToken = token;
  }
}
