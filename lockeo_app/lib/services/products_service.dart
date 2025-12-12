import 'package:lockeo_app/models/product_suggestion.dart';
import 'api_client.dart';
import 'auth_session.dart';

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

  Future<List<ProductSuggestion>> getRecentFavorites({int limit = 4}) async {
    _api.setBearerToken(AuthSession.instance.accessToken);
    final list = await _api.getJsonList('/favorites/recent', query: {'limit': limit});
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductSuggestion.fromJson(e))
        .toList();
  }
}
