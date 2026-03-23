import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _kGranted = 'loc_granted';
  static const _kLabel = 'loc_label';
  static const _kLat = 'loc_lat';
  static const _kLng = 'loc_lng';

  Future<bool> hasPermissionStored() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kGranted) ?? false;
  }

  Future<String?> getStoredLabel() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kLabel);
  }

  Future<bool> requestAndCacheLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      await _setGranted(false);
      return false;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 8),
    );

    final label = await _toLabel(pos.latitude, pos.longitude);

    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kGranted, true);
    await sp.setDouble(_kLat, pos.latitude);
    await sp.setDouble(_kLng, pos.longitude);
    if (label != null && label.isNotEmpty) {
      await sp.setString(_kLabel, label);
    }

    return true;
  }

  Future<void> denyAndCache() async {
    await _setGranted(false);
  }

  Future<void> _setGranted(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kGranted, v);
  }

  Future<String?> _toLabel(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;

      final city = (p.locality?.isNotEmpty ?? false)
          ? p.locality!
          : (p.administrativeArea ?? "");
      final country = p.country ?? "";

      final parts = [
        if (city.isNotEmpty) city,
        if (country.isNotEmpty) country,
      ];

      return parts.join(", ");
    } catch (_) {
      return null;
    }
  }

  Future<String?> getCachedOrCurrentLocationLabel() async {
    final cached = await getStoredLabel();
    if (cached != null && cached.trim().isNotEmpty) return cached;

    final ok = await requestAndCacheLocation();
    if (!ok) return null;

    return await getStoredLabel();
  }

  Future<({double lat, double lng})?> getStoredLatLng() async {
    final sp = await SharedPreferences.getInstance();
    final lat = sp.getDouble('loc_lat');
    final lng = sp.getDouble('loc_lng');
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  Future<void> clearStoredLatLng() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kLat);
    await sp.remove(_kLng);
  }
}
