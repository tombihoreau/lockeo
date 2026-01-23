import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../services/local_data_service.dart';
import '../widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Offer>? offers;
  final int? maxItems;
  final bool shrinkWrap;
  final bool randomize;
  final bool favoritesOnly;
  final String? searchQuery;
  final List<int>? selectedCategories;
  final double? maxDistance;
  final RangeValues? priceRange;
  final String? sortBy;
  final ValueChanged<int>? onCountChanged;

  const ProductGrid({
    super.key,
    this.offers,
    this.maxItems,
    this.shrinkWrap = false,
    this.randomize = false,
    this.favoritesOnly = false,
    this.searchQuery,
    this.selectedCategories,
    this.maxDistance,
    this.priceRange,
    this.sortBy,
    this.onCountChanged,
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

        if (favoritesOnly) {
          products = products.where((p) => p.isFavorite).toList();
        }

        if (selectedCategories != null && selectedCategories!.isNotEmpty) {
          products = products.where((p) {
            final productCategories = p.categoryIds ?? [];
            return productCategories.any(
              (id) => selectedCategories!.contains(id),
            );
          }).toList();
        }

        if (priceRange != null) {
          final double minPrice = priceRange!.start;
          final double maxPrice = priceRange!.end;

          products = products.where((p) {
            final double price = p.price ?? 0.0;
            return price >= minPrice && price <= maxPrice;
          }).toList();
        }

        // 🔎 Recherche
        if (searchQuery != null && searchQuery!.isNotEmpty) {
          final query = searchQuery!.toLowerCase();
          products = products
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
          if (products.isEmpty) {
            // 🟡 Si aucun produit trouvé → informer le parent (0 résultat)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onCountChanged?.call(0);
            });
            return const Center(
              child: Text("Aucun produit ne correspond à la recherche"),
            );
          }
        }

        // 👇 Si aucune liste d’offres fournie, on prend tout
        final visibleOffers = offers ?? allOffers;

        // 👇 On garde seulement celles avec un produit disponible
        var validOffers = visibleOffers
            .where(
              (o) => products.any(
                (p) => p.productId == o.productId && p.isAvailable,
              ),
            )
            .toList();

        if (randomize) validOffers.shuffle();

        switch (sortBy) {
          case "Prix":
            validOffers.sort((a, b) {
              final productA = products.firstWhere(
                (p) => p.productId == a.productId,
                orElse: () => products.first,
              );
              final productB = products.firstWhere(
                (p) => p.productId == b.productId,
                orElse: () => products.first,
              );

              final double priceA = productA.price ?? 0.0;
              final double priceB = productB.price ?? 0.0;

              return priceA.compareTo(priceB);
            });
            break;

          case "Distance":
            // 🚧 À implémenter plus tard avec LocationService
            break;

          case "Nouveautés":
            validOffers.sort((a, b) {
              final productA = products.firstWhere(
                (p) => p.productId == a.productId,
                orElse: () => products.first,
              );
              final productB = products.firstWhere(
                (p) => p.productId == b.productId,
                orElse: () => products.first,
              );
              return DateTime.parse(
                productB.createdAt,
              ).compareTo(DateTime.parse(productA.createdAt));
            });
            break;
        }

        // 👇 On limite le nombre d’éléments si maxItems est défini
        final displayedOffers = maxItems != null
            ? validOffers.take(maxItems!).toList()
            : validOffers;

        // 🟢 Informe la page parente du nombre total d’éléments affichés
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onCountChanged?.call(displayedOffers.length);
        });

        if (displayedOffers.isEmpty) {
          return const Center(child: Text("Aucun produit disponible"));
        }

        // 🧱 Grille des produits
        return GridView.builder(
          padding: EdgeInsets.zero,
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
            final product = products.firstWhere(
              (p) => p.productId == offer.productId,
            );

            final productImages = images
                .where((img) => img.productId == product.productId)
                .toList();

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
                Navigator.pushNamed(
                  context,
                  '/productDetails',
                  arguments: offer,
                );
              },
            );
          },
        );
      },
    );
  }
}
