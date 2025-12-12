class Offer {
  final int offerId;
  final int productId;
  final int userId; 
  final String status;
  final double amount;
  final String createdAt;

  Offer({
    required this.offerId,
    required this.productId,
    required this.userId,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) {
        final d = double.tryParse(v.trim());
        return d ?? 0.0;
      }
      return 0.0;
    }
    return Offer(
      offerId: json['offer_id'],
      productId: json['product_id'],
      userId: json['user_id'],
      status: json['status'],
      amount: _toDouble(json['amount']),
      createdAt: json['created_at'],
    );
  }
}
