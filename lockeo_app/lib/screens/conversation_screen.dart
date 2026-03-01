import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/local_data_service.dart';
import '../services/chat_socket_service.dart';
import '../services/auth_session.dart';
import '../services/conversations_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/offer.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/image.dart';
import '../models/reservation.dart';
import '../models/inventory.dart';

import '../widgets/conversation_header.dart';
import '../widgets/inventory_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/reservation_sheet.dart';

class ConversationScreen extends StatefulWidget {
  final int conversationId;

  const ConversationScreen({super.key, required this.conversationId});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _dataService = LocalDataService();
  final _chatSocketService = ChatSocketService();
  final _conversationsService = ConversationsService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  int _currentUserId = 1;

  Conversation? _conversation;
  Offer? _offer;
  Product? _product;
  ImageModel? _productImage;

  Reservation? _reservation;
  Inventory? _inventory;

  User? _otherUser;
  String _otherUserName = "";

  List<Message> _messages = [];
  bool _loading = true;
  bool _socketConnected = false;
  bool _isConnectingSocket = false;
  bool _isOtherUserTyping = false;
  bool _isTypingSent = false;

  bool _hasReadChanges = false;
  bool _checkoutCongratsShown = false;
  StreamSubscription<ConversationHistoryEvent>? _historySub;
  StreamSubscription<ConversationMessageEvent>? _newMessageSub;
  StreamSubscription<ConversationTypingEvent>? _typingSub;
  StreamSubscription<String>? _socketErrorSub;
  Timer? _typingStopTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _historySub?.cancel();
    _newMessageSub?.cancel();
    _typingSub?.cancel();
    _socketErrorSub?.cancel();
    _typingStopTimer?.cancel();
    if (_socketConnected) {
      _chatSocketService.emitTyping(
        conversationId: widget.conversationId,
        isTyping: false,
      );
    }
    _chatSocketService.leaveConversation(widget.conversationId);
    _chatSocketService.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final currentUser = await _dataService.getCurrentUser();
    final currentUserId = AuthSession.instance.userId ?? currentUser?.userId ?? 1;

    final conversations = await _dataService.loadConversations();
    final messages = await _dataService.loadMessages();
    final offers = await _dataService.loadOffers();
    final products = await _dataService.loadProducts();
    final users = await _dataService.loadUsers();
    final images = await _dataService.loadImages();
    final reservations = await _dataService.loadReservations();
    final inventories = await _dataService.loadInventories();

    // 1) conversation
    Conversation? conversation;
    try {
      conversation = conversations.firstWhere(
        (c) => c.conversationId == widget.conversationId,
      );
    } catch (_) {
      conversation = null;
    }

    // 2) produit / offre / image
    Product? product;
    Offer? offer;
    ImageModel? productImage;

    if (conversation != null) {
      product = products.cast<Product?>().firstWhere(
        (p) => p?.productId == conversation!.productId,
        orElse: () => null,
      );

      offer = offers.cast<Offer?>().firstWhere(
        (o) => o?.productId == conversation!.productId,
        orElse: () => null,
      );

      if (product != null) {
        productImage = images.cast<ImageModel?>().firstWhere(
          (img) => img?.productId == product!.productId,
          orElse: () => null,
        );
      }
    }

    // 3) autre user (celui qui n'est pas moi)
    User? otherUser;
    if (conversation != null) {
      final otherUserId = conversation.userIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => currentUserId,
      );

      otherUser = users.cast<User?>().firstWhere(
        (u) => u?.userId == otherUserId,
        orElse: () => null,
      );
    }

    // 4) reservation via conversation.reservationId
    Reservation? reservation;
    final convoReservationId = conversation?.reservationId;
    if (convoReservationId != null) {
      try {
        reservation = reservations.firstWhere(
          (r) => r.reservationId == convoReservationId,
        );
      } catch (_) {
        reservation = null;
      }
    }

    // 5) inventory (le plus récent)
    Inventory? inventory;
    if (reservation != null) {
      inventory = _findInventoryForReservation(
        inventories: inventories,
        reservationId: reservation.reservationId,
      );
    }

    // 6) messages
    final convoMessages =
        messages
            .where((m) => m.conversationId == widget.conversationId)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    ConversationSnapshot? backendSnapshot;
    try {
      backendSnapshot = await _conversationsService.fetchConversationSnapshot(
        conversationId: widget.conversationId,
      );
    } catch (_) {
      backendSnapshot = null;
    }

    final resolvedMessages = backendSnapshot?.messages ?? convoMessages;
    final resolvedOtherUserName = backendSnapshot?.otherUser?.displayName ??
        _localDisplayName(otherUser);

    setState(() {
      _currentUserId = currentUserId;

      _conversation = conversation;
      _product = product;
      _offer = offer;
      _productImage = productImage;

      _otherUser = otherUser;
      _otherUserName = resolvedOtherUserName;

      _reservation = reservation;
      _inventory = inventory;

      _messages = resolvedMessages;
      _loading = false;
    });

    _maybeShowCheckoutCongrats();
    _markAllIncomingAsRead();
    _scrollToBottom();
    await _initRealtime();
  }

  // -------------------------
  // Header computed
  // -------------------------

  ConversationRole get _role {
    final ownerId = _offer?.userId;
    if (ownerId != null && ownerId == _currentUserId) {
      return ConversationRole.owner;
    }
    return ConversationRole.renter;
  }

  ReservationStatus get _reservationStatus {
    return _mapReservationStatus(_reservation?.status);
  }

  String _formatRangeLabel(Reservation? r) {
    if (r == null) return "";
    final df = DateFormat("d MMMM y", "fr_FR");
    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return "Du ${cap(df.format(r.startDate))} au ${cap(df.format(r.endDate))}";
  }

  // -------------------------
  // Popup checkout_validated
  // -------------------------

  void _maybeShowCheckoutCongrats() {
    if (_checkoutCongratsShown) return;

    final mapped = _mapReservationStatus(_reservation?.status);
    if (mapped != ReservationStatus.checkoutValidated) return;

    _checkoutCongratsShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_loading) return;
      _showCheckoutValidatedDialog();
    });
  }

  void _showCheckoutValidatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  "Félicitations !",
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "L’état des lieux de sortie a été validé.\nVous pouvez procéder à la restitution du matériel.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/handshake.png',
                  width: 174,
                  height: 174,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  "Merci pour votre confiance.",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------
  // Read / scroll / send
  // -------------------------

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
      setState(() => _messages = updated);
      _hasReadChanges = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_socketConnected) {
      if (_isTypingSent) {
        _chatSocketService.emitTyping(
          conversationId: widget.conversationId,
          isTyping: false,
        );
        _isTypingSent = false;
      }
      _chatSocketService.sendMessage(
        conversationId: widget.conversationId,
        text: text,
      );
      _controller.clear();
      return;
    }

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

  void _onComposerChanged(String value) {
    if (!_socketConnected) return;

    final hasText = value.trim().isNotEmpty;
    if (hasText && !_isTypingSent) {
      _chatSocketService.emitTyping(
        conversationId: widget.conversationId,
        isTyping: true,
      );
      _isTypingSent = true;
    }

    _typingStopTimer?.cancel();
    if (hasText) {
      _typingStopTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!_socketConnected || !_isTypingSent) return;
        _chatSocketService.emitTyping(
          conversationId: widget.conversationId,
          isTyping: false,
        );
        _isTypingSent = false;
      });
    } else if (_isTypingSent) {
      _chatSocketService.emitTyping(
        conversationId: widget.conversationId,
        isTyping: false,
      );
      _isTypingSent = false;
    }
  }

  Future<void> _initRealtime() async {
    if (_isConnectingSocket) return;
    _isConnectingSocket = true;

    _historySub?.cancel();
    _newMessageSub?.cancel();
    _typingSub?.cancel();
    _socketErrorSub?.cancel();

    _historySub = _chatSocketService.historyStream.listen((event) {
      if (!mounted || event.conversationId != widget.conversationId) return;
      setState(() {
        _messages = event.messages;
      });
      _markAllIncomingAsRead();
      _scrollToBottom();
    });

    _newMessageSub = _chatSocketService.newMessageStream.listen((event) {
      if (!mounted || event.conversationId != widget.conversationId) return;
      final alreadyExists = _messages.any(
        (m) => m.messageId == event.message.messageId && m.messageId != 0,
      );
      if (alreadyExists) return;

      setState(() {
        _messages = [..._messages, event.message];
        if (event.message.senderUserId != _currentUserId) {
          _isOtherUserTyping = false;
        }
      });
      _markAllIncomingAsRead();
      _scrollToBottom();
    });

    _typingSub = _chatSocketService.typingStream.listen((event) {
      if (!mounted || event.conversationId != widget.conversationId) return;
      if (event.senderUserId == _currentUserId) return;
      setState(() => _isOtherUserTyping = event.isTyping);
    });

    _socketErrorSub = _chatSocketService.errorStream.listen((_) {
      if (!mounted) return;
      setState(() {
        _socketConnected = false;
        _isOtherUserTyping = false;
      });
      _isTypingSent = false;
    });

    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      _isConnectingSocket = false;
      return;
    }

    try {
      await _chatSocketService.connect(token: token);
      _chatSocketService.joinConversation(widget.conversationId);
      if (mounted) {
        setState(() => _socketConnected = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _socketConnected = false);
      }
    } finally {
      _isConnectingSocket = false;
    }
  }

  // -------------------------
  // Inventory helpers + callbacks header
  // -------------------------

  Inventory? _findInventoryForReservation({
    required List<Inventory> inventories,
    required int reservationId,
  }) {
    final matches = inventories
        .where((i) => i.reservationId == reservationId)
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.first;
  }

  ReservationStatus _mapReservationStatus(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    switch (s) {
      case 'pending':
        return ReservationStatus.requestPending;
      case 'accepted':
        return ReservationStatus.accepted;
      case 'exchange_pending':
        return ReservationStatus.exchangePending;
      case 'completed':
        return ReservationStatus.completed;
      case 'in_progress':
        return ReservationStatus.inProgress;
      case 'return_soon':
        return ReservationStatus.returnSoon;
      case 'checkout_validated':
        return ReservationStatus.checkoutValidated;
      default:
        return ReservationStatus.none;
    }
  }

  void _openOfferSheet() {
    if (_offer == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationSheet(offerId: _offer!.offerId),
    );
  }

  void _openOfferDetails() {
    final offer = _offer;
    if (offer == null) return;
    Navigator.pushNamed(context, '/productDetails', arguments: offer);
  }

  void _openOtherUserProfile() {
    final otherUserId = _otherUser?.userId;
    if (otherUserId == null || otherUserId <= 0) return;
    Navigator.pushNamed(context, '/user', arguments: otherUserId);
  }

  void _acceptReservation() {}
  void _declineReservation() {}

  Future<void> _openInventory() async {
    if (_reservation == null) return;

    // Si déjà fait => lecture seule
    final readOnly = _inventory != null;

    final result = await showDialog<Inventory?>(
      context: context,
      barrierDismissible: true,
      builder: (_) => InventoryDialog(
        reservationId: _reservation!.reservationId,
        initialInventory: _inventory,
        readOnly: readOnly,
      ),
    );

    // En lecture seule => result = null (on ferme)
    if (readOnly) return;

    // Si création => result est l’inventory envoyé
    if (result == null) return;

    setState(() {
      _inventory = result;
    });
  }

  void _validateInventory() {}

  // -------------------------
  // UI
  // -------------------------

  @override
  Widget build(BuildContext context) {
    final lightBg = const Color(0xFFF5F7FA);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final displayedMessages = _messages.reversed.toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasReadChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBg,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (!keyboardVisible)
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 8,
                          ),
                          child: ConversationHeader(
                            role: _role,
                            status: _reservationStatus,
                            productTitle: _product?.name ?? "",
                            priceLabel:
                                "${(_product?.price ?? 0).toStringAsFixed(0)}€/jour",
                            dateLabel: _formatRangeLabel(_reservation),
                            otherUserName: _otherUser?.firstName ?? "",
                            imagePath:
                                _productImage?.url ?? 'assets/images/default.jpg',
                            cityLabel: _product?.city ?? "",
                            postalCodeLabel: _product?.postalCode ?? "",
                            pricePerDay: _product?.price ?? 0,
                            onAccept: _acceptReservation,
                            onDecline: _declineReservation,
                            onOpenInventory: _openInventory,
                            onValidateInventory: _validateInventory,
                            onMakeOffer: _openOfferSheet,
                            onOpenOfferDetails: _openOfferDetails,
                            rentalEndDate: _reservation?.endDate,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          16,
                          keyboardVisible ? 60 : 8,
                          16,
                          8,
                        ),
                        itemCount: displayedMessages.length,
                        itemBuilder: (context, index) {
                          final m = displayedMessages[index];
                          final isMe = m.senderUserId == _currentUserId;
                          return _MessageRow(
                            isMe: isMe,
                            text: m.text,
                            timeLabel: _formatTime(m.createdAt),
                            teal: AppColors.blue100,
                            onOtherAvatarTap: _openOtherUserProfile,
                          );
                        },
                      ),
                    ),
                    if (_isOtherUserTyping)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28,
                          right: 28,
                          bottom: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Est en train d'écrire ...",
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    _ComposerBar(
                      controller: _controller,
                      onSend: _sendMessage,
                      onChanged: _onComposerChanged,
                    ),
                  ],
                ),
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

  String _localDisplayName(User? user) {
    if (user == null) return "";
    if (user.login.trim().isNotEmpty) return user.login.trim();
    final first = user.firstName.trim();
    if (first.isNotEmpty) return first;
    final last = user.lastName.trim();
    if (last.isNotEmpty) return last;
    return "";
  }
}

class _MessageRow extends StatelessWidget {
  final bool isMe;
  final String text;
  final String timeLabel;
  final Color teal;
  final VoidCallback? onOtherAvatarTap;

  const _MessageRow({
    required this.isMe,
    required this.text,
    required this.timeLabel,
    required this.teal,
    this.onOtherAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.white : teal;
    final textColor = AppColors.textPrimary;

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
              child: GestureDetector(
                onTap: onOtherAvatarTap,
                child: const _Avatar(isMe: false),
              ),
            ),
          if (!isMe) const SizedBox(width: 10),

          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: isMe
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.body.copyWith(color: textColor),
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
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
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
      width: 45,
      height: 45,
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
  final ValueChanged<String> onChanged;

  const _ComposerBar({
    required this.controller,
    required this.onSend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cape300, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Envoyer un message",
                    hintStyle: AppTextStyles.label.copyWith(
                      color: AppColors.textGrey,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  textInputAction: TextInputAction.send,
                  onChanged: onChanged,
                  onSubmitted: (_) => onSend(),
                ),
              ),
              GestureDetector(
                onTap: onSend,
                child: Icon(
                  Icons.send_outlined,
                  color: AppColors.primaryBlue,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
