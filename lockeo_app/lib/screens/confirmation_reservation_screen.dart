import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/button.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../services/local_data_service.dart';
import '../models/offer.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'package:intl/intl.dart';

class ReservationConfirmationScreen extends StatefulWidget {
  final int offerId;
  final DateTime startDate;
  final DateTime endDate;

  const ReservationConfirmationScreen({
    super.key,
    required this.offerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ReservationConfirmationScreen> createState() =>
      _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState
    extends State<ReservationConfirmationScreen> {
  final dataService = LocalDataService();

  Offer? _offer;
  Product? _product;
  ImageModel? _img;
  User? _owner;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final offer = await dataService.getOfferById(widget.offerId);
    if (offer == null) return;

    final products = await dataService.loadProducts();
    final images = await dataService.loadImages();
    final users = await dataService.loadUsers();
    final owner = users.firstWhere((u) => u.userId == offer.userId);

    final product = products.firstWhere((p) => p.productId == offer.productId);
    final productImage = images.firstWhere(
      (img) => img.productId == product.productId,
    );

    setState(() {
      _offer = offer;
      _product = product;
      _img = productImage;
      _owner = owner;
    });
  }

  Future<void> _onContactOwner() async {
    if (_owner == null) return;

    // 🔹 récupérer les données nécessaires
    final conversations = await dataService.loadConversations();
    final messages = await dataService.loadMessages();
    final currentUser = await dataService.getCurrentUser() as User;

    // 🔹 chercher une conversation existante
    final existingConversationId = _findConversationIdWithUser(
      conversations: conversations,
      currentUserId: currentUser.userId,
      otherUserId: _owner!.userId,
      messages: messages,
    );

    if (existingConversationId != null) {
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: existingConversationId,
      );
      return;
    }

    // 🔸 sinon : fallback (JSON statique)
    Navigator.pushNamed(
      context,
      '/conversation',
      arguments: _owner!.userId, // ou rien, selon ton routing
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Icône check
                SvgPicture.asset(
                  'assets/icons/icon_check.svg',
                  width: 64,
                  height: 64,
                ),

                const SizedBox(height: 8),

                // Titre
                Text(
                  "Votre demande a été\nenvoyée !",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 18),

                // 📝 Texte explicatif
                Text(
                  "Vous recevrez un e-mail de confirmation dès que le propriétaire aura validé votre demande",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),

                Text(
                  "Jusqu'au 20/10/2025",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _img?.url ?? 'assets/images/default.jpg',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product!.name,
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Du ${_formatDate(widget.startDate)} au ${_formatDate(widget.endDate)}",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _onContactOwner,
                                  child: Text(
                                    "Contacter ${_owner?.firstName}",
                                    style: AppTextStyles.link.copyWith(
                                      color: AppColors.primaryBlue,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Retour à la page d’accueil",
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final formatted = DateFormat('d MMMM y', 'fr_FR').format(d);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}

int? _findConversationIdWithUser({
  required List<Conversation> conversations,
  required int currentUserId,
  required int otherUserId,
  required List<Message> messages, // pas utilisé ici mais on le laisse
}) {
  for (final c in conversations) {
    final participants = c.userIds;

    final hasBoth =
        participants.contains(currentUserId) &&
        participants.contains(otherUserId);

    if (hasBoth) return c.conversationId;
  }
  return null;
}
