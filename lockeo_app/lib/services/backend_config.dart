import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendConfig {
  BackendConfig._();

  static const String _defaultRemoteApiBaseUrl =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://jules.demai.rennes.mds-project.fr/lockeo/api',
      );
  static const String _defaultRemoteWsBaseUrl =
      String.fromEnvironment(
        'WS_BASE_URL',
        defaultValue: 'http://jules.demai.rennes.mds-project.fr',
      );
  static const bool _useAndroidEmulatorHost = bool.fromEnvironment(
    'ANDROID_EMULATOR',
    defaultValue: false,
  );

  static String _resolvedApiBaseUrl = _defaultRemoteApiBaseUrl;
  static String _resolvedWsBaseUrl = _defaultRemoteWsBaseUrl;
  static bool _initialized = false;

  static String get apiBaseUrl => _resolvedApiBaseUrl;
  static String get wsBaseUrl => _resolvedWsBaseUrl;

  static bool get isLocalEnvironment {
    final apiHost = Uri.parse(_resolvedApiBaseUrl).host;
    final wsHost = Uri.parse(_resolvedWsBaseUrl).host;
    return _isLocalHost(apiHost) || _isLocalHost(wsHost);
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    final localTargets = _preferredLocalTargets()
        .map(
          (target) => (
            api: _normalizedBaseUrl(target.apiBaseUrl),
            ws: _normalizedBaseUrl(target.wsBaseUrl),
          ),
        )
        .toList();

    String? resolvedLocalApiBaseUrl;
    String? resolvedLocalWsBaseUrl;

    for (final target in localTargets) {
      final isReachable = await _isBackendReachable(target.api);
      if (isReachable) {
        resolvedLocalApiBaseUrl = target.api;
        resolvedLocalWsBaseUrl = target.ws;
        break;
      }
    }

    _resolvedApiBaseUrl =
        resolvedLocalApiBaseUrl ?? _normalizedBaseUrl(_defaultRemoteApiBaseUrl);
    _resolvedWsBaseUrl =
        resolvedLocalWsBaseUrl ?? _normalizedBaseUrl(_defaultRemoteWsBaseUrl);
    _initialized = true;
  }

  static List<({String apiBaseUrl, String wsBaseUrl})> _preferredLocalTargets() {
    if (kIsWeb) {
      return const [
        (
          apiBaseUrl: 'http://localhost:3000/api',
          wsBaseUrl: 'http://localhost:3000',
        ),
      ];
    }
    return const [
      (
        apiBaseUrl: 'http://127.0.0.1:3000/api',
        wsBaseUrl: 'http://127.0.0.1:3000',
      ),
      (
        apiBaseUrl: 'http://localhost:3000/api',
        wsBaseUrl: 'http://localhost:3000',
      ),
    ];
  }

  static String _normalizedBaseUrl(String raw) {
    final uri = Uri.parse(raw);
    final host = uri.host;

    if (_useAndroidEmulatorHost &&
        (host == 'localhost' || host == '127.0.0.1')) {
      return uri.replace(host: '10.0.2.2').toString();
    }
    return raw;
  }

  static bool _isLocalHost(String host) {
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }

  static Future<bool> _isBackendReachable(String apiBaseUrl) async {
    final client = http.Client();
    try {
      final healthUri = Uri.parse('$apiBaseUrl/health');
      final response = await client
          .get(healthUri)
          .timeout(const Duration(seconds: 2));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }
}
