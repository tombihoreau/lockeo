import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'conversation_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _dataService = LocalDataService();
  late Future<_ConversationsVm> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ConversationsVm> _load() async {
    final current = await _dataService.getCurrentUser();
    if (current == null) {
      return const _ConversationsVm(rows: []);
    }

    final currentUserId = int.parse(current.userId.toString());

    final conversations = await _dataService.getConversationsForCurrentUser();
    final users = await _dataService.loadUsers();
    final allMessages = await _dataService.loadMessages();

    final rows = <_ConversationRow>[];

    for (final c in conversations) {
      final conversationId = int.parse(c.conversationId.toString());

      // autre user (pour le nom affiché)
      final otherUserId = c.userIds.firstWhere(
        (id) => int.parse(id.toString()) != currentUserId,
        orElse: () => currentUserId,
      );

      final otherUser = users.firstWhere(
        (u) =>
            int.parse(u.userId.toString()) == int.parse(otherUserId.toString()),
        orElse: () => current,
      );

      // messages de la conversation (triés du + récent au + ancien)
      final messages = allMessages
          .where(
            (m) => int.parse(m.conversationId.toString()) == conversationId,
          )
          .toList();

      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastMessage = messages.isNotEmpty ? messages.first : null;

      // VERSION PROPRE : non lus = entrants + readAt null
      final unreadCount = messages.where((m) {
        final senderId = int.parse(m.senderUserId.toString());
        if (senderId == currentUserId) return false; // jamais tes messages
        return m.readAt == null; // non lu
      }).length;

      rows.add(
        _ConversationRow(
          conversationId: conversationId,
          title: _displayName(otherUser),
          lastText: lastMessage?.text ?? "Aucun message",
          timeLabel: lastMessage != null
              ? _formatHour(lastMessage.createdAt)
              : "",
          unreadCount: unreadCount,
        ),
      );
    }

    return _ConversationsVm(rows: rows);
  }

  String _displayName(User user) {
    return user.login ?? "Pseudo";
  }

  void _openConversation(int conversationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(conversationId: conversationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text("Messagerie"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<_ConversationsVm>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Erreur: ${snapshot.error}"),
              );
            }

            final rows = snapshot.data?.rows ?? [];
            if (rows.isEmpty) {
              return const Center(child: Text("Aucune conversation"));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final row = rows[i];
                return _ConversationTile(
                  title: row.title,
                  lastMessage: row.lastText,
                  timeLabel: row.timeLabel,
                  unreadCount: row.unreadCount,
                  onTap: () => _openConversation(row.conversationId),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConversationsVm {
  final List<_ConversationRow> rows;
  const _ConversationsVm({required this.rows});
}

class _ConversationRow {
  final int conversationId;
  final String title;
  final String lastText;
  final String timeLabel;
  final int unreadCount;

  const _ConversationRow({
    required this.conversationId,
    required this.title,
    required this.lastText,
    required this.timeLabel,
    required this.unreadCount,
  });
}

class _ConversationTile extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.title,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/default.jpg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isUnread
                            ? const Color(0xFF0C88A6)
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: const Color(0xFF2F3A3F),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C8AA0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatHour(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return "$h:$m";
}
