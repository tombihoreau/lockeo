import 'package:lockeo_app/models/category.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _api;
  CategoryService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  Future<List<Category>> fetchCategories() async {
    final list = await _api.getJsonList('/categories');
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }
}
