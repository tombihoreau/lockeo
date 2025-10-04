import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/images.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final List<ImageModel> images; 

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼️ Image produit
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                images.isNotEmpty ? images.first.url : "assets/images/default.jpg",
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // 📝 Description
            Text(
              product.description,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),

            Text(
              product.city,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // 💰 Prix 
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "${product.price?.toInt()}€",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "1/2 journée",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

          
          ],
        ),
      ),
    );
  }
}
