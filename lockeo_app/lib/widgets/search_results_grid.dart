import 'package:flutter/material.dart';

import '../models/image.dart';
import '../models/product_suggestion.dart';
import '../services/products_service.dart';
import 'product_card.dart';

class SearchResultsGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final trimmedQuery = searchQuery.trim();

    if (trimmedQuery.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onCountChanged?.call(0);
      });

      return const Center(
        child: Text("Saisissez un mot-clé puis appuyez sur la loupe"),
      );
    }

    final productsService = ProductsService();

    return FutureBuilder<List<ProductSuggestion>>(
      future: productsService.searchProducts(
        query: trimmedQuery,
        categoryIds: selectedCategories.isEmpty ? null : selectedCategories,
        minPrice: priceRange?.start,
        maxPrice: priceRange?.end,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onCountChanged?.call(0);
          });

          return const Center(
            child: Text("Impossible de charger les résultats depuis le serveur"),
          );
        }

        final suggestions = snapshot.data ?? const <ProductSuggestion>[];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          onCountChanged?.call(suggestions.length);
        });

        if (suggestions.isEmpty) {
          return const Center(
            child: Text("Aucun article ne correspond à votre recherche"),
          );
        }

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
            final image = ImageModel(
              imageId: 0,
              productId: suggestion.product.productId,
              url: suggestion.imagePath,
              positionImage: 0,
              createdAt: '',
            );

            return ProductCard(
              product: suggestion.product,
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
            );
          },
        );
      },
    );
  }
}
