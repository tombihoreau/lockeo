import 'package:lockeo_app/models/product_detail.dart';
import 'package:lockeo_app/models/product_suggestion.dart';
import 'api_client.dart';
import 'auth_session.dart';

class CreatedReservationResult {
  final int reservationId;
  final int conversationId;
  final String? paymentProvider;
  final String? paymentStatus;
  final String? paymentReference;
  final String? paymentCardLabel;
  final String? paymentCardPreview;

  const CreatedReservationResult({
    required this.reservationId,
    required this.conversationId,
    this.paymentProvider,
    this.paymentStatus,
    this.paymentReference,
    this.paymentCardLabel,
    this.paymentCardPreview,
  });
}

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

  Future<List<ProductSuggestion>> getHomeSuggestions({
    int limit = 4,
    double? latitude,
    double? longitude,
  }) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      return getSuggestions(limit: limit);
    }

    _api.setBearerToken(token);
    final list = await _api.getJsonList(
      '/products/home/suggestions',
      query: {
        'limit': limit,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      },
    );
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductSuggestion.fromJson(e))
        .toList();
  }

  Future<List<ProductSuggestion>> getPopularNearby({
    int limit = 4,
    double? latitude,
    double? longitude,
  }) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      return getSuggestions(limit: limit);
    }

    _api.setBearerToken(token);
    final list = await _api.getJsonList(
      '/products/home/popular-nearby',
      query: {
        'limit': limit,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      },
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

  Future<CreatedReservationResult> createReservation({
    required int offerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    _api.setBearerToken(token);
    final json = await _api.postJson(
      '/products/offers/$offerId/reservations',
      body: {
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      },
    );

    final reservationId = _toInt(json['reservation_id']);
    final conversationId = _toInt(json['conversation_id']);

    if (reservationId == null || conversationId == null) {
      throw const FormatException(
        'Réponse backend invalide (reservation_id/conversation_id manquants)',
      );
    }

    return CreatedReservationResult(
      reservationId: reservationId,
      conversationId: conversationId,
    );
  }

  Future<CreatedReservationResult> checkoutReservation({
    required int offerId,
    required DateTime startDate,
    required DateTime endDate,
    required String paymentScenario,
  }) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    _api.setBearerToken(token);
    final json = await _api.postJson(
      '/products/offers/$offerId/reservations/checkout',
      body: {
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
        'paymentScenario': paymentScenario,
      },
    );

    final reservationId = _toInt(json['reservation_id']);
    final conversationId = _toInt(json['conversation_id']);

    if (reservationId == null || conversationId == null) {
      throw const FormatException(
        'Réponse backend invalide (reservation_id/conversation_id manquants)',
      );
    }

    return CreatedReservationResult(
      reservationId: reservationId,
      conversationId: conversationId,
      paymentProvider: json['payment_provider']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentReference: json['payment_reference']?.toString(),
      paymentCardLabel: json['payment_card_label']?.toString(),
      paymentCardPreview: json['payment_card_preview']?.toString(),
    );
  }

  Future<void> updateReservationStatus({
    required int reservationId,
    required String status,
  }) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    _api.setBearerToken(token);
    await _api.patchJson(
      '/products/reservations/$reservationId/status',
      body: {'status': status},
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
