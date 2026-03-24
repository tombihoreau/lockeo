import 'package:flutter/material.dart';

import '../models/image.dart';
import '../models/product_suggestion.dart';
import '../services/favorites_service.dart';
import 'product_card.dart';

class ProductSuggestionsGrid extends StatelessWidget {
  final List<ProductSuggestion> suggestions;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductSuggestionsGrid({
    super.key,
    required this.suggestions,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService.instance;

    return FutureBuilder<Set<int>>(
      future: favoritesService.ensureLoaded(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<Set<int>>(
          valueListenable: favoritesService.favoriteProductIds,
          builder: (context, favoriteIds, _) {
            return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: shrinkWrap,
              physics:
                  physics ??
                  (shrinkWrap
                      ? const NeverScrollableScrollPhysics()
                      : const ScrollPhysics()),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.6,
              ),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                final product = suggestion.product.copyWith(
                  isFavorite: favoriteIds.contains(
                    suggestion.product.productId,
                  ),
                );
                final image = ImageModel(
                  imageId: 0,
                  productId: product.productId,
                  url: suggestion.imagePath,
                  positionImage: 0,
                  createdAt: '',
                );

                return ProductCard(
                  product: product,
                  image: image,
                  onTap: suggestion.offer == null
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            '/productDetails',
                            arguments: suggestion.offer,
                          );
                        },
                  onToggleFavorite: () async {
                    try {
                      await favoritesService.toggleFavorite(
                        product.productId,
                        currentValue: product.isFavorite,
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Impossible de mettre à jour les favoris",
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
