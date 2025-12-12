import 'package:flutter/material.dart';
import '../models/product_suggestion.dart';
import '../models/image.dart';
import '../services/products_service.dart';
import 'product_card.dart';

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
            childAspectRatio: 0.6,
          ),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final s = suggestions[index];
            final product = s.product;
            final imageUrl = (s.imageUri != null && s.imageUri!.isNotEmpty)
                ? 'assets/images/${s.imageUri}'
                : 'assets/images/default.jpg';
            final firstImage = ImageModel(
              imageId: 0,
              productId: product.productId,
              url: imageUrl,
              positionImage: 0,
              createdAt: '',
            );

            return ProductCard(
              product: product,
              image: firstImage,
              onTap: () {
                Navigator.pushNamed(context, '/productDetails', arguments: product);
              },
            );
          },
        );
      },
    );
  }
}
