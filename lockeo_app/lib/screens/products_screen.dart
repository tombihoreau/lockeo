import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_data_service.dart';
import '../widgets/product_card.dart';
import '../models/image.dart';
import 'product_detail_screen.dart';
import '../models/offer.dart';

class ProductsScreen extends StatelessWidget {
  final LocalDataService dataService = LocalDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produits disponibles")),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          dataService.loadOffers(),
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

          final offers = snapshot.data![0] as List<Offer>;
          final products = snapshot.data![1] as List<Product>;
          final images = snapshot.data![2] as List<ImageModel>; 

          final visibleOffers = offers.where((o) =>
            products.any((p) => p.productId == o.productId && p.isAvailable)
          ).toList();
          
          if (offers.isEmpty) {
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
            itemCount: visibleOffers.length,
            itemBuilder: (context, index) {
              final offer = visibleOffers[index];
              final product = products.firstWhere((p) => p.productId == offer.productId);
              final productImages = images.where((img) => img.productId == product.productId).toList();
              final firstImage = productImages.firstWhere(
                (img) => img.positionImage == 1,
                orElse: () => ImageModel(
                  imageId: 0,
                  productId: product.productId,
                  url: "assets/images/default.jpg",
                  positionImage: 0,
                  createdAt: "",
                ),
              );

              return ProductCard(
                product: product,
                image: firstImage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        offer: offer,
                      ),
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
