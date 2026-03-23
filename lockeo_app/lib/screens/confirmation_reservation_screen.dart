import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../models/image.dart';
import '../models/product_detail.dart';
import '../services/conversations_service.dart';
import '../services/products_service.dart';
import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../widgets/button.dart';
import '../widgets/selected_photo_image.dart';
import 'conversation_screen.dart';

class ReservationConfirmationScreen extends StatefulWidget {
  final int offerId;
  final DateTime startDate;
  final DateTime endDate;
  final ProductDetail? initialDetail;
  final int? conversationId;
  final int? reservationId;
  final double? reservationTotalPrice;

  const ReservationConfirmationScreen({
    super.key,
    required this.offerId,
    required this.startDate,
    required this.endDate,
    this.initialDetail,
    this.conversationId,
    this.reservationId,
    this.reservationTotalPrice,
  });

  @override
  State<ReservationConfirmationScreen> createState() =>
      _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState
    extends State<ReservationConfirmationScreen> {
  final _productsService = ProductsService();
  final _conversationsService = ConversationsService();

  ProductDetail? _detail;
  ImageModel? _img;

  @override
  void initState() {
    super.initState();
    _detail = widget.initialDetail;
    _loadData();
  }

  Future<void> _loadData() async {
    final detail =
        widget.initialDetail ??
        await _productsService.getOfferDetail(widget.offerId);

    final productImage = detail.images.isNotEmpty
        ? detail.images.first
        : ImageModel(
            imageId: 0,
            productId: detail.product.productId,
            url: 'assets/images/default.jpg',
            positionImage: 0,
            createdAt: '',
          );

    if (!mounted) return;
    setState(() {
      _detail = detail;
      _img = productImage;
    });
  }

  Future<void> _onContactOwner() async {
    final existingConversationId = widget.conversationId;
    final detail = _detail;
    final owner = detail?.owner;
    final ownerName = owner == null
        ? 'le propriétaire'
        : owner.firstName.trim().isNotEmpty
        ? owner.firstName.trim()
        : owner.login.trim().isNotEmpty
        ? owner.login.trim()
        : 'le propriétaire';

    if (existingConversationId != null && existingConversationId > 0) {
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: ConversationRouteArgs(
          conversationId: existingConversationId,
          otherUserName: ownerName,
          productTitle: detail?.product.name,
          imagePath: _img?.url ?? 'assets/images/default.jpg',
          cityLabel: detail?.product.city,
          postalCodeLabel: detail?.product.postalCode,
          pricePerDay: detail?.product.price ?? 0,
          totalPrice: widget.reservationTotalPrice,
          totalDays: widget.endDate.difference(widget.startDate).inDays + 1,
          offerId: detail?.offer.offerId,
          ownerUserId: detail?.owner.userId,
          reservationId: widget.reservationId,
          startDate: widget.startDate,
          endDate: widget.endDate,
          reservationStatus: 'pending',
        ),
      );
      return;
    }

    if (owner == null) return;

    try {
      final conversationId = await _conversationsService
          .ensureConversationWithUser(otherUserId: owner.userId);
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: ConversationRouteArgs(
          conversationId: conversationId,
          otherUserName: ownerName,
          productTitle: detail?.product.name,
          imagePath: _img?.url ?? 'assets/images/default.jpg',
          cityLabel: detail?.product.city,
          postalCodeLabel: detail?.product.postalCode,
          pricePerDay: detail?.product.price ?? 0,
          totalPrice: widget.reservationTotalPrice,
          totalDays: widget.endDate.difference(widget.startDate).inDays + 1,
          offerId: detail?.offer.offerId,
          ownerUserId: detail?.owner.userId,
          reservationId: widget.reservationId,
          startDate: widget.startDate,
          endDate: widget.endDate,
          reservationStatus: 'pending',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir la conversation: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    if (detail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ownerName = detail.owner.firstName.trim().isNotEmpty
        ? detail.owner.firstName.trim()
        : detail.owner.login.trim().isNotEmpty
        ? detail.owner.login.trim()
        : 'le propriétaire';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_check.svg',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(height: 8),
                Text(
                  "Votre demande a été\nenvoyée !",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Vous recevrez un e-mail de confirmation dès que le propriétaire aura validé votre demande",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Jusqu'au ${DateFormat('dd/MM/yyyy', 'fr_FR').format(widget.endDate)}",
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
                        child: SelectedPhotoImage(
                          path: _img?.url ?? 'assets/images/default.jpg',
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
                              detail.product.name,
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
                                    "Contacter $ownerName",
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
                const SizedBox(height: 4),
                Text(
                  "Contactez le propriétaire pour organiser votre échange (horaire et lieu)",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textGrey,
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
