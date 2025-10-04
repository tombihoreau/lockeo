import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import '../widgets/images_slider.dart';
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

        final products = snapshot.data![0] as List<Product>;
        final images = snapshot.data![1] as List<ImageModel>;
        final users = snapshot.data![2] as List<User>;
        final offers = snapshot.data![3] as List<Offer>;
        final categories = snapshot.data![4] as List<Category>;

        final product = products.firstWhere((p) => p.productId == offer.productId);
        final owner = users.firstWhere((u) => u.userId == offer.userId);
        final productImages = images.where((img) => img.productId == product.productId).toList();
        final ownerOffersCount = offers.where((o) => o.userId == owner.userId).length;
        final productCategories = categories
          .where((cat) => product.categoryIds.contains(cat.categoryId))
          .toList();
          
        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Propriétaire
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(owner.firstName[0]), // première lettre du prénom
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          owner.firstName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$ownerOffersCount annonces",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Slider d'images
                ImageSlider(
                  images: productImages,
                  height: 250,
                  borderRadius: 12,
                ),
                const SizedBox(height: 16),

                // Categories

                Wrap(
                  spacing: 8, // espace horizontal entre les badges
                  runSpacing: 8, // espace vertical (si retour à la ligne)
                  children: productCategories.map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // vert clair de fond
                        border: Border.all(color: const Color(0xFF006633), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.label, // 👈 ton champ du modèle Category
                        style: const TextStyle(
                          color: Color(0xFF006633),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                
                const SizedBox(height: 16),
                // Description
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Ville
                Text(
                  product.city,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Prix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${product.price?.toInt()}€",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "1/2 journée",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                CustomButton(
                  text: "Faire une offre",
                  filled: false, // bouton plein
                  onPressed: () {
                    print("Faire une offre !");
                  },
                ),

                const SizedBox(height: 16),
                  CustomButton(
                  text: "Louer",
                  filled: true, // bouton plein
                  onPressed: () {
                    print("Louer !");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
