import 'package:flutter/material.dart';
import '../models/product_suggestion.dart';
import '../services/products_service.dart';
import 'product_suggestions_grid.dart';

class FavoritesSection extends StatelessWidget {
  final int maxItems;
  const FavoritesSection({super.key, this.maxItems = 4});

  @override
  Widget build(BuildContext context) {
    final productsService = ProductsService();

    return FutureBuilder<List<ProductSuggestion>>(
      future: productsService.getRecentFavorites(limit: maxItems),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // On peut choisir de ne rien afficher pendant le chargement
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          // Si pas de token/401, on masque la section
          return const SizedBox.shrink();
        }

        final favorites = snapshot.data ?? const <ProductSuggestion>[];
        if (favorites.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Vos favoris',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/products');
                  },
                  child: const Text(
                    'Tout voir',
                    style: TextStyle(
                      color: Color(0xFF225A5D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ProductSuggestionsGrid(
              suggestions: favorites,
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}
