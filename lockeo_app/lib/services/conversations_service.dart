import '../services/api_client.dart';
import '../services/auth_session.dart';
import '../models/message.dart';

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

class ConversationParticipant {
  final int userId;
  final String? login;
  final String? firstName;
  final String? lastName;

  const ConversationParticipant({
    required this.userId,
    this.login,
    this.firstName,
    this.lastName,
  });

  String get displayName {
    final safeLogin = login?.trim();
    if (safeLogin != null && safeLogin.isNotEmpty) return safeLogin;

    final parts = [firstName, lastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .map((p) => p!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    return 'Utilisateur';
  }
}

class ConversationSnapshot {
  final ConversationParticipant? otherUser;
  final List<Message> messages;
  final ConversationReservationContext? reservationContext;

  const ConversationSnapshot({
    required this.otherUser,
    required this.messages,
    required this.reservationContext,
  });
}

class ConversationReservationContext {
  final int reservationId;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final int totalDays;
  final int offerId;
  final int ownerUserId;
  final String productTitle;
  final String cityLabel;
  final String postalCodeLabel;
  final double pricePerDay;
  final String? imagePath;

  const ConversationReservationContext({
    required this.reservationId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.totalDays,
    required this.offerId,
    required this.ownerUserId,
    required this.productTitle,
    required this.cityLabel,
    required this.postalCodeLabel,
    required this.pricePerDay,
    required this.imagePath,
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

  Future<int> ensureConversationWithUser({required int otherUserId}) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    _api.setBearerToken(token);
    final json = await _api.postJson(
      '/conversations/ensure',
      body: {'otherUserId': otherUserId},
    );

    final conversationId = _toInt(json['conversation_id']);
    if (conversationId == null || conversationId <= 0) {
      throw const FormatException('Réponse invalide: conversation_id manquant');
    }
    return conversationId;
  }

  Future<ConversationSnapshot> fetchConversationSnapshot({
    required int conversationId,
  }) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    _api.setBearerToken(token);
    final rows = await _api.getJsonList('/conversations');
    final row = rows
        .whereType<Map>()
        .map((r) => r.cast<String, dynamic>())
        .firstWhere(
          (r) => _toInt(r['conversation_id']) == conversationId,
          orElse: () => <String, dynamic>{},
        );

    ConversationParticipant? otherUser;
    ConversationReservationContext? reservationContext;
    final otherRaw = row['other_user'];
    if (otherRaw is Map) {
      final other = otherRaw.map((k, v) => MapEntry(k.toString(), v));
      final userId = _toInt(other['user_id']);
      if (userId != null) {
        otherUser = ConversationParticipant(
          userId: userId,
          login: (other['login'] as String?)?.trim(),
          firstName: (other['first_name'] as String?)?.trim(),
          lastName: (other['last_name'] as String?)?.trim(),
        );
      }
    }

    final reservationRaw = row['reservation'];
    if (reservationRaw is Map) {
      final reservationMap = reservationRaw.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final productRaw = reservationMap['product'];
      final productMap = productRaw is Map
          ? productRaw.map((key, value) => MapEntry(key.toString(), value))
          : const <String, dynamic>{};

      final reservationId = _toInt(reservationMap['reservation_id']);
      final offerId = _toInt(reservationMap['offer_id']);
      final ownerUserId = _toInt(reservationMap['owner_user_id']);
      final totalDays = _toInt(reservationMap['total_days']);
      final startDateRaw = reservationMap['start_date'];
      final endDateRaw = reservationMap['end_date'];

      if (reservationId != null &&
          offerId != null &&
          ownerUserId != null &&
          totalDays != null &&
          startDateRaw is String &&
          endDateRaw is String) {
        reservationContext = ConversationReservationContext(
          reservationId: reservationId,
          status: (reservationMap['status'] as String?)?.trim() ?? 'pending',
          startDate: DateTime.parse(startDateRaw),
          endDate: DateTime.parse(endDateRaw),
          totalPrice: _toDouble(reservationMap['final_price']),
          totalDays: totalDays,
          offerId: offerId,
          ownerUserId: ownerUserId,
          productTitle: (productMap['name'] as String?)?.trim() ?? '',
          cityLabel: (productMap['city'] as String?)?.trim() ?? '',
          postalCodeLabel: (productMap['postal_code'] as String?)?.trim() ?? '',
          pricePerDay: _toDouble(productMap['price_per_day']),
          imagePath: (productMap['image_uri'] as String?)?.trim(),
        );
      }
    }

    final messageRows = await _api.getJsonList(
      '/conversations/$conversationId/messages',
    );
    final messages =
        messageRows
            .whereType<Map>()
            .map((raw) => _messageFromJson(raw.cast<String, dynamic>()))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ConversationSnapshot(
      otherUser: otherUser,
      messages: messages,
      reservationContext: reservationContext,
    );
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
        final parts = [
          firstName,
          lastName,
        ].where((p) => p != null && p.isNotEmpty).cast<String>().toList();
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
      final map = lastMessage.map(
        (key, value) => MapEntry(key.toString(), value),
      );
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
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }

  Message _messageFromJson(Map<String, dynamic> json) {
    return Message(
      messageId: _toInt(json['message_id']) ?? 0,
      conversationId: _toInt(json['conversation_id']) ?? 0,
      senderUserId: _toInt(json['sender_user_id']) ?? 0,
      text: (json['text'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'sent',
      createdAt: DateTime.parse(
        (json['created_at'] as String?) ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      readAt: json['read_at'] is String
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }
}
