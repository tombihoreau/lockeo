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
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return null;
        return double.tryParse(s);
      }
      return null;
    }

    List<int> toIntList(dynamic value) {
      if (value is! List) {
        return const [];
      }

      return value
          .map((item) {
            if (item is int) return item;
            if (item is num) return item.toInt();
            if (item is String) return int.tryParse(item.trim());
            return null;
          })
          .whereType<int>()
          .toList();
    }

    return Product(
      productId: json['product_id'],
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: toDouble(json['price']),
      priceEstimate: toDouble(json['price_estimate']),
      state: (json['state'] ?? '').toString(),
      longitude: toDouble(json['longitude']),
      latitude: toDouble(json['latitude']),
      city: (json['city'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(),
      isAvailable: json['is_available'] == true,
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      categoryIds: toIntList(json['category_ids']),
      isFavorite: json['is_favorite'] ?? false,
      price3Days: toDouble(json['price_3_days']),
      price7Days: toDouble(json['price_7_days']),
    );
  }

  Product copyWith({
    int? productId,
    String? name,
    String? description,
    double? price,
    double? priceEstimate,
    String? state,
    double? longitude,
    double? latitude,
    String? city,
    String? postalCode,
    bool? isAvailable,
    String? createdAt,
    String? updatedAt,
    List<int>? categoryIds,
    bool? isFavorite,
    double? price3Days,
    double? price7Days,
  }) {
    return Product(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      state: state ?? this.state,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryIds: categoryIds ?? this.categoryIds,
      isFavorite: isFavorite ?? this.isFavorite,
      price3Days: price3Days ?? this.price3Days,
      price7Days: price7Days ?? this.price7Days,
    );
  }
}
