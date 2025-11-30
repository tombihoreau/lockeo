import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ImageModel image;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image en haut
            Image.asset(
              image.url,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Padding uniquement en bas
            const SizedBox(height: 12),

            // Infos produit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${product.city}, ${product.postalCode}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Spacer(), // 👈 pousse la Row vers le bas

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF225A5D), width: 1.3),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      "${product.price?.toStringAsFixed(0)}€",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF225A5D),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Text(
                    "1 journée",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
