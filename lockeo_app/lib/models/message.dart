class Message {
  final int messageId;
  final int conversationId;
  final int senderUserId;
  final String text;
  final String status;
  final DateTime createdAt;
  final DateTime? readAt;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.senderUserId,
    required this.text,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      conversationId: json['conversation_id'],
      senderUserId: json['sender_user_id'],
      text: json['text'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
  Message copyWith({String? status, DateTime? readAt}) {
    return Message(
      messageId: messageId,
      conversationId: conversationId,
      senderUserId: senderUserId,
      text: text,
      status: status ?? this.status,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
