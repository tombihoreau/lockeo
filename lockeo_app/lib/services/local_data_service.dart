import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/review.dart';

class LocalDataService {
  Future<List<Product>> loadProducts() async {
    return loadJson<Product>("products", (json) => Product.fromJson(json));
  }

  Future<List<ImageModel>> loadImages() async {
    return loadJson<ImageModel>("images", (json) => ImageModel.fromJson(json));
  }

  Future<List<Offer>> loadOffers() async {
    return loadJson<Offer>("offers", (json) => Offer.fromJson(json));
  }

  Future<List<User>> loadUsers() async {
    return loadJson<User>("users", (json) => User.fromJson(json));
  }

  Future<List<Category>> loadCategories() async {
    return loadJson<Category>("categories", (json) => Category.fromJson(json));
  }

  Future<List<Review>> loadReviews() async {
    return loadJson<Review>("reviews", (json) => Review.fromJson(json));
  }

  Future<List<T>> loadJson<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final String response = await rootBundle.loadString('lib/data/$path.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => fromJson(json)).toList();
  }

  Future<User?> getUserById(int userId) async {
    final users = await loadUsers();
    try {
      return users.firstWhere((u) => u.userId == userId);
    } catch (_) {
      return null;
    }
  }
}
