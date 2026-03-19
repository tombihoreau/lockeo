class User {
  final int userId;
  final String lastName;
  final String firstName;
  final String email;
  final String login;
  final String phoneNumber;
  final double longitude;
  final double latitude;
  final String postalCode;
  final String city;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;

  User({
    required this.userId,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.login,
    required this.phoneNumber,
    required this.longitude,
    required this.latitude,
    required this.postalCode,
    required this.city,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v, [double fallback = 0.0]) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      if (v is String) {
        final d = double.tryParse(v.trim());
        return d ?? fallback;
      }
      return fallback;
    }

    bool toBool(dynamic value, [bool fallback = false]) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
      return fallback;
    }

    return User(
      userId: json['user_id'],
      lastName: (json['last_name'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      login: (json['login'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      longitude: toDouble(json['longitude'], 0.0),
      latitude: toDouble(json['latitude'], 0.0),
      postalCode: (json['postal_code'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      isVerified: toBool(json['is_verified']),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "last_name": lastName,
      "first_name": firstName,
      "email": email,
      "login": login,
      "phone_number": phoneNumber,
      "longitude": longitude,
      "latitude": latitude,
      "postal_code": postalCode,
      "city": city,
      "is_verified": isVerified,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
