import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_data_service.dart';
import '../widgets/product_card.dart';
import '../models/images.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  final LocalDataService dataService = LocalDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produits disponibles")),
      body: FutureBuilder<List<dynamic>>(
        //à voir pour prendre un produit qui correspond à une offre
        future: Future.wait([
          dataService.loadProducts(),
          dataService.loadImages(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Erreur ou données introuvables"));
          }

          final products = snapshot.data![0] as List<Product>;
          final images = snapshot.data![1] as List<ImageModel>; 
          final availableProducts = products.where((p) => p.isAvailable).toList();
          if (availableProducts.isEmpty) {
            return const Center(child: Text("Aucun produit disponible"));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.65,
            ),
            itemCount: availableProducts.length,
            itemBuilder: (context, index) {
              final availableProduct = availableProducts[index];
              final productImages = images.where((img) => img.productId == availableProduct.productId).toList();
              final firstImage = productImages.firstWhere(
                (img) => img.positionImage == 1,
                orElse: () => ImageModel(
                  imageId: 0,
                  productId: availableProduct.productId,
                  url: "assets/images/default.jpg",
                  positionImage: 0,
                  createdAt: "",
                ),
              );

              return ProductCard(
                product: availableProduct,
                image: firstImage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: availableProduct, images: productImages),
                    ),
                  );
                },
              );
            }
          );
        },
      ),
    );
  }
}
