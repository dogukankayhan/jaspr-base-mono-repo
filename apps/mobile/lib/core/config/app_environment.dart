import 'package:flutter/services.dart';

enum AppEnvironment { dev, staging, prod }

class AppConfig {
  final AppEnvironment environment;
  final String baseUrl;
  final String appName;
  final String googleServerClientId;

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  static const _channel = MethodChannel('com.yourcompany.baseapp/environment');

  AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.appName,
    required this.googleServerClientId,
  });

  /// From the native layer (Android: strings.xml/resValue, iOS: Info.plist/xcconfig)
  /// Reads baseUrl, appName, and googleServerClientId.
  static Future<void> init(AppEnvironment env) async {
    final nativeConfig = await _channel.invokeMapMethod<String, String>(
      'getEnvironmentConfig',
    );

    _instance = AppConfig._(
      environment: env,
      baseUrl: nativeConfig?['baseUrl'] ?? '',
      appName: nativeConfig?['appName'] ?? '',
      googleServerClientId: nativeConfig?['googleServerClientId'] ?? '',
    );
  }

  bool get isDev => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProd => environment == AppEnvironment.prod;
}
