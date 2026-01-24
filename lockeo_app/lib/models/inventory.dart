class Inventory {
  final int inventoryId;
  final int reservationId;
  final String comment;
  final String status;
  final String createdAt;

  Inventory({
    required this.inventoryId,
    required this.reservationId,
    required this.comment,
    required this.status,
    required this.createdAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      inventoryId: json['inventory_id'],
      reservationId: json['reservation_id'],
      comment: json['comment'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
