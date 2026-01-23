import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import '../widgets/images_slider.dart';
import '../widgets/category_card.dart';
import '../widgets/button.dart';
import '../widgets/product_grid.dart';
import '../widgets/reservation_sheet.dart';
import '../models/reservation.dart';
import '../theme/app_colors.dart';

class ProductDetailScreen extends StatelessWidget {
  final Offer offer;

  const ProductDetailScreen({super.key, required this.offer});

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
        List<Offer> otherOffers = [];

        final product = products.firstWhere(
          (p) => p.productId == offer.productId,
        );
        final owner = users.firstWhere((u) => u.userId == offer.userId);
        final productImages = images
            .where((img) => img.productId == product.productId)
            .toList();
        final ownerOffersCount = offers
            .where((o) => o.userId == owner.userId)
            .length;

        otherOffers = offers
            .where(
              (o) => o.userId == owner.userId && o.offerId != offer.offerId,
            )
            .toList();

        final productCategories = categories
            .where((cat) => product.categoryIds.contains(cat.categoryId))
            .toList();

        final rentalCount = reservations
            .where((r) => r.productId == product!.productId)
            .length;

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

          // --- CONTENU ---
          body: Stack(
            children: [
              // Contenu scrollable
              SingleChildScrollView(
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Localisation
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      "${product.city}, ${product.postalCode}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Catégories
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: productCategories.map((category) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: CategoryCard(name: category.label),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Description
                              Text(
                                product.description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'État',
                                style: const TextStyle(
                                  color: Color.fromRGBO(157, 160, 162, 1),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.state,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),

                              if (rentalCount > 0)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFE7C2,
                                    ), // beige/orange doux
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Cet objet a été loué $rentalCount fois.",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔹 Ligne titre + logo
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Notre protection avec la MAAF",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.asset(
                                            "assets/icons/logo_maaf.png",
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // 🔹 Texte pleine largeur
                                    const Text(
                                      "Nous utilisons un système de caution via assurance pour vous protéger en cas de dommage.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // 🔹 Lien
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: navigation page assurance
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: const [
                                          Text(
                                            "Découvrir notre assurance",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2E6F75),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFF2E6F75),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Propriétaire
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/user',
                                    arguments: owner.userId,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
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
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundImage: const AssetImage(
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
                                              owner.firstName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                                SizedBox(width: 4),
                                                Text("5"),
                                              ],
                                            ),
                                            Text(
                                              "$ownerOffersCount annonces",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Text(
                                "Autres annonces",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ProductGrid(
                                maxItems: 4,
                                offers: otherOffers,
                                shrinkWrap: true,
                              ),
                            ],
                          ),

                          // --- Prix en haut à droite ---
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              child: Text(
                                "${product.price?.toStringAsFixed(0)}€",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    builder: (_) => ReservationSheet(offerId: offer.offerId),
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
