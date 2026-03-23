import 'product.dart';
import 'offer.dart';
import '../services/backend_config.dart';

class ProductSuggestion {
  final Product product;
  final String? imageUri; // ex: "default.jpg"
  final Offer? offer;

  ProductSuggestion({required this.product, this.imageUri, this.offer});

  String get imagePath {
    final uri = imageUri?.trim();
    if (uri == null || uri.isEmpty) {
      return 'assets/images/default.jpg';
    }

    if (uri.startsWith('assets/') ||
        uri.startsWith('http://') ||
        uri.startsWith('https://') ||
        uri.startsWith('file://')) {
      return uri;
    }
    if (uri.startsWith('uploads/') ||
        uri.startsWith('/uploads/') ||
        uri.startsWith('api/uploads/') ||
        uri.startsWith('/api/uploads/')) {
      return BackendConfig.resolveApiUrl(uri);
    }
    if (uri.startsWith('/')) return uri;

    return 'assets/images/$uri';
  }

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim());
      return null;
    }

    // Le backend renvoie les champs du produit à plat + image_uri
    final prod = Product.fromJson(json);
    final img = json['image_uri'] as String?;
    final offerId = toInt(json['offer_id']);
    final offerUserId = toInt(json['offer_user_id']);
    final offerAmount = toDouble(json['offer_amount']);

    final offer =
        offerId != null &&
            offerUserId != null &&
            offerAmount != null &&
            json['offer_status'] != null &&
            json['offer_created_at'] != null
        ? Offer(
            offerId: offerId,
            productId: prod.productId,
            userId: offerUserId,
            status: json['offer_status'].toString(),
            amount: offerAmount,
            createdAt: json['offer_created_at'].toString(),
          )
        : null;

    return ProductSuggestion(product: prod, imageUri: img, offer: offer);
  }
}
