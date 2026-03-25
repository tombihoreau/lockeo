import 'package:flutter/material.dart';

import '../models/product_suggestion.dart';
import '../services/location_service.dart';
import '../services/products_service.dart';
import 'product_suggestions_grid.dart';

class HomeSuggestionsGrid extends StatelessWidget {
  final int maxItems;
  final bool shrinkWrap;

  const HomeSuggestionsGrid({
    super.key,
    this.maxItems = 4,
    this.shrinkWrap = true,
  });

  Future<List<ProductSuggestion>> _loadSuggestions() async {
    final location = await LocationService().getStoredLatLng();
    return ProductsService().getHomeSuggestions(
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
            child: Text("Impossible de charger les suggestions"),
          );
        }

        final suggestions = snapshot.data ?? const <ProductSuggestion>[];
        if (suggestions.isEmpty) {
          return const Center(child: Text("Aucune suggestion disponible"));
        }

        return ProductSuggestionsGrid(
          suggestions: suggestions,
          shrinkWrap: shrinkWrap,
        );
      },
    );
  }
}
