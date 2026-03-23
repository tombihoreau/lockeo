import 'package:flutter/material.dart';
import '../models/product_suggestion.dart';
import '../services/products_service.dart';
import 'product_suggestions_grid.dart';

class SuggestionsGrid extends StatelessWidget {
  final int maxItems;
  final bool shrinkWrap;
  const SuggestionsGrid({super.key, this.maxItems = 4, this.shrinkWrap = true});

  @override
  Widget build(BuildContext context) {
    final productsService = ProductsService();

    return FutureBuilder<List<ProductSuggestion>>(
      future: productsService.getSuggestions(limit: maxItems),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        final suggestions = snapshot.data ?? const <ProductSuggestion>[];
        if (suggestions.isEmpty) {
          return const Center(child: Text('Aucune suggestion disponible'));
        }

        return ProductSuggestionsGrid(
          suggestions: suggestions,
          shrinkWrap: shrinkWrap,
        );
      },
    );
  }
}
