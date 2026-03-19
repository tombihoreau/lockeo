import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
import 'package:intl/intl.dart';

import '../services/local_data_service.dart';
import '../models/notification_template.dart';
import '../models/user_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _dataService = LocalDataService();
  bool _loading = true;

  int _currentUserId = 1; // ou via getCurrentUser()
  List<_NotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final currentUser = await _dataService.getCurrentUser();
    _currentUserId = currentUser?.userId ?? 1;

    final templates = await _dataService.loadNotificationTemplates();
    final userNotifs = await _dataService.loadUserNotifications();

    final templateById = {for (final t in templates) t.templateId: t};

    // filtre sur le destinataire + tri date desc
    final mine =
        userNotifs.where((n) => n.destinationUserId == _currentUserId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    print("mine=${mine}");

    final items = mine.map((n) {
      final tpl = templateById[n.templateId];

      final title = _renderTemplate(tpl?.title ?? "Notification", n.payload);
      final body = _renderTemplate(tpl?.content ?? "", n.payload);

      return _NotificationItem(
        id: n.userNotificationId,
        title: title,
        body: body,
        unread: n.isUnread,
        createdAt: n.createdAt,
      );
    }).toList();

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  String _renderTemplate(String template, Map<String, dynamic> payload) {
    // Remplace {{key}} par payload[key]
    final reg = RegExp(r'{{\s*([^}]+)\s*}}');
    return template.replaceAllMapped(reg, (m) {
      final key = (m.group(1) ?? '').trim();
      final value = payload[key];
      return value == null ? "" : value.toString();
    });
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat("HH:mm").format(local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => AppNavigator.back(context),
        ),
        titleSpacing: 0,
        title: Text(
          "Notifications",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F0),
                ),
                itemBuilder: (context, index) {
                  final n = _items[index];
                  return _NotificationRow(
                    title: n.title,
                    body: n.body,
                    timeLabel: _formatTime(n.createdAt),
                    unread: n.unread,
                    onTap: () {
                      // TODO: navigation selon template/code/payload
                      // et marquer en "read" si tu veux
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationItem {
  final int id;
  final String title;
  final String body;
  final bool unread;
  final DateTime createdAt;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.unread,
    required this.createdAt,
  });
}

class _NotificationRow extends StatelessWidget {
  final String title;
  final String body;
  final String timeLabel;
  final bool unread;
  final VoidCallback onTap;

  const _NotificationRow({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.body.copyWith(
      color: unread ? AppColors.primaryRed : AppColors.textPrimary,
    );

    final bodyStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textPrimary,
      fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: bodyStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 10),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
