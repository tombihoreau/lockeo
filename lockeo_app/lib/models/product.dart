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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return null;
        return double.tryParse(s);
      }
      return null;
    }

    return Product(
      productId: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: _toDouble(json['price']),
      priceEstimate: _toDouble(json['price_estimate']),
      state: json['state'],
      longitude: _toDouble(json['longitude']),
      latitude: _toDouble(json['latitude']),
      city: json['city'],
      postalCode: json['postal_code'],
      isAvailable: json['is_available'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoryIds: List<int>.from(json['category_ids'] ?? []),
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
