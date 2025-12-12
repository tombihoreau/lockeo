/// Stocke le token JWT en mémoire.
///
/// Pour une vraie app, on remplacera ça par un stockage persistant (flutter_secure_storage).
class AuthSession {
  static final AuthSession instance = AuthSession._();
  AuthSession._();

  String? accessToken;
}
