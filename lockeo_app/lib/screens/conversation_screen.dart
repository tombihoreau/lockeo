import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/local_data_service.dart';
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

  List<Message> _messages = [];
  bool _loading = true;

  bool _hasReadChanges = false;
  bool _checkoutCongratsShown = false;

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

    setState(() {
      _currentUserId = currentUserId;

      _conversation = conversation;
      _product = product;
      _offer = offer;
      _productImage = productImage;

      _otherUser = otherUser;

      _reservation = reservation;
      _inventory = inventory;

      _messages = convoMessages;
      _loading = false;
    });

    _maybeShowCheckoutCongrats();
    _markAllIncomingAsRead();
    _scrollToBottom();
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
                        rentalEndDate: _reservation?.endDate,
                      ),
                    ),
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
                          teal: AppColors.blue100,
                        );
                      },
                    ),
                  ),

                  _ComposerBar(controller: _controller, onSend: _sendMessage),
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
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
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

  const _ComposerBar({required this.controller, required this.onSend});

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
