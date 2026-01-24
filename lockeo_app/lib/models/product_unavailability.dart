class ProductUnavailability {
  final int unavailabilityId;
  final int productId;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const ProductUnavailability({
    required this.unavailabilityId,
    required this.productId,
    required this.startDateTime,
    required this.endDateTime,
  });

  factory ProductUnavailability.fromJson(Map<String, dynamic> json) {
    return ProductUnavailability(
      unavailabilityId: json['unavailability_id'] as int,
      productId: json['product_id'] as int,
      startDateTime: DateTime.parse(json['start_date_time'] as String),
      endDateTime: DateTime.parse(json['end_date_time'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unavailability_id': unavailabilityId,
      'product_id': productId,
      'start_date_time': startDateTime.toUtc().toIso8601String(),
      'end_date_time': endDateTime.toUtc().toIso8601String(),
    };
  }

  bool overlaps(DateTime start, DateTime end) {
    // chevauchement si start < endDateTime ET end > startDateTime
    return start.isBefore(endDateTime) && end.isAfter(startDateTime);
  }
}
