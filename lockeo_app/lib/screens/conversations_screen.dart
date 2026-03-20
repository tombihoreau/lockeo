import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../services/conversations_service.dart';
import 'conversation_screen.dart';
import 'home_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/main_scaffold.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _dataService = LocalDataService();
  final _conversationsService = ConversationsService();
  late Future<_ConversationsVm> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ConversationsVm> _load() async {
    try {
      final dbRows = await _conversationsService.fetchMyConversations();
      if (dbRows.isNotEmpty) {
        return _ConversationsVm(
          rows: dbRows
              .map(
                (r) => _ConversationRow(
                  conversationId: r.conversationId,
                  title: r.title,
                  lastText: r.lastText,
                  timeLabel: r.lastMessageAt != null ? _formatHour(r.lastMessageAt!) : "",
                  unreadCount: r.unreadCount,
                ),
              )
              .toList(),
        );
      }
    } catch (_) {
      // fallback local en cas d'erreur réseau/API
    }

    return _loadFromLocalJson();
  }

  Future<_ConversationsVm> _loadFromLocalJson() async {
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
          title: otherUser.login ?? "Pseudo",
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

  void _openConversation(int conversationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(conversationId: conversationId),
      ),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainScaffold(
          currentIndex: 0,
          child: HomeScreen(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goToHome();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _goToHome,
          ),
          title: Text(
            "Messagerie",
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
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
                  padding: const EdgeInsets.all(20),
                  child: Text("Erreur: ${snapshot.error}"),
                );
              }

              final rows = snapshot.data?.rows ?? [];
              if (rows.isEmpty) {
                return const Center(child: Text("Aucune conversation"));
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 21),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E5E5),
                  ),
                ),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w400,
                        color: isUnread
                            ? AppColors.primaryRed
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
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
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(20),
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
