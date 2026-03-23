import '../models/notification_template.dart';
import '../models/user_notification.dart';
import 'api_client.dart';
import 'auth_session.dart';
import 'local_data_service.dart';

class NotificationsPayload {
  final List<NotificationTemplate> templates;
  final List<UserNotification> notifications;

  const NotificationsPayload({
    required this.templates,
    required this.notifications,
  });
}

class NotificationsService {
  NotificationsService({ApiClient? api, LocalDataService? localDataService})
      : _api = api ?? ApiClient(),
        _localDataService = localDataService ?? LocalDataService();

  final ApiClient _api;
  final LocalDataService _localDataService;

  Future<NotificationsPayload> fetchMine() async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      return _loadLocalFallback();
    }

    try {
      _api.setBearerToken(token);
      final rows = await _api.getJsonList('/notifications');

      final notifications = <UserNotification>[];
      final templateById = <int, NotificationTemplate>{};

      for (final raw in rows.whereType<Map>()) {
        final map = raw.cast<String, dynamic>();
        notifications.add(UserNotification.fromJson(map));

        final templateRaw = map['template'];
        if (templateRaw is Map) {
          final template = NotificationTemplate.fromJson(
            templateRaw.cast<String, dynamic>(),
          );
          templateById[template.templateId] = template;
        }
      }

      return NotificationsPayload(
        templates: templateById.values.toList(),
        notifications: notifications,
      );
    } catch (_) {
      return _loadLocalFallback();
    }
  }

  Future<NotificationsPayload> _loadLocalFallback() async {
    final templates = await _localDataService.loadNotificationTemplates();
    final notifications = await _localDataService.loadUserNotifications();
    return NotificationsPayload(
      templates: templates,
      notifications: notifications,
    );
  }
}
