class Reservation {
  final int reservationId;
  final int productId;
  final int ownerId;
  final int renterId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double finalPrice;
  final DateTime verificationCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.reservationId,
    required this.ownerId,
    required this.renterId,
    required this.productId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.finalPrice,
    required this.verificationCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservation_id'],
      ownerId: json['owner_id'],
      renterId: json['renter_id'],
      productId: json['product_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      finalPrice: (json['final_price'] as num).toDouble(),
      verificationCode: DateTime.parse(json['verification_code']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
