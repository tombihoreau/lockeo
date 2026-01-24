class Product {
  final int productId;
  final String name;
  final String description;
  final double? price;
  final double? priceEstimate;
  final String state;
  final double? longitude;
  final double? latitude;
  final String city;
  final String postalCode;
  final bool isAvailable;
  final String createdAt;
  final String updatedAt;
  final List<int> categoryIds; 
  final bool isFavorite;
  final double? price3Days; 
  final double? price7Days; 

  Product({
    required this.productId,
    required this.name,
    required this.description,
    this.price,
    this.priceEstimate,
    required this.state,
    this.longitude,
    this.latitude,
    required this.city,
    required this.postalCode,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryIds,
    this.isFavorite = false,
    this.price3Days,
    this.price7Days,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] != null ? json['price'].toDouble() : null,
      priceEstimate: json['price_estimate'] != null ? json['price_estimate'].toDouble() : null,
      state: json['state'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      city: json['city'],
      postalCode: json['postal_code'],
      isAvailable: json['is_available'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoryIds: List<int>.from(json['category_ids'] ?? []),
      isFavorite: json['is_favorite'] ?? false,
      price3Days: json['price_3_days'] != null ? json['price_3_days'].toDouble() : null,
      price7Days: json['price_7_days'] != null ? json['price_7_days'].toDouble() : null,
    );
  }
}
