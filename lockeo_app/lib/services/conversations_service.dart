import '../services/api_client.dart';
import '../services/auth_session.dart';

class ConversationListItem {
  final int conversationId;
  final String title;
  final String lastText;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationListItem({
    required this.conversationId,
    required this.title,
    required this.lastText,
    required this.lastMessageAt,
    required this.unreadCount,
  });
}

class ConversationsService {
  ConversationsService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<List<ConversationListItem>> fetchMyConversations() async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      return [];
    }

    _api.setBearerToken(token);
    final data = await _api.getJsonList('/conversations');

    return data
        .whereType<Map>()
        .map((raw) => _fromJson(raw.cast<String, dynamic>()))
        .toList();
  }

  ConversationListItem _fromJson(Map<String, dynamic> json) {
    final conversationId = _toInt(json['conversation_id']) ?? 0;

    final otherUser = json['other_user'];
    String title = 'Utilisateur';
    if (otherUser is Map) {
      final otherUserMap = otherUser.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final login = (otherUserMap['login'] as String?)?.trim();
      final firstName = (otherUserMap['first_name'] as String?)?.trim();
      final lastName = (otherUserMap['last_name'] as String?)?.trim();

      if (login != null && login.isNotEmpty) {
        title = login;
      } else {
        final parts = [firstName, lastName]
            .where((p) => p != null && p.isNotEmpty)
            .cast<String>()
            .toList();
        if (parts.isNotEmpty) {
          title = parts.join(' ');
        }
      }
    }

    final lastMessage = json['last_message'];
    String lastText = 'Aucun message';
    DateTime? lastMessageAt;

    if (lastMessage is Map<String, dynamic>) {
      final text = (lastMessage['text'] as String?)?.trim();
      if (text != null && text.isNotEmpty) {
        lastText = text;
      }

      final createdAtRaw = lastMessage['created_at'];
      if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
        lastMessageAt = DateTime.tryParse(createdAtRaw);
      }
    } else if (lastMessage is Map) {
      final map = lastMessage.map((key, value) => MapEntry(key.toString(), value));
      final text = (map['text'] as String?)?.trim();
      if (text != null && text.isNotEmpty) {
        lastText = text;
      }
      final createdAtRaw = map['created_at'];
      if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
        lastMessageAt = DateTime.tryParse(createdAtRaw);
      }
    }

    final unreadCount = _toInt(json['unread_count']) ?? 0;

    return ConversationListItem(
      conversationId: conversationId,
      title: title,
      lastText: lastText,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
