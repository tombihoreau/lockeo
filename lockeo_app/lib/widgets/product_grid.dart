import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../services/local_data_service.dart';
import '../widgets/product_card.dart';
import '../screens/product_detail_screen.dart';

class ProductGrid extends StatelessWidget {
  final List<Offer>? offers; 
  final int? maxItems;
  final bool shrinkWrap;
  final bool randomize;
  final bool favoritesOnly; // 👈 ton paramètre de filtre favoris

  const ProductGrid({
    super.key,
    this.offers,
    this.maxItems,
    this.shrinkWrap = false,
    this.randomize = false,
    this.favoritesOnly = false, // 👈 par défaut false
  });

  @override
  Widget build(BuildContext context) {
    final dataService = LocalDataService();

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        dataService.loadProducts(),
        dataService.loadImages(),
        dataService.loadOffers(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Erreur ou données introuvables"));
        }

        var products = snapshot.data![0] as List<Product>;
        final images = snapshot.data![1] as List<ImageModel>;
        final allOffers = snapshot.data![2] as List<Offer>;

        // 🔹 Filtrer uniquement les favoris si demandé
        if (favoritesOnly) {
          products = products.where((p) => p.isFavorite).toList();
        }

        print (products.length);

        // 👇 Si aucune liste d’offres fournie, on prend tout
        final visibleOffers = offers ?? allOffers;

        // 👇 On filtre uniquement celles avec un produit disponible
        var validOffers = visibleOffers
            .where((o) => products.any(
                (p) => p.productId == o.productId && p.isAvailable))
            .toList();

        print(validOffers.length);

        if (randomize) validOffers.shuffle();

        // 👇 On limite le nombre d’éléments si maxItems est défini
        final displayedOffers = maxItems != null
            ? validOffers.take(maxItems!).toList()
            : validOffers;

        if (displayedOffers.isEmpty) {
          return const Center(child: Text("Aucun produit disponible"));
        }

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.65,
          ),
          itemCount: displayedOffers.length,
          itemBuilder: (context, index) {
            final offer = displayedOffers[index];
            final product = products.firstWhere((p) => p.productId == offer.productId);
            
            final productImages =
                images.where((img) => img.productId == product.productId).toList();

            final firstImage = productImages.isNotEmpty
                ? productImages.first
                : ImageModel(
                    imageId: 0,
                    productId: product.productId,
                    url: "assets/images/default.jpg",
                    positionImage: 0,
                    createdAt: "",
                  );

            return ProductCard(
              product: product,
              image: firstImage,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(offer: offer),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
