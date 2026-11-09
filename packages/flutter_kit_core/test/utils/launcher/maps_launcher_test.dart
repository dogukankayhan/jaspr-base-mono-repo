import 'package:flutter/foundation.dart';
import 'package:flutter_kit_core/utils/launcher/maps_launcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'fake_url_launcher.dart';

void main() {
  late FakeUrlLauncher fake;

  setUp(() {
    fake = FakeUrlLauncher();
    UrlLauncherPlatform.instance = fake;
  });

  test('openAppleMaps launches the Apple Maps query URL', () async {
    await MapsLauncher.openAppleMaps('Istanbul Tower');
    expect(fake.lastUrl, 'https://maps.apple.com/?q=Istanbul%20Tower');
  });

  test('openGoogleMaps launches the Google Maps query URL', () async {
    await MapsLauncher.openGoogleMaps('Istanbul Tower');
    expect(
      fake.lastUrl,
      'https://www.google.com/maps/search/?api=1&query=Istanbul%20Tower',
    );
  });

  test('openCoordinates launches Google Maps with lat/lng', () async {
    await MapsLauncher.openCoordinates(41.0082, 28.9784);
    expect(
      fake.lastUrl,
      'https://www.google.com/maps/search/?api=1&query=41.0082,28.9784',
    );
  });

  test('openWithQuery picks Apple Maps on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await MapsLauncher.openWithQuery('Istanbul Tower');

    expect(fake.lastUrl, contains('maps.apple.com'));
  });

  test('openWithQuery picks Google Maps on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await MapsLauncher.openWithQuery('Istanbul Tower');

    expect(fake.lastUrl, contains('google.com'));
  });

  test('returns false instead of throwing when launch fails', () async {
    fake.canLaunchResult = false;
    final result = await MapsLauncher.openGoogleMaps('nowhere');
    expect(result, isA<bool>());
  });
}
