class Conversation {
  final int conversationId;
  final int productId;
  final List<int> userIds; // expected: 2 ids

  final int? lastMessageId;
  final String lastMessageAt;
  final String createdAt;

  Conversation({
    required this.conversationId,
    required this.productId,
    required this.userIds,
    this.lastMessageId,
    required this.lastMessageAt,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversation_id'] ?? json['conversationId'] ?? 0,
      productId: json['product_id'] ?? json['productId'] ?? 0,
      userIds: List<int>.from(json['user_ids'] ?? json['userIds'] ?? []),
      lastMessageId: json['last_message_id'] ?? json['lastMessageId'],
      lastMessageAt: json['last_message_at'] ?? json['lastMessageAt'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'conversation_id': conversationId,
        'product_id': productId,
        'user_ids': userIds,
        'last_message_id': lastMessageId,
        'last_message_at': lastMessageAt,
        'created_at': createdAt,
      };

  bool containsUser(int userId) => userIds.contains(userId);

  int getOtherUserId(int currentUserId) {
    if (userIds.length != 2) return -1;
    if (userIds[0] == currentUserId) return userIds[1];
    if (userIds[1] == currentUserId) return userIds[0];
    return -1;
  }
}
