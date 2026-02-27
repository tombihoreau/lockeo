import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/message.dart';

class ChatSocketService {
  ChatSocketService({String? baseUrl})
      : _baseUrl = _normalizeBaseUrl(
          baseUrl ??
              const String.fromEnvironment(
                'WS_BASE_URL',
                defaultValue: 'http://localhost:3000',
              ),
        );

  final String _baseUrl;
  io.Socket? _socket;

  final _historyController = StreamController<ConversationHistoryEvent>.broadcast();
  final _newMessageController = StreamController<ConversationMessageEvent>.broadcast();
  final _typingController = StreamController<ConversationTypingEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  bool get isConnected => _socket?.connected == true;

  Stream<ConversationHistoryEvent> get historyStream => _historyController.stream;
  Stream<ConversationMessageEvent> get newMessageStream => _newMessageController.stream;
  Stream<ConversationTypingEvent> get typingStream => _typingController.stream;
  Stream<String> get errorStream => _errorController.stream;

  static String _normalizeBaseUrl(String raw) {
    final uri = Uri.parse(raw);
    final host = uri.host;
    const useAndroidEmulatorHost = bool.fromEnvironment(
      'ANDROID_EMULATOR',
      defaultValue: false,
    );

    if (useAndroidEmulatorHost && (host == 'localhost' || host == '127.0.0.1')) {
      return uri.replace(host: '10.0.2.2').toString();
    }
    return raw;
  }

  Future<void> connect({required String token}) async {
    if (token.trim().isEmpty) {
      throw const FormatException('Token JWT manquant pour le websocket');
    }

    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    final socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {});

    socket.on('conversation:history', (payload) {
      try {
        final map = _toMap(payload);
        final conversationId = _readInt(map, 'conversationId');
        final list = map['messages'];
        if (conversationId == null || list is! List) {
          throw const FormatException('Payload conversation:history invalide');
        }

        final messages = list
            .whereType<Map>()
            .map((raw) => _messageFromWs(raw.cast<String, dynamic>()))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        _historyController.add(
          ConversationHistoryEvent(conversationId: conversationId, messages: messages),
        );
      } catch (e) {
        _errorController.add(e.toString());
      }
    });

    socket.on('conversation:new_message', (payload) {
      try {
        final map = _toMap(payload);
        final conversationId = _readInt(map, 'conversationId');
        final messageMap = map['message'];

        if (conversationId == null || messageMap is! Map) {
          throw const FormatException('Payload conversation:new_message invalide');
        }

        final message = _messageFromWs(messageMap.cast<String, dynamic>());
        _newMessageController.add(
          ConversationMessageEvent(conversationId: conversationId, message: message),
        );
      } catch (e) {
        _errorController.add(e.toString());
      }
    });

    socket.on('chat:error', (payload) {
      if (payload is Map && payload['message'] is String) {
        _errorController.add(payload['message'] as String);
        return;
      }
      _errorController.add('Erreur websocket');
    });

    socket.on('conversation:typing', (payload) {
      try {
        final map = _toMap(payload);
        final conversationId = _readInt(map, 'conversationId');
        final senderUserId = _readInt(map, 'senderUserId');
        final isTyping = map['isTyping'];
        if (conversationId == null || senderUserId == null || isTyping is! bool) {
          throw const FormatException('Payload conversation:typing invalide');
        }
        _typingController.add(
          ConversationTypingEvent(
            conversationId: conversationId,
            senderUserId: senderUserId,
            isTyping: isTyping,
          ),
        );
      } catch (e) {
        _errorController.add(e.toString());
      }
    });

    socket.onConnectError((error) => _errorController.add(error.toString()));
    socket.onError((error) => _errorController.add(error.toString()));

    socket.connect();
    _socket = socket;

    await _waitForConnection(socket);
  }

  void joinConversation(int conversationId) {
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  void leaveConversation(int conversationId) {
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  void sendMessage({required int conversationId, required String text}) {
    _socket?.emit('conversation:send', {
      'conversationId': conversationId,
      'text': text,
    });
  }

  void emitTyping({required int conversationId, required bool isTyping}) {
    _socket?.emit('conversation:typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _historyController.close();
    _newMessageController.close();
    _typingController.close();
    _errorController.close();
  }

  Future<void> _waitForConnection(io.Socket socket) {
    final completer = Completer<void>();

    if (socket.connected) {
      completer.complete();
      return completer.future;
    }

    late final void Function(dynamic) onError;
    late final void Function(dynamic) onConnect;

    onConnect = (_) {
      socket.off('connect_error', onError);
      completer.complete();
    };

    onError = (err) {
      socket.off('connect', onConnect);
      if (!completer.isCompleted) {
        completer.completeError(Exception(err.toString()));
      }
    };

    socket.once('connect', onConnect);
    socket.once('connect_error', onError);

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        socket.off('connect', onConnect);
        socket.off('connect_error', onError);
        throw TimeoutException('Connexion websocket expirée');
      },
    );
  }

  static Map<String, dynamic> _toMap(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }
    throw const FormatException('Payload websocket invalide');
  }

  static int? _readInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static Message _messageFromWs(Map<String, dynamic> json) {
    return Message(
      messageId: _readInt(json, 'message_id') ?? 0,
      conversationId: _readInt(json, 'conversation_id') ?? 0,
      senderUserId: _readInt(json, 'sender_user_id') ?? 0,
      text: (json['text'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'sent',
      createdAt: DateTime.parse(
        (json['created_at'] as String?) ?? DateTime.now().toUtc().toIso8601String(),
      ),
      readAt: json['read_at'] is String ? DateTime.parse(json['read_at'] as String) : null,
    );
  }
}

class ConversationHistoryEvent {
  final int conversationId;
  final List<Message> messages;

  ConversationHistoryEvent({
    required this.conversationId,
    required this.messages,
  });
}

class ConversationMessageEvent {
  final int conversationId;
  final Message message;

  ConversationMessageEvent({
    required this.conversationId,
    required this.message,
  });
}

class ConversationTypingEvent {
  final int conversationId;
  final int senderUserId;
  final bool isTyping;

  ConversationTypingEvent({
    required this.conversationId,
    required this.senderUserId,
    required this.isTyping,
  });
}
