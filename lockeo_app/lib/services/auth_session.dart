/// Stocke le token JWT en mémoire.
///
/// Pour une vraie app, on remplacera ça par un stockage persistant (flutter_secure_storage).
class AuthSession {
  static final AuthSession instance = AuthSession._();
  AuthSession._();

  String? accessToken;

  /// Profil minimal en mémoire pour afficher le prénom/nom dans l’UI.
  /// (À persister plus tard si nécessaire.)
  String? firstName;
  String? lastName;

  String get displayName {
    final parts = [firstName, lastName]
        .where((e) => e != null && e.trim().isNotEmpty)
        .map((e) => e!.trim())
        .toList();
    return parts.isEmpty ? '' : parts.join(' ');
  }
}
