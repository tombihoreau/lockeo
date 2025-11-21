import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse(_baseUrl).replace(path: path, queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri(path, query));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.trim();
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Réponse inattendue (objet JSON attendu)');
    }
    throw HttpException('GET $path status=${res.statusCode} body=${res.body}');
  }

  Future<List<dynamic>> getJsonList(String path, {Map<String, dynamic>? query}) async {
    final res = await _client.get(_uri(path, query));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.trim();
      final decoded = json.decode(body);
      if (decoded is List<dynamic>) return decoded;
      throw FormatException('Réponse inattendue (liste JSON attendue)');
    }
    throw HttpException('GET $path status=${res.statusCode} body=${res.body}');
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => 'HttpException: $message';
}
