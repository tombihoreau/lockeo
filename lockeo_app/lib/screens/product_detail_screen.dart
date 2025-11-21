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

class ProductDetailScreen extends StatelessWidget {
  final Offer offer;

  const ProductDetailScreen({
    super.key,
    required this.offer,
  });

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

        final product = products.firstWhere((p) => p.productId == offer.productId);
        final owner = users.firstWhere((u) => u.userId == offer.userId);
        final productImages = images.where((img) => img.productId == product.productId).toList();
        final ownerOffersCount = offers.where((o) => o.userId == owner.userId).length;
        final productCategories =
            categories.where((cat) => product.categoryIds.contains(cat.categoryId)).toList();

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
                      child: ImageSlider(
                        images: productImages,
                        height: 320,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                                  const Icon(Icons.location_on, color: Colors.grey, size: 18),
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
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: CategoryCard(
                                        name: category.label,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Description
                              Text(
                                product.description,
                                style: const TextStyle(fontSize: 15, height: 1.4),
                              ),
                              const SizedBox(height: 20),

                              // Propriétaire
                              Container(
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
                                      backgroundImage:
                                          const AssetImage('assets/images/user.jpg'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                              Icon(Icons.star, size: 16, color: Colors.amber),
                                              SizedBox(width: 4),
                                              Text("5"),
                                            ],
                                          ),
                                          Text(
                                            "$ownerOffersCount annonces",
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),

                          // --- Prix en haut à droite ---
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFF225A5D), width: 1.3),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                "${product.price?.toStringAsFixed(0)}€",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF225A5D),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomButton(
              text: "Louer",
              onPressed: () {
                print("Louer !");
              },
            ),
          ),
        );
      },
    );
  }
}
