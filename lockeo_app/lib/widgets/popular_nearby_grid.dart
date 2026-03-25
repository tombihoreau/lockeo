import 'package:flutter/material.dart';

import '../models/product_suggestion.dart';
import '../services/location_service.dart';
import '../services/products_service.dart';
import 'product_suggestions_grid.dart';

class PopularNearbyGrid extends StatelessWidget {
  final int maxItems;
  final bool shrinkWrap;

  const PopularNearbyGrid({
    super.key,
    this.maxItems = 4,
    this.shrinkWrap = true,
  });

  Future<List<ProductSuggestion>> _loadSuggestions() async {
    final location = await LocationService().getStoredLatLng();
    return ProductsService().getPopularNearby(
      limit: maxItems,
      latitude: location?.lat,
      longitude: location?.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductSuggestion>>(
      future: _loadSuggestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Impossible de charger les produits populaires"),
          );
        }

        final suggestions = snapshot.data ?? const <ProductSuggestion>[];
        if (suggestions.isEmpty) {
          return const Center(child: Text("Aucun produit disponible"));
        }

        return ProductSuggestionsGrid(
          suggestions: suggestions,
          shrinkWrap: shrinkWrap,
        );
      },
    );
  }
}
