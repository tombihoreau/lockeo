import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/offer.dart';
import '../models/product.dart';
import '../widgets/button.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationId;

  const ConversationScreen({super.key, required this.conversationId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _dataService = LocalDataService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String _contactLogin = "Utilisateur";
  int _currentUserId = 1;
  Conversation? _conversation;
  Offer? _offer;
  Product? _product;

  List<Message> _messages = [];
  bool _loading = true;

  // Permet de dire à l’écran précédent "j’ai marqué des messages en read"
  bool _hasReadChanges = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final currentUser = await _dataService.getCurrentUser();
    final currentUserId = currentUser?.userId ?? 1;

    final conversations = await _dataService.loadConversations();
    final users = await _dataService.loadUsers();
    final messages = await _dataService.loadMessages();
    final offers = await _dataService.loadOffers();
    final products = await _dataService.loadProducts();

    final Conversation? conversation =
        conversations
            .where((c) => c.conversationId == widget.conversationId)
            .isNotEmpty
        ? conversations.firstWhere(
            (c) => c.conversationId == widget.conversationId,
          )
        : null;

    // utilisateur "en face" (login)
    String contactLogin = "Utilisateur";
    if (conversation != null) {
      final otherUserId = conversation.userIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => currentUserId,
      );

      try {
        final otherUser = users.firstWhere((u) => u.userId == otherUserId);
        contactLogin =
            otherUser.login; // adapte si ton champ s'appelle username
      } catch (_) {
        contactLogin = "Utilisateur";
      }
    }

    Product? product;
    if (conversation != null) {
      try {
        product = products.firstWhere(
          (p) => p.productId == conversation.productId,
        );
      } catch (_) {
        product = null;
      }
    }

    Offer? offer;
    if (conversation != null) {
      try {
        offer = offers.firstWhere((o) => o.productId == conversation.productId);
      } catch (_) {
        offer = null;
      }
    }

    final convoMessages =
        messages
            .where((m) => m.conversationId == widget.conversationId)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    setState(() {
      _currentUserId = currentUserId;
      _conversation = conversation;
      _offer = offer;
      _product = product;
      _messages = convoMessages;
      _contactLogin = contactLogin; // <= ajoute ce champ dans ton State
      _loading = false;
    });

    _markAllIncomingAsRead();
    _scrollToBottom();
  }

  void _markAllIncomingAsRead() {
    final now = DateTime.now().toUtc();
    bool changed = false;

    final updated = _messages.map((m) {
      final isIncoming = m.senderUserId != _currentUserId;
      final isUnread = m.readAt == null;

      if (isIncoming && isUnread) {
        changed = true;
        return m.copyWith(status: "read", readAt: now);
      }
      return m;
    }).toList();

    if (changed) {
      setState(() {
        _messages = updated;
      });
      _hasReadChanges = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final nextId = _messages.isEmpty ? 1 : (_messages.last.messageId + 1);

    final newMessage = Message(
      messageId: nextId,
      conversationId: widget.conversationId,
      senderUserId: _currentUserId,
      text: text,
      status: "sent",
      createdAt: DateTime.now().toUtc(),
      readAt: null,
    );

    setState(() {
      _messages = [..._messages, newMessage];
      _controller.clear();
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF0F4C4C);
    final lightBg = const Color(0xFFF5F7FA);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasReadChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBg,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _OfferHeaderCard(
                    teal: teal,
                    contactLogin: _contactLogin,
                    onBack: () => Navigator.pop(context, _hasReadChanges),
                    offerTitle: _product?.name ?? "Produit",
                    priceLabel: _product != null ? "${_product!.price}€" : "—",
                    durationLabel: "1/2 journée",
                    locationLabel: _product?.city ?? "Ville, quartier",
                    onRentTap: () {},
                    onOfferTap: () {},
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        final isMe = m.senderUserId == _currentUserId;
                        return _MessageRow(
                          isMe: isMe,
                          text: m.text,
                          timeLabel: _formatTime(m.createdAt),
                          teal: teal,
                        );
                      },
                    ),
                  ),
                  _ComposerBar(
                    controller: _controller,
                    onSend: _sendMessage,
                    teal: teal,
                  ),
                ],
              ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return "$h:$min";
  }
}

class _OfferHeaderCard extends StatelessWidget {
  final Color teal;

  // Top bar
  final String contactLogin;
  final VoidCallback onBack;

  // Card content
  final String offerTitle;
  final String priceLabel;
  final String durationLabel;
  final String locationLabel;
  final VoidCallback onRentTap;
  final VoidCallback onOfferTap;

  const _OfferHeaderCard({
    required this.teal,
    required this.contactLogin,
    required this.onBack,
    required this.offerTitle,
    required this.priceLabel,
    required this.durationLabel,
    required this.locationLabel,
    required this.onRentTap,
    required this.onOfferTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TOP BAR (back + login)
                Row(
                  children: [
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        contactLogin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // OFFER CARD
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 150,
                        height: 110,
                        color: const Color(0xFFE9EEF3),
                        child: const Icon(
                          Icons.image,
                          color: Color(0xFF9AA6B2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            priceLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5B6672),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            durationLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5B6672),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            locationLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5B6672),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: CustomButton(
                          text: "Louer",
                          onPressed: onRentTap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: CustomButton(
                          text: "Faire une offre",
                          outlined: true,
                          onPressed: onOfferTap,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final bool isMe;
  final String text;
  final String timeLabel;
  final Color teal;

  const _MessageRow({
    required this.isMe,
    required this.text,
    required this.timeLabel,
    required this.teal,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? teal : Colors.white;
    final textColor = isMe ? Colors.white : const Color(0xFF263238);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _Avatar(isMe: false),
            ),
          if (!isMe) const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8794),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 10),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _Avatar(isMe: true),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool isMe;

  const _Avatar({required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFE9EEF3) : const Color(0xFFEDE7F6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 18,
        color: isMe ? const Color(0xFF7A8794) : const Color(0xFF7E57C2),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Color teal;

  const _ComposerBar({
    required this.controller,
    required this.onSend,
    required this.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      color: Colors.transparent,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Envoyer un message",
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Icon(Icons.send, color: teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
