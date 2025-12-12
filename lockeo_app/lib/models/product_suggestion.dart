import 'product.dart';

class ProductSuggestion {
  final Product product;
  final String? imageUri; // ex: "default.jpg"

  ProductSuggestion({required this.product, this.imageUri});

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    // Le backend renvoie les champs du produit à plat + image_uri
    final prod = Product.fromJson(json);
    final img = json['image_uri'] as String?;
    return ProductSuggestion(product: prod, imageUri: img);
  }
}
