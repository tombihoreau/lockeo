import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'auth_session.dart';
import 'local_data_service.dart';

class FavoritesService {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  final ApiClient _api = ApiClient();
  final LocalDataService _localDataService = LocalDataService();

  final ValueNotifier<Set<int>> favoriteProductIds = ValueNotifier<Set<int>>(
    <int>{},
  );

  Future<Set<int>>? _loadingFuture;
  bool _hasLoaded = false;

  bool get _hasToken {
    final token = AuthSession.instance.accessToken;
    return token != null && token.trim().isNotEmpty;
  }

  Future<Set<int>> ensureLoaded({bool force = false}) {
    if (!force) {
      if (_hasLoaded) {
        return Future.value(Set<int>.from(favoriteProductIds.value));
      }
      if (_loadingFuture != null) {
        return _loadingFuture!;
      }
    }

    final future = _loadFavoriteProductIds();
    _loadingFuture = future;
    return future;
  }

  Future<bool> toggleFavorite(int productId, {bool? currentValue}) async {
    final isFavorite =
        currentValue ?? favoriteProductIds.value.contains(productId);

    if (_hasToken) {
      _api.setBearerToken(AuthSession.instance.accessToken);
      if (isFavorite) {
        await _api.deleteJson('/favorites/$productId');
      } else {
        await _api.postJson('/favorites/$productId');
      }
    } else {
      await _localDataService.toggleFavoriteProduct(productId);
    }

    final nextIds = Set<int>.from(favoriteProductIds.value);
    if (isFavorite) {
      nextIds.remove(productId);
    } else {
      nextIds.add(productId);
    }

    favoriteProductIds.value = nextIds;
    _hasLoaded = true;
    return !isFavorite;
  }

  Future<Set<int>> _loadFavoriteProductIds() async {
    try {
      final ids = _hasToken
          ? await _loadRemoteFavoriteProductIds()
          : await _loadLocalFavoriteProductIds();
      favoriteProductIds.value = ids;
      _hasLoaded = true;
      return Set<int>.from(ids);
    } finally {
      _loadingFuture = null;
    }
  }

  Future<Set<int>> _loadRemoteFavoriteProductIds() async {
    _api.setBearerToken(AuthSession.instance.accessToken);
    final list = await _api.getJsonList('/favorites/product-ids');
    return list
        .map((value) {
          if (value is int) return value;
          if (value is num) return value.toInt();
          if (value is String) return int.tryParse(value.trim());
          return null;
        })
        .whereType<int>()
        .toSet();
  }

  Future<Set<int>> _loadLocalFavoriteProductIds() async {
    final products = await _localDataService.loadProducts();
    return products
        .where((product) => product.isFavorite)
        .map((product) => product.productId)
        .toSet();
  }
}
