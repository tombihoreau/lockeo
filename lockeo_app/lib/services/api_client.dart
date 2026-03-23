import 'dart:convert';
import 'package:http/http.dart' as http;

import 'backend_config.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? BackendConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  String? _bearerToken;

  void setBearerToken(String? token) {
    _bearerToken = token;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final baseUri = Uri.parse(_baseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final baseSegments = baseUri.pathSegments.where((segment) => segment.isNotEmpty);
    final pathSegments = normalizedPath.isEmpty
        ? const <String>[]
        : normalizedPath.split('/').where((segment) => segment.isNotEmpty);

    return baseUri.replace(
      pathSegments: [...baseSegments, ...pathSegments],
      queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _client.get(
      _uri(path, query),
      headers: _bearerToken != null
          ? {'Authorization': 'Bearer $_bearerToken'}
          : null,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.trim();
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw FormatException('Réponse inattendue (objet JSON attendu)');
    }
    throw HttpException('GET $path status=${res.statusCode} body=${res.body}');
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _client.get(
      _uri(path, query),
      headers: _bearerToken != null
          ? {'Authorization': 'Bearer $_bearerToken'}
          : null,
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.trim();
      final decoded = json.decode(body);
      if (decoded is List<dynamic>) return decoded;
      throw FormatException('Réponse inattendue (liste JSON attendue)');
    }
    throw HttpException('GET $path status=${res.statusCode} body=${res.body}');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
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

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    final res = await _client.patch(
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

    throw HttpException(
      'PATCH $path status=${res.statusCode} body=${res.body}',
    );
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => 'HttpException: $message';
}
