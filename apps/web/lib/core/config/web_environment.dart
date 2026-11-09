import 'package:kit_network/core/config/environment_config.dart';

/// Web flavors — the counterpart of mobile's `AppConfig` / flavor setup.
///
/// Mobile reads its base URL from the native build (gradle / xcconfig); the
/// web build takes it from `--dart-define`s instead:
///
/// ```bash
/// jaspr serve --dart-define=FLAVOR=staging --dart-define=BASE_URL=https://…
/// ```
enum WebFlavor { dev, staging, prod }

abstract final class WebEnvironment {
  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://pokeapi.co/api/v2/',
  );

  static WebFlavor get flavor => switch (_flavor) {
    'prod' => WebFlavor.prod,
    'staging' => WebFlavor.staging,
    _ => WebFlavor.dev,
  };

  static bool get isDev => flavor == WebFlavor.dev;

  static EnvironmentConfig get config => switch (flavor) {
    WebFlavor.dev => EnvironmentConfig.development(baseUrl: _baseUrl),
    WebFlavor.staging => EnvironmentConfig.staging(baseUrl: _baseUrl),
    WebFlavor.prod => EnvironmentConfig.production(baseUrl: _baseUrl),
  };
}
