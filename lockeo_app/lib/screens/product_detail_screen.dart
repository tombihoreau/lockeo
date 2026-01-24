import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/reservation.dart';
import '../models/product_unavailability.dart';
import '../models/review.dart';
import '../models/conversation.dart';
import '../models/message.dart';

import '../services/local_data_service.dart';

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
  @override
  Widget build(BuildContext context) {
    final dataService = LocalDataService();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        dataService.loadProducts(),
        dataService.loadImages(),
        dataService.loadUsers(),
        dataService.loadOffers(),
        dataService.loadCategories(),
        dataService.loadReservations(),
        dataService.loadProductUnavailabilities(),
        dataService.loadReviews(),
        dataService.loadConversations(),
        dataService.loadMessages(),
        dataService.getCurrentUser(),
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
        final conversations = snapshot.data![8] as List<Conversation>;
        final messages = snapshot.data![9] as List<Message>;
        final currentUser = snapshot.data![10] as User;

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
              onPressed: () => Navigator.pop(context),
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
                  child: ImageSlider(images: productImages, height: 320),
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
                            "${product.price?.toStringAsFixed(0)}€/jour",
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
                                        "$ownerOffersCount transactions", // ✅ vrai chiffre
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
                                    onPressed: () {
                                      // 1) si une conversation existe déjà avec ce propriétaire -> /conversation avec l'id
                                      final existingConversationId =
                                          _findConversationIdWithUser(
                                            conversations: conversations,
                                            currentUserId: currentUser.userId,
                                            otherUserId: owner.userId,
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

                                      // 2) sinon -> il faudrait créer une conversation
                                      // ⚠️ pas possible avec un JSON statique (pas de persistence).
                                      // TODO: appeler ton backend / service pour créer une conversation et récupérer l'id
                                      // final newId = await dataService.createConversation(...);
                                      // Navigator.pushNamed(context, '/conversation', arguments: newId);

                                      // En attendant : tu peux naviguer vers /conversation sans id,
                                      // ou afficher un message.
                                      // Navigator.pushNamed(context, '/conversation');
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
