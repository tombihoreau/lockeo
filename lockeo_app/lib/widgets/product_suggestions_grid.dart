import 'package:flutter/material.dart';

import '../models/image.dart';
import '../models/product_suggestion.dart';
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
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics ??
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
  }
}
