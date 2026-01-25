class NotificationTemplate {
  final int templateId;
  final String code;
  final String title;
  final String content;

  NotificationTemplate({
    required this.templateId,
    required this.code,
    required this.title,
    required this.content,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      templateId: json['template_id'] as int,
      code: (json['code'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
    );
  }
}
