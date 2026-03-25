import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/chat_socket_service.dart';
import '../services/auth_session.dart';
import '../services/app_notifications_realtime_service.dart';
import '../services/conversations_service.dart';
import '../services/products_service.dart';
import '../models/message.dart';
import '../models/offer.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/reservation.dart';
import '../models/inventory.dart';

import '../widgets/conversation_header.dart';
import '../widgets/inventory_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/reservation_sheet.dart';

class ConversationRouteArgs {
  final int conversationId;
  final String? otherUserName;
  final String? productTitle;
  final String? imagePath;
  final String? cityLabel;
  final String? postalCodeLabel;
  final double? pricePerDay;
  final double? totalPrice;
  final int? totalDays;
  final int? offerId;
  final int? ownerUserId;
  final int? reservationId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reservationStatus;

  const ConversationRouteArgs({
    required this.conversationId,
    this.otherUserName,
    this.productTitle,
    this.imagePath,
    this.cityLabel,
    this.postalCodeLabel,
    this.pricePerDay,
    this.totalPrice,
    this.totalDays,
    this.offerId,
    this.ownerUserId,
    this.reservationId,
    this.startDate,
    this.endDate,
    this.reservationStatus,
  });
}

class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final ConversationRouteArgs? initialArgs;

  const ConversationScreen({
    super.key,
    required this.conversationId,
    this.initialArgs,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  final _chatSocketService = ChatSocketService();
  final _conversationsService = ConversationsService();
  final _productsService = ProductsService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  int _currentUserId = 1;

  Offer? _offer;
  Product? _product;
  ImageModel? _productImage;

  Reservation? _reservation;
  Inventory? _inventory;
  ConversationReservationContext? _reservationContext;

  String _otherUserName = "";

  List<Message> _messages = [];
  bool _loading = true;
  bool _socketConnected = false;
  bool _isConnectingSocket = false;
  bool _isOtherUserTyping = false;
  bool _isTypingSent = false;
  bool _keyboardVisible = false;

  bool _hasReadChanges = false;
  bool _checkoutCongratsShown = false;
  StreamSubscription<ConversationHistoryEvent>? _historySub;
  StreamSubscription<ConversationMessageEvent>? _newMessageSub;
  StreamSubscription<ConversationTypingEvent>? _typingSub;
  StreamSubscription<String>? _socketErrorSub;
  StreamSubscription<ChatNotificationEvent>? _notificationSub;
  Timer? _typingStopTimer;
  double _lastBottomInset = 0;

  @override
  void initState() {
    super.initState();
    AppNotificationsRealtimeService.instance.setActiveConversation(
      widget.conversationId,
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncKeyboardVisibility();
    });
    _notificationSub = AppNotificationsRealtimeService.instance.notificationsStream
        .listen(_handleRealtimeNotification);
    _load();
  }

  @override
  void dispose() {
    if (AppNotificationsRealtimeService.instance.activeConversationId ==
        widget.conversationId) {
      AppNotificationsRealtimeService.instance.setActiveConversation(null);
    }
    WidgetsBinding.instance.removeObserver(this);
    _historySub?.cancel();
    _newMessageSub?.cancel();
    _typingSub?.cancel();
    _socketErrorSub?.cancel();
    _notificationSub?.cancel();
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

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    _syncKeyboardVisibility();

    final view = View.of(context);
    final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;
    final keyboardWasVisible = _lastBottomInset > 0;
    final keyboardIsVisible = bottomInset > 0;
    _lastBottomInset = bottomInset;

    if (keyboardWasVisible != keyboardIsVisible) {
      _scheduleScrollToBottom(animated: false);
    }
  }

  void _syncKeyboardVisibility() {
    final view = View.of(context);
    final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;
    final nextKeyboardVisible = bottomInset > 0;
    if (_keyboardVisible == nextKeyboardVisible) return;
    setState(() {
      _keyboardVisible = nextKeyboardVisible;
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final currentUserId = AuthSession.instance.userId ?? 1;
    final backendSnapshot = await _fetchConversationSnapshot();

    final resolvedMessages = backendSnapshot?.messages ?? const <Message>[];
    final resolvedOtherUserName =
        backendSnapshot?.otherUser?.displayName ??
        widget.initialArgs?.otherUserName ??
        "";

    setState(() {
      _currentUserId = currentUserId;

      _product = null;
      _offer = null;
      _productImage = null;

      _otherUserName = resolvedOtherUserName;

      _reservation = null;
      _inventory = null;
      _reservationContext = backendSnapshot?.reservationContext;

      _messages = resolvedMessages;
      _loading = false;
    });

    _maybeShowCheckoutCongrats();
    _markAllIncomingAsRead();
    _scrollToBottom();
    await _initRealtime();
  }

  Future<ConversationSnapshot?> _fetchConversationSnapshot() async {
    try {
      return await _conversationsService.fetchConversationSnapshot(
        conversationId: widget.conversationId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshConversationSnapshot() async {
    final backendSnapshot = await _fetchConversationSnapshot();
    if (!mounted || backendSnapshot == null) return;

    setState(() {
      _otherUserName =
          backendSnapshot.otherUser?.displayName ??
          widget.initialArgs?.otherUserName ??
          _otherUserName;
      _reservationContext = backendSnapshot.reservationContext;
      _messages = backendSnapshot.messages;
    });

    _maybeShowCheckoutCongrats();
    _markAllIncomingAsRead();
    _scheduleScrollToBottom(animated: false);
  }

  void _handleRealtimeNotification(ChatNotificationEvent event) {
    if (event.conversationId != widget.conversationId) return;
    _refreshConversationSnapshot();
  }

  // -------------------------
  // Header computed
  // -------------------------

  ConversationRole get _role {
    final ownerId =
        _reservationContext?.ownerUserId ??
        widget.initialArgs?.ownerUserId ??
        _offer?.userId;
    if (ownerId != null && ownerId == _currentUserId) {
      return ConversationRole.owner;
    }
    return ConversationRole.renter;
  }

  ReservationStatus get _reservationStatus {
    final contextStatus = _reservationContext?.status;
    if (contextStatus != null) {
      return _mapReservationStatus(contextStatus);
    }
    final initialStatus = widget.initialArgs?.reservationStatus;
    if (_reservation == null && initialStatus != null) {
      return _mapReservationStatus(initialStatus);
    }
    return _mapReservationStatus(_reservation?.status);
  }

  String _formatRangeLabel(Reservation? r) {
    if (r == null) return "";
    final df = DateFormat("d MMMM y", "fr_FR");
    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return "Du ${cap(df.format(r.startDate))} au ${cap(df.format(r.endDate))}";
  }

  String get _fallbackDateLabel {
    final start =
        _reservationContext?.startDate ?? widget.initialArgs?.startDate;
    final end = _reservationContext?.endDate ?? widget.initialArgs?.endDate;
    if (start == null || end == null) return "";
    final df = DateFormat("d MMMM y", "fr_FR");
    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return "Du ${cap(df.format(start))} au ${cap(df.format(end))}";
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
      _conversationsService
          .markConversationAsRead(conversationId: widget.conversationId)
          .catchError((_) {});
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        return;
      }
      _scrollController.jumpTo(target);
    });
  }

  void _scheduleScrollToBottom({bool animated = true}) {
    _scrollToBottom(animated: animated);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _scrollToBottom(animated: false);
    });
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _scrollToBottom(animated: false);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_socketConnected) {
      await _initRealtime();
    }

    if (!_socketConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’envoyer le message: connexion temps reel indisponible.',
          ),
        ),
      );
      return;
    }

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
    _scheduleScrollToBottom(animated: false);
    FocusScope.of(context).unfocus();
    _scheduleScrollToBottom(animated: false);
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
      _scheduleScrollToBottom(animated: false);
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
      _scheduleScrollToBottom();
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

  ReservationStatus _mapReservationStatus(String? status) {
    final s = (status ?? '').trim().toLowerCase();
    switch (s) {
      case 'pending':
        return ReservationStatus.requestPending;
      case 'accepted':
        return ReservationStatus.accepted;
      case 'refused':
      case 'rejected':
        return ReservationStatus.none;
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
    final offerId =
        _reservationContext?.offerId ??
        widget.initialArgs?.offerId ??
        _offer?.offerId;
    if (offerId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationSheet(offerId: offerId),
    );
  }

  Future<void> _acceptReservation() async {
    final reservationId =
        _reservationContext?.reservationId ?? widget.initialArgs?.reservationId;
    if (reservationId == null) return;
    await _updateReservationStatus(
      reservationId: reservationId,
      status: 'accepted',
    );
  }

  Future<void> _declineReservation() async {
    final reservationId =
        _reservationContext?.reservationId ?? widget.initialArgs?.reservationId;
    if (reservationId == null) return;
    await _updateReservationStatus(
      reservationId: reservationId,
      status: 'refused',
    );
  }

  Future<void> _updateReservationStatus({
    required int reservationId,
    required String status,
  }) async {
    try {
      await _productsService.updateReservationStatus(
        reservationId: reservationId,
        status: status,
      );
      if (!mounted) return;

      setState(() {
        final current = _reservationContext;
        if (current != null) {
          _reservationContext = ConversationReservationContext(
            reservationId: current.reservationId,
            status: status,
            startDate: current.startDate,
            endDate: current.endDate,
            totalPrice: current.totalPrice,
            totalDays: current.totalDays,
            offerId: current.offerId,
            ownerUserId: current.ownerUserId,
            productTitle: current.productTitle,
            cityLabel: current.cityLabel,
            postalCodeLabel: current.postalCodeLabel,
            pricePerDay: current.pricePerDay,
            imagePath: current.imagePath,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de mettre à jour la demande: $e")),
      );
    }
  }

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
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _hasReadChanges);
      },
      child: Scaffold(
        backgroundColor: lightBg,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (!_keyboardVisible)
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 8,
                        ),
                        child: ConversationHeader(
                          role: _role,
                          status: _reservationStatus,
                          productTitle:
                              _reservationContext?.productTitle ??
                              _product?.name ??
                              widget.initialArgs?.productTitle ??
                              "",
                          priceLabel:
                              "${(_reservationContext?.pricePerDay ?? _product?.price ?? widget.initialArgs?.pricePerDay ?? 0).toStringAsFixed(0)}€/jour",
                          totalPrice:
                              _reservationContext?.totalPrice ??
                              widget.initialArgs?.totalPrice,
                          totalDays:
                              _reservationContext?.totalDays ??
                              widget.initialArgs?.totalDays,
                          dateLabel: _reservation != null
                              ? _formatRangeLabel(_reservation)
                              : _fallbackDateLabel,
                          otherUserName: _otherUserName.isNotEmpty
                              ? _otherUserName
                              : (widget.initialArgs?.otherUserName ?? ""),
                          imagePath:
                              _reservationContext?.imagePath ??
                              _productImage?.url ??
                              widget.initialArgs?.imagePath ??
                              'assets/images/default.jpg',
                          cityLabel:
                              _reservationContext?.cityLabel ??
                              _product?.city ??
                              widget.initialArgs?.cityLabel ??
                              "",
                          postalCodeLabel:
                              _reservationContext?.postalCodeLabel ??
                              _product?.postalCode ??
                              widget.initialArgs?.postalCodeLabel ??
                              "",
                          pricePerDay:
                              _reservationContext?.pricePerDay ??
                              _product?.price ??
                              widget.initialArgs?.pricePerDay ??
                              0,
                          onAccept: _acceptReservation,
                          onDecline: _declineReservation,
                          onOpenInventory: _openInventory,
                          onValidateInventory: _validateInventory,
                          onMakeOffer: _openOfferSheet,
                          rentalEndDate:
                              _reservationContext?.endDate ??
                              _reservation?.endDate ??
                              widget.initialArgs?.endDate,
                        ),
                      ),
                    ),

                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          16,
                          _keyboardVisible ? topPadding + 12 : 8,
                          16,
                          8,
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
                    onSend: () {
                      _sendMessage();
                    },
                    onChanged: _onComposerChanged,
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
                  textCapitalization: TextCapitalization.sentences,
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
