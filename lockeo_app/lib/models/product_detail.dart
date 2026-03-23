import 'category.dart';
import 'image.dart';
import 'offer.dart';
import 'product.dart';
import 'product_suggestion.dart';
import 'product_unavailability.dart';
import 'user.dart';

class ProductDetail {
  final Offer offer;
  final Product product;
  final User owner;
  final List<ImageModel> images;
  final List<Category> categories;
  final List<ProductUnavailability> unavailabilities;
  final int rentalCount;
  final int ownerReviewsCount;
  final double ownerRatingAverage;
  final int ownerOffersCount;
  final List<ProductSuggestion> otherOffers;

  const ProductDetail({
    required this.offer,
    required this.product,
    required this.owner,
    required this.images,
    required this.categories,
    required this.unavailabilities,
    required this.rentalCount,
    required this.ownerReviewsCount,
    required this.ownerRatingAverage,
    required this.ownerOffersCount,
    required this.otherOffers,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? fallback;
      return fallback;
    }

    double toDouble(dynamic value, [double fallback = 0]) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim()) ?? fallback;
      return fallback;
    }

    final offerJson = (json['offer'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final productJson = (json['product'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final ownerJson = (json['owner'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final images = (json['images'] as List? ?? const [])
        .whereType<Map>()
        .map((raw) => ImageModel.fromJson(raw.cast<String, dynamic>()))
        .toList();

    final categories = (json['categories'] as List? ?? const [])
        .whereType<Map>()
        .map((raw) => Category.fromJson(raw.cast<String, dynamic>()))
        .toList();

    final unavailabilities = (json['unavailabilities'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (raw) => ProductUnavailability.fromJson(raw.cast<String, dynamic>()),
        )
        .toList();

    final otherOffers = (json['other_offers'] as List? ?? const [])
        .whereType<Map>()
        .map((raw) => ProductSuggestion.fromJson(raw.cast<String, dynamic>()))
        .toList();

    return ProductDetail(
      offer: Offer.fromJson(offerJson),
      product: Product.fromJson(productJson),
      owner: User.fromJson(ownerJson),
      images: images,
      categories: categories,
      unavailabilities: unavailabilities,
      rentalCount: toInt(json['rental_count']),
      ownerReviewsCount: toInt(json['owner_reviews_count']),
      ownerRatingAverage: toDouble(json['owner_rating_average']),
      ownerOffersCount: toInt(json['owner_offers_count']),
      otherOffers: otherOffers,
    );
  }
}
