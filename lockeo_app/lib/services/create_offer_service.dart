import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
    final uploadedPhotoUris = await _uploadPhotos(draft.photos, token);

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
        'photoUris': uploadedPhotoUris,
        'unavailableDates': (draft.unavailableDates ?? [])
            .map(
              (d) => {
                'isoDate': DateTime.utc(
                  d.year,
                  d.month,
                  d.day,
                ).toIso8601String(),
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

  Future<List<String>> _uploadPhotos(List<XFile> photos, String token) async {
    final normalizedPhotos = photos
        .where((photo) => photo.path.trim().isNotEmpty)
        .take(5)
        .toList();

    if (normalizedPhotos.isEmpty) {
      return const [];
    }

    final request = http.MultipartRequest(
      'POST',
      _api.buildUri('/products/uploads'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    for (final photo in normalizedPhotos) {
      final bytes = await photo.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('files', bytes, filename: photo.name),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'POST /products/uploads status=${response.statusCode} body=$body',
      );
    }

    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Réponse inattendue lors de l’upload des images',
      );
    }

    final urls = (decoded['urls'] as List? ?? const [])
        .map((value) => value?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();

    if (urls.isEmpty) {
      throw const FormatException('Aucune URL image renvoyée par le backend');
    }

    return urls;
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
