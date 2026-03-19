import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';

import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/reservation.dart';
import '../models/product_unavailability.dart';
import '../models/review.dart';

import '../services/local_data_service.dart';
import '../services/conversations_service.dart';
import '../services/auth_session.dart';

import '../widgets/images_slider.dart';
import '../widgets/category_card.dart';
import '../widgets/button.dart';
import '../widgets/product_grid.dart';
import '../widgets/reservation_sheet.dart';
import '../widgets/security_card.dart';
import '../widgets/availability_calendar_card.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  final Offer offer;

  const ProductDetailScreen({super.key, required this.offer});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _conversationsService = ConversationsService();
  final LocalDataService _dataService = LocalDataService();

  Future<void> _toggleFavorite() async {
    await _dataService.toggleFavoriteProduct(widget.offer.productId);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _dataService.loadProducts(),
        _dataService.loadImages(),
        _dataService.loadUsers(),
        _dataService.loadOffers(),
        _dataService.loadCategories(),
        _dataService.loadReservations(),
        _dataService.loadProductUnavailabilities(),
        _dataService.loadReviews(),
        _dataService.loadConversations(),
        _dataService.loadMessages(),
        _dataService.getCurrentUser(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Erreur ou données introuvables")),
          );
        }

        // Données locales
        final products = snapshot.data![0] as List<Product>;
        final images = snapshot.data![1] as List<ImageModel>;
        final users = snapshot.data![2] as List<User>;
        final offers = snapshot.data![3] as List<Offer>;
        final categories = snapshot.data![4] as List<Category>;
        final reservations = snapshot.data![5] as List<Reservation>;
        final unavailabilities =
            snapshot.data![6] as List<ProductUnavailability>;
        final reviews = snapshot.data![7] as List<Review>;

        // Produit + relations
        final product = products.firstWhere(
          (p) => p.productId == widget.offer.productId,
        );
        final owner = users.firstWhere((u) => u.userId == widget.offer.userId);

        final ownerReviews = reviews
            .where((r) => r.ownerId == owner.userId)
            .toList();

        final int ownerReviewsCount = ownerReviews.length;

        final double ownerRatingAverage = ownerReviews.isNotEmpty
            ? ownerReviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  ownerReviews.length
            : 0;

        final productImages = images
            .where((img) => img.productId == product.productId)
            .toList();

        final ownerOffersCount = offers
            .where((o) => o.userId == owner.userId)
            .length;

        final otherOffers = offers
            .where(
              (o) =>
                  o.userId == owner.userId && o.offerId != widget.offer.offerId,
            )
            .toList();

        final productCategories = categories
            .where((cat) => product.categoryIds.contains(cat.categoryId))
            .toList();

        final rentalCount = reservations
            .where((r) => r.productId == product.productId)
            .length;

        final productUnavailabilities = unavailabilities
            .where((u) => u.productId == product.productId)
            .toList();

        const String ownerRating = "5";

        bool isUnavailableDay(DateTime day) {
          final d = DateTime(day.year, day.month, day.day);

          for (final u in productUnavailabilities) {
            final start = DateTime(
              u.startDateTime.year,
              u.startDateTime.month,
              u.startDateTime.day,
            );
            final end = DateTime(
              u.endDateTime.year,
              u.endDateTime.month,
              u.endDateTime.day,
            );

            final isInRange =
                (d.isAtSameMomentAs(start) || d.isAfter(start)) &&
                (d.isAtSameMomentAs(end) || d.isBefore(end));

            if (isInRange) return true;
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
              onPressed: () => AppNavigator.back(context),
            ),
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SLIDER D’IMAGES ---
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: ImageSlider(
                    images: productImages,
                    height: 320,
                    isFavorite: product.isFavorite,
                    onToggleFavorite: _toggleFavorite,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        product.name,
                        style: AppTextStyles.h1.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 13),

                      // Localisation
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
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
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
                            "${product.price?.toStringAsFixed(0)}€/jour",
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
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
                      if (rentalCount > 0)
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
                                "Cet objet a été loué $rentalCount fois.",
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
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
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Catégories
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: productCategories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CategoryCard(name: category.label),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        product.description,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SecurityCard(
                        onTap: () {
                          // navigation ou ouverture modal
                        },
                      ),

                      const SizedBox(height: 18),

                      // Propriétaire
                      // --- PROPRIÉTAIRE (card + actions) ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                        owner
                                            .firstName, // ou "${owner.firstName} ${owner.lastName}"
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
                                            ownerRatingAverage.toStringAsFixed(0), // si tu as rating
                                            style: AppTextStyles.label.copyWith(
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "($ownerReviewsCount avis)", // ✅ vrai chiffre
                                            style: AppTextStyles.label.copyWith(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "$ownerOffersCount transactions", 
                                        style: AppTextStyles.label.copyWith(
                                          color: Colors.black.withOpacity(0.6),
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
                                // ✅ Contacter
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

                                // ✅ Voir le profil
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

                      // Calendrier informatif
                      Text(
                        "Disponibilité de l'article",
                        style: AppTextStyles.h2.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 18),

                      AvailabilityCalendarCard(
                        isUnavailableDay: isUnavailableDay,
                      ),

                      const SizedBox(height: 18),

                      Text(
                        "Annonces de ${owner.firstName}",
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 20),

                      ProductGrid(
                        maxItems: 4,
                        offers: otherOffers,
                        shrinkWrap: true,
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Suggestion d'annonces",
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 18),

                      ProductGrid(maxItems: 2, shrinkWrap: true),
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
                        ReservationSheet(offerId: widget.offer.offerId),
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
