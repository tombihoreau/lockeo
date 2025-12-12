import 'package:lockeo_app/models/product_suggestion.dart';
import 'api_client.dart';

class ProductsService {
  final ApiClient _api;
  ProductsService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<ProductSuggestion>> getSuggestions({int limit = 4}) async {
    final list = await _api.getJsonList('/products/suggestions', query: {'limit': limit});
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductSuggestion.fromJson(e))
        .toList();
  }
}
