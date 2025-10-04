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
    return Offer(
      offerId: json['offer_id'],
      productId: json['product_id'],
      userId: json['user_id'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}
