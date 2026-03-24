import 'package:flutter/material.dart';

import '../models/image.dart';
import '../models/product_suggestion.dart';
import '../services/favorites_service.dart';
import '../services/products_service.dart';
import 'product_card.dart';

class SearchResultsGrid extends StatefulWidget {
  final String searchQuery;
  final List<int> selectedCategories;
  final RangeValues? priceRange;
  final ValueChanged<int>? onCountChanged;

  const SearchResultsGrid({
    super.key,
    required this.searchQuery,
    required this.selectedCategories,
    required this.priceRange,
    this.onCountChanged,
  });

  @override
  State<SearchResultsGrid> createState() => _SearchResultsGridState();
}

class _SearchResultsGridState extends State<SearchResultsGrid> {
  final ProductsService _productsService = ProductsService();
  final FavoritesService _favoritesService = FavoritesService.instance;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = widget.searchQuery.trim();
    final hasCategoryFilter = widget.selectedCategories.isNotEmpty;

    if (trimmedQuery.isEmpty && !hasCategoryFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCountChanged?.call(0);
      });

      return const Center(
        child: Text("Saisissez un mot-clé ou choisissez une catégorie"),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _productsService.searchProducts(
          query: trimmedQuery,
          categoryIds: widget.selectedCategories.isEmpty
              ? null
              : widget.selectedCategories,
          minPrice: widget.priceRange?.start,
          maxPrice: widget.priceRange?.end,
        ),
        _favoritesService.ensureLoaded(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCountChanged?.call(0);
          });

          return const Center(
            child: Text(
              "Impossible de charger les résultats depuis le serveur",
            ),
          );
        }

        final suggestions = snapshot.data![0] as List<ProductSuggestion>;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onCountChanged?.call(suggestions.length);
        });

        if (suggestions.isEmpty) {
          return const Center(
            child: Text("Aucun article ne correspond à votre recherche"),
          );
        }

        return ValueListenableBuilder<Set<int>>(
          valueListenable: _favoritesService.favoriteProductIds,
          builder: (context, favoriteIds, _) {
            return GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.62,
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
                      await _favoritesService.toggleFavorite(
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
