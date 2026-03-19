import 'package:flutter/material.dart';

import '../models/offer.dart';
import '../models/product_detail.dart';
import '../services/auth_session.dart';
import '../services/conversations_service.dart';
import '../services/products_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/availability_calendar_card.dart';
import '../widgets/button.dart';
import '../widgets/category_card.dart';
import '../widgets/images_slider.dart';
import '../widgets/product_suggestions_grid.dart';
import '../widgets/reservation_sheet.dart';
import '../widgets/security_card.dart';
import '../widgets/suggestions_grid.dart';

class ProductDetailScreen extends StatefulWidget {
  final Offer offer;

  const ProductDetailScreen({super.key, required this.offer});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _conversationsService = ConversationsService();
  final _productsService = ProductsService();

  late Future<ProductDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _productsService.getOfferDetail(widget.offer.offerId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductDetail>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text("Erreur ou données introuvables"),
            ),
          );
        }

        final detail = snapshot.data!;
        final product = detail.product;
        final owner = detail.owner;
        final ownerName = owner.firstName.trim().isNotEmpty
            ? owner.firstName.trim()
            : owner.login.trim().isNotEmpty
                ? owner.login.trim()
                : 'Utilisateur';

        bool isUnavailableDay(DateTime day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);

          for (final item in detail.unavailabilities) {
            final start = DateTime(
              item.startDateTime.year,
              item.startDateTime.month,
              item.startDateTime.day,
            );
            final end = DateTime(
              item.endDateTime.year,
              item.endDateTime.month,
              item.endDateTime.day,
            );

            final isInRange =
                (normalizedDay.isAtSameMomentAs(start) ||
                    normalizedDay.isAfter(start)) &&
                (normalizedDay.isAtSameMomentAs(end) ||
                    normalizedDay.isBefore(end));

            if (isInRange) {
              return true;
            }
          }

          return false;
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: ImageSlider(images: detail.images, height: 320),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.h1.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "${product.city}, ${product.postalCode}",
                              style: AppTextStyles.label.copyWith(
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${product.price?.toStringAsFixed(0) ?? '0'}€/jour",
                            style: AppTextStyles.label.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (product.price3Days != null)
                            _PriceChip(
                              text:
                                  "${product.price3Days!.toStringAsFixed(0)}€ pour 3 jours",
                            ),
                          const SizedBox(width: 8),
                          if (product.price7Days != null)
                            _PriceChip(
                              text:
                                  "${product.price7Days!.toStringAsFixed(0)}€ pour 7 jours",
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (detail.rentalCount > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.sync_alt,
                              color: Colors.black,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "Cet objet a été loué ${detail.rentalCount} fois.",
                                style: AppTextStyles.label.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.bookmark_border,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              product.state,
                              style: AppTextStyles.label.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (detail.categories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: detail.categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CategoryCard(name: category.label),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        product.description,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SecurityCard(onTap: () {}),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundImage: AssetImage(
                                    'assets/images/user.jpg',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ownerName,
                                        style: AppTextStyles.h2.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            detail.ownerRatingAverage
                                                .toStringAsFixed(1),
                                            style: AppTextStyles.label.copyWith(
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "(${detail.ownerReviewsCount} avis)",
                                            style: AppTextStyles.label.copyWith(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${detail.ownerOffersCount} transactions",
                                        style: AppTextStyles.label.copyWith(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
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
                                  child: CustomButton(
                                    text: "Contacter",
                                    onPressed: () async {
                                      try {
                                        final currentUserId =
                                            AuthSession.instance.userId;
                                        if (currentUserId != null &&
                                            currentUserId == owner.userId) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Vous ne pouvez pas vous contacter vous-même.",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final conversationId =
                                            await _conversationsService
                                                .ensureConversationWithUser(
                                                  otherUserId: owner.userId,
                                                );
                                        if (!context.mounted) return;
                                        Navigator.pushNamed(
                                          context,
                                          '/conversation',
                                          arguments: conversationId,
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Impossible d'ouvrir la conversation: $e",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/user',
                                        arguments: owner.userId,
                                      );
                                    },
                                    text: "Voir le profil",
                                    outlined: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Disponibilité de l'article",
                        style: AppTextStyles.h2.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 18),
                      AvailabilityCalendarCard(
                        isUnavailableDay: isUnavailableDay,
                      ),
                      if (detail.otherOffers.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text(
                          "Annonces de $ownerName",
                          style: AppTextStyles.h2,
                        ),
                        const SizedBox(height: 20),
                        ProductSuggestionsGrid(
                          suggestions: detail.otherOffers,
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        "Suggestion d'annonces",
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 18),
                      const SuggestionsGrid(maxItems: 2, shrinkWrap: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            alignment: Alignment.center,
            height: 100,
            child: SizedBox(
              width: 300,
              child: CustomButton(
                text: "Louer",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        ReservationSheet(offerId: detail.offer.offerId),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String text;
  const _PriceChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue, width: 1),
        borderRadius: BorderRadius.circular(999),
        color: AppColors.blue50,
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue),
      ),
    );
  }
}
