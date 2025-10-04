import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/images.dart';

class LocalDataService {
  Future<List<Product>> loadProducts() async {
    return loadJson<Product>("products", (json) => Product.fromJson(json));
  }
  Future<List<ImageModel>> loadImages() async {
    return loadJson<ImageModel>("images", (json) => ImageModel.fromJson(json));
  }

  Future<List<T>> loadJson<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final String response = await rootBundle.loadString('lib/data/$path.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => fromJson(json)).toList();
  }
}
