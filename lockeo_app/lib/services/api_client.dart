import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = _normalizeBaseUrl(baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000'));

  final http.Client _client;
  final String _baseUrl;

  String? _bearerToken;

  void setBearerToken(String? token) {
    _bearerToken = token;
  }

  // Adapte localhost pour les émulateurs
  static String _normalizeBaseUrl(String raw) {
    final uri = Uri.parse(raw);
    final host = uri.host;
    // Si Android emulator et host est localhost, utiliser 10.0.2.2
    // On ne peut pas tester Platform ici sans import dart:io dans web, on gère simple:
    // si host est 'localhost' ou '127.0.0.1', remplace par 10.0.2.2 pour Android via un dart-define optionnel
    const useAndroidEmulatorHost = bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: false);
    if (useAndroidEmulatorHost && (host == 'localhost' || host == '127.0.0.1')) {
      return uri.replace(host: '10.0.2.2').toString();
    }
    return raw;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse(_baseUrl).replace(path: path, queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(
      _uri(path, query),
      headers: _bearerToken != null ? {'Authorization': 'Bearer $_bearerToken'} : null,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.trim();
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Réponse inattendue (objet JSON attendu)');
    }
    throw HttpException('GET $path status=${res.statusCode} body=${res.body}');
  }

  Future<List<dynamic>> getJsonList(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(
      _uri(path, query),
      headers: _bearerToken != null ? {'Authorization': 'Bearer $_bearerToken'} : null,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.trim();
      final decoded = json.decode(body);
      if (decoded is List<dynamic>) return decoded;
      throw FormatException('Réponse inattendue (liste JSON attendue)');
    }
    throw HttpException('GET $path status=${res.statusCode} body=${res.body}');
  }

  Future<Map<String, dynamic>> postJson(String path, {Object? body, Map<String, dynamic>? query}) async {
    final res = await _client.post(
      _uri(path, query),
      headers: {
        'Content-Type': 'application/json',
        if (_bearerToken != null) 'Authorization': 'Bearer $_bearerToken',
      },
      body: body == null ? null : json.encode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Réponse inattendue (objet JSON attendu)');
    }

    throw HttpException('POST $path status=${res.statusCode} body=${res.body}');
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => 'HttpException: $message';
}
