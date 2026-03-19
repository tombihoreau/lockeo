import 'package:lockeo_app/models/product_detail.dart';
import 'package:lockeo_app/models/product_suggestion.dart';
import 'api_client.dart';
import 'auth_session.dart';

class ProductsService {
  final ApiClient _api;
  ProductsService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<ProductSuggestion>> getSuggestions({int limit = 4}) async {
    final list = await _api.getJsonList(
      '/products/suggestions',
      query: {'limit': limit},
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductSuggestion.fromJson(e))
        .toList();
  }

  Future<List<ProductSuggestion>> searchProducts({
    required String query,
    List<int>? categoryIds,
    double? minPrice,
    double? maxPrice,
    int limit = 24,
  }) async {
    final params = <String, dynamic>{
      'q': query,
      'limit': limit,
      if (categoryIds != null && categoryIds.isNotEmpty)
        'categoryIds': categoryIds.join(','),
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
    };

    final list = await _api.getJsonList('/products/search', query: params);
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductSuggestion.fromJson(e))
        .toList();
  }

  Future<List<ProductSuggestion>> getRecentFavorites({int limit = 4}) async {
    _api.setBearerToken(AuthSession.instance.accessToken);
    final list = await _api.getJsonList(
      '/favorites/recent',
      query: {'limit': limit},
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductSuggestion.fromJson(e))
        .toList();
  }

  Future<ProductDetail> getOfferDetail(int offerId) async {
    final json = await _api.getJson('/products/offers/$offerId');
    return ProductDetail.fromJson(json);
  }
}
