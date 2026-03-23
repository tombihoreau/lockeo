import '../models/offerDraft.dart';
import 'api_client.dart';
import 'auth_session.dart';
import 'location_service.dart';

class CreatedOfferResult {
  final int productId;
  final int offerId;

  const CreatedOfferResult({required this.productId, required this.offerId});
}

class CreateOfferService {
  CreateOfferService({ApiClient? apiClient, LocationService? locationService})
    : _api = apiClient ?? ApiClient(),
      _locationService = locationService ?? LocationService();

  final ApiClient _api;
  final LocationService _locationService;

  Future<CreatedOfferResult> createOffer(OfferDraft draft) async {
    final token = AuthSession.instance.accessToken;
    if (token == null || token.trim().isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    if ((draft.title ?? '').trim().isEmpty) {
      throw const FormatException('Titre manquant');
    }
    if ((draft.state ?? '').trim().isEmpty) {
      throw const FormatException('Etat manquant');
    }
    if ((draft.pricePerDay ?? 0) <= 0) {
      throw const FormatException('Prix par jour invalide');
    }

    final location = (draft.location ?? '').trim();
    final parsed = _parseLocation(location);
    final latLng = await _locationService.getStoredLatLng();

    _api.setBearerToken(token);
    final json = await _api.postJson(
      '/products/create-offer',
      body: {
        'title': (draft.title ?? '').trim(),
        'description': (draft.description ?? '').trim(),
        'state': (draft.state ?? '').trim(),
        'pricePerDay': draft.pricePerDay,
        'price3Days': draft.price3Days,
        'price7Days': draft.pricePerWeek,
        'city': parsed.city,
        'postalCode': parsed.postalCode,
        'latitude': latLng?.lat,
        'longitude': latLng?.lng,
        'categoryIds': draft.categories,
        'photoUris': draft.photos,
        'unavailableDates': (draft.unavailableDates ?? [])
            .map(
              (d) => {
                'isoDate': DateTime.utc(d.year, d.month, d.day)
                    .toIso8601String(),
              },
            )
            .toList(),
      },
    );

    final productId = _toInt(json['product_id']);
    final offerId = _toInt(json['offer_id']);

    if (productId == null || offerId == null) {
      throw const FormatException('Réponse backend invalide (ids manquants)');
    }

    return CreatedOfferResult(productId: productId, offerId: offerId);
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  ({String? city, String? postalCode}) _parseLocation(String location) {
    if (location.isEmpty) {
      return (city: null, postalCode: null);
    }

    final parts = location
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final city = parts.isNotEmpty ? parts.first : null;
    String? postal;

    final postalMatch = RegExp(r'\b\d{5}\b').firstMatch(location);
    if (postalMatch != null) {
      postal = postalMatch.group(0);
    }

    return (city: city, postalCode: postal);
  }
}
