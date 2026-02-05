import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class ApproxLocationService {
  final _cityCache = <String, ({double lat, double lng})?>{};

  Future<double?> distanceFromUser(String city) async {
    final user = await LocationService().getStoredLatLng();
    if (user == null) return null;

    final cityPos = await _getCityLatLng(city);
    if (cityPos == null) return null;

    final meters = Geolocator.distanceBetween(
      user.lat,
      user.lng,
      cityPos.lat,
      cityPos.lng,
    );

    return meters / 1000.0;
  }

  Future<({double lat, double lng})?> _getCityLatLng(String city) async {
    if (_cityCache.containsKey(city)) {
      return _cityCache[city];
    }

    try {
      final locations = await locationFromAddress(city);
      if (locations.isEmpty) return null;

      final loc = locations.first;
      final value = (lat: loc.latitude, lng: loc.longitude);
      _cityCache[city] = value;
      return value;
    } catch (_) {
      _cityCache[city] = null;
      return null;
    }
  }
}
