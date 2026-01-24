import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/offer.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/image.dart';
import '../models/reservation.dart';
import '../models/inventory.dart';
import 'package:intl/intl.dart';

import '../widgets/conversation_header.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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

  int _currentUserId = 1;

  Conversation? _conversation;
  Offer? _offer;
  Product? _product;
  User? _owner;
  ImageModel? _productImage;
  Reservation? _reservation;
  Inventory? _inventory;

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
    final messages = await _dataService.loadMessages();
    final offers = await _dataService.loadOffers();
    final products = await _dataService.loadProducts();
    final users = await _dataService.loadUsers();
    final images = await _dataService.loadImages();
    final reservations = await _dataService.loadReservations();
    final inventories = await _dataService.loadInventories();

    Conversation? conversation;
    try {
      conversation = conversations.firstWhere(
        (c) => c.conversationId == widget.conversationId,
      );
    } catch (_) {
      conversation = null;
    }

    Offer? offer;
    Product? product;
    User? owner;
    ImageModel? productImage;

    if (conversation != null) {
      // Produit
      product = products.cast<Product?>().firstWhere(
        (p) => p?.productId == conversation?.productId,
        orElse: () => null,
      );

      // Offre liée au produit (si 1 offre / produit dans tes données)
      offer = offers.cast<Offer?>().firstWhere(
        (o) => o?.productId == conversation?.productId,
        orElse: () => null,
      );

      // Proprio = offer.userId
      if (offer != null) {
        owner = users.cast<User?>().firstWhere(
          (u) => u?.userId == offer!.userId,
          orElse: () => null,
        );
      }

      // Image produit
      if (product != null) {
        productImage = images.cast<ImageModel?>().firstWhere(
          (img) => img?.productId == product!.productId,
          orElse: () => null,
        );
      }
    }

    Reservation? reservation;

    if (conversation != null && product != null && offer != null) {
      final ownerId = offer.userId;

      // l’autre participant = locataire
      final renterId = conversation.userIds.firstWhere(
        (id) => id != ownerId,
        orElse: () => currentUserId,
      );

      reservation = _findReservationBetweenUsers(
        reservations: reservations,
        productId: product.productId,
        ownerId: ownerId,
        renterId: renterId,
      );
    }

    Inventory? inventory;
    if (reservation != null) {
      inventory = _findInventoryForReservation(
        inventories: inventories,
        reservationId: reservation.reservationId,
      );

      print(
        "reservationId: ${reservation.reservationId} inventory: ${inventory?.inventoryId} status: ${inventory?.status}",
      );
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
      _owner = owner;
      _productImage = productImage;
      _messages = convoMessages;
      _loading = false;
      _reservation = reservation;
      _inventory = inventory;
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

  // -------------------------
  // Header logic (role/status)
  // -------------------------
  String _formatRangeLabel(Reservation? r) {
    if (r == null) return "";
    final df = DateFormat("d MMMM y", "fr_FR");

    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

    final start = cap(df.format(r.startDate));
    final end = cap(df.format(r.endDate));
    return "Du $start au $end";
  }

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

  Reservation? _findReservationBetweenUsers({
    required List<Reservation> reservations,
    required int productId,
    required int ownerId,
    required int renterId,
  }) {
    final matches = reservations.where((r) {
      return r.productId == productId &&
          r.ownerId == ownerId &&
          r.renterId == renterId;
    }).toList();

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

      default:
        return ReservationStatus.none;
    }
  }

  Inventory? _findInventoryForReservation({
    required List<Inventory> inventories,
    required int reservationId,
  }) {
    final matches = inventories
        .where((i) => i.reservationId == reservationId)
        .toList();
    if (matches.isEmpty) return null;

    // si plusieurs inventaires (submitted puis validated), on prend le plus récent
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.first;
  }

  // Callbacks header (tu brancheras sur tes écrans/bottomsheet)
  void _openOfferSheet() {
    // TODO: ouvrir ta bottom sheet "ReservationSheet" ou une page d’offre
    // showModalBottomSheet(...);
  }

  void _acceptReservation() {
    // TODO: setState + update status si tu persistes côté backend
  }

  void _declineReservation() {
    // TODO
  }

  bool _inventoryDialogOpen = false;

  void _openInventory() {
    if (_inventoryDialogOpen) return;
    _inventoryDialogOpen = true;
    final comment = (_inventory?.comment ?? "").trim();
    final hasComment = comment.isNotEmpty;

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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        "L’état des lieux",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Placeholder photos
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cape200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    hasComment ? comment : "Aucun commentaire.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                CustomButton(
                  text: "Valider l’état des lieux",
                  onPressed: () {
                    Navigator.pop(context); // ferme état des lieux
                    _showCongratsDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => _inventoryDialogOpen = false);
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                  "L’état des lieux a été validé.\nVous pouvez procéder à l’échange !",
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

  void _validateInventory() {
    // TODO
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
                  // ✅ HEADER full-bleed (fond jusqu'en haut) + contenu safe + flèche retour
                  Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        // contenu du header avec un padding top "safe"
                        Padding(
                          padding: EdgeInsets.only(
                            top:
                                MediaQuery.of(context).padding.top +
                                8, // ✅ espace sous notch
                          ),
                          child: ConversationHeader(
                            role: _role,
                            status: _reservationStatus,
                            productTitle: _product!.name,
                            priceLabel:
                                "${(_product!.price ?? 0).toStringAsFixed(0)}€/jour",
                            dateLabel: _formatRangeLabel(_reservation),
                            ownerName: _owner!.firstName,
                            imagePath:
                                _productImage?.url ??
                                'assets/images/default.jpg',
                            cityLabel: _product!.city,
                            postalCodeLabel: _product!.postalCode,
                            pricePerDay: _product!.price ?? 0,
                            onAccept: _acceptReservation,
                            onDecline: _declineReservation,
                            onOpenInventory: _openInventory,
                            onValidateInventory: _validateInventory,
                            onMakeOffer: _openOfferSheet,
                          ),
                        ),
                      ],
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

                  _ComposerBar(
                    controller: _controller,
                    onSend: _sendMessage,
                    teal: const Color(0xFF0F4C4C),
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
  final Color teal;

  const _ComposerBar({
    required this.controller,
    required this.onSend,
    required this.teal,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: Colors.white, // 🔹 BARRE BLANCHE
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
