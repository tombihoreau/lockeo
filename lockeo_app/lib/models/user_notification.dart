class UserNotification {
  final int userNotificationId;
  final int destinationUserId;
  final int templateId;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  UserNotification({
    required this.userNotificationId,
    required this.destinationUserId,
    required this.templateId,
    required this.status,
    required this.createdAt,
    required this.payload,
  });

  bool get isUnread => status.toLowerCase() != "read";

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      userNotificationId: json['user_notification_id'] as int,
      destinationUserId: json['destination_user_id'] as int,
      templateId: json['template_id'] as int,
      status: (json['status'] ?? 'unread') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }
}
