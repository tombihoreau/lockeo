class Inventory {
  final int inventoryId;
  final int reservationId;
  final List<String> photos; // ✅ nouveau
  final String comment;
  final String status;
  final String createdAt;

  Inventory({
    required this.inventoryId,
    required this.reservationId,
    required this.photos,
    required this.comment,
    required this.status,
    required this.createdAt,
  });

  Inventory copyWith({
    int? inventoryId,
    int? reservationId,
    List<String>? photos,
    String? comment,
    String? status,
    String? createdAt,
  }) {
    return Inventory(
      inventoryId: inventoryId ?? this.inventoryId,
      reservationId: reservationId ?? this.reservationId,
      photos: photos ?? this.photos,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Inventory.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];

    return Inventory(
      inventoryId: json['inventory_id'],
      reservationId: json['reservation_id'],
      photos: (rawPhotos is List)
          ? rawPhotos.map((e) => e.toString()).toList()
          : <String>[], // ✅ si absent
      comment: (json['comment'] ?? "").toString(),
      status: (json['status'] ?? "").toString(),
      createdAt: (json['created_at'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventory_id': inventoryId,
      'reservation_id': reservationId,
      'photos': photos,
      'comment': comment,
      'status': status,
      'created_at': createdAt,
    };
  }
}
