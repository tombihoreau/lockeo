import 'dart:async';

import 'auth_session.dart';
import 'chat_socket_service.dart';

class AppNotificationsRealtimeService {
  AppNotificationsRealtimeService._();

  static final AppNotificationsRealtimeService instance =
      AppNotificationsRealtimeService._();

  final ChatSocketService _chatSocketService = ChatSocketService();
  final StreamController<ChatNotificationEvent> _controller =
      StreamController<ChatNotificationEvent>.broadcast();

  StreamSubscription<ChatNotificationEvent>? _notificationSub;
  StreamSubscription<String>? _errorSub;
  Timer? _reconnectTimer;

  bool _isConnecting = false;
  bool _isConnected = false;
  String? _connectedToken;

  Stream<ChatNotificationEvent> get notificationsStream => _controller.stream;

  Future<void> ensureConnected() async {
    final token = AuthSession.instance.accessToken?.trim();
    if (token == null || token.isEmpty) return;

    if (_isConnected && _connectedToken == token) return;
    if (_isConnecting) return;

    _isConnecting = true;
    try {
      _notificationSub ??=
          _chatSocketService.notificationStream.listen(_controller.add);
      _errorSub ??= _chatSocketService.errorStream.listen((_) {
        _isConnected = false;
        _scheduleReconnect();
      });

      await _chatSocketService.connect(token: token);
      _connectedToken = token;
      _isConnected = true;
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    } catch (_) {
      _isConnected = false;
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;
    _reconnectTimer = Timer(const Duration(seconds: 2), () async {
      _reconnectTimer = null;
      await ensureConnected();
    });
  }
}
