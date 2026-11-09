import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Opens the device's native maps app to search a query or show coordinates.
abstract final class MapsLauncher {
  static const _appleMapsUrl = 'https://maps.apple.com/?q=';
  static const _googleMapsUrl =
      'https://www.google.com/maps/search/?api=1&query=';

  /// Opens Apple Maps on iOS, Google Maps everywhere else, searching [query]
  /// (an address or place name).
  static Future<bool> openWithQuery(String query) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? openAppleMaps(query)
        : openGoogleMaps(query);
  }

  /// Opens Apple Maps searching [query].
  static Future<bool> openAppleMaps(String query) =>
      _launch('$_appleMapsUrl${Uri.encodeComponent(query)}');

  /// Opens Google Maps searching [query].
  static Future<bool> openGoogleMaps(String query) =>
      _launch('$_googleMapsUrl${Uri.encodeComponent(query)}');

  /// Opens Google Maps centered on [latitude]/[longitude].
  static Future<bool> openCoordinates(double latitude, double longitude) =>
      _launch('$_googleMapsUrl$latitude,$longitude');

  static Future<bool> _launch(String url) async {
    try {
      return await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
