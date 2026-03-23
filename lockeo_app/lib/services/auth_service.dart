import 'api_client.dart';
import 'app_notifications_realtime_service.dart';
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

    // Récupère le profil minimal pour l’UI (prénom/nom)
    await _fetchAndStoreMe();
    await AppNotificationsRealtimeService.instance.ensureConnected();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final decoded = await _api.postJson('/auth/login', body: {
      'email': email,
      'password': password,
    });

    final token = decoded['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Réponse inattendue (accessToken manquant)');
    }

    AuthSession.instance.accessToken = token;

    // Récupère le profil minimal pour l’UI (prénom/nom)
    await _fetchAndStoreMe();
    await AppNotificationsRealtimeService.instance.ensureConnected();
  }

  Future<void> _fetchAndStoreMe() async {
    _api.setBearerToken(AuthSession.instance.accessToken);
    final me = await _api.getJson('/auth/me');

    AuthSession.instance.userId = me['userId'] is int
        ? me['userId'] as int
        : int.tryParse('${me['userId']}');
    AuthSession.instance.firstName = (me['firstName'] as String?)?.trim();
    AuthSession.instance.lastName = (me['lastName'] as String?)?.trim();
  }
}
