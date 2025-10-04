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
    return User(
      userId: json['user_id'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      email: json['email'],
      login: json['login'],
      phoneNumber: json['phone_number'],
      longitude: json['longitude']?.toDouble() ?? 0.0,
      latitude: json['latitude']?.toDouble() ?? 0.0,
      postalCode: json['postal_code'],
      city: json['city'],
      isVerified: json['is_verified'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
