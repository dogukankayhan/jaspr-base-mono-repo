import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_kit_auth/flutter_kit_auth.dart';
import 'package:flutter_kit_network/core/config/environment_config.dart';
import 'package:flutter_kit_network/core/di/service_locator.dart' as network_di;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:requests_inspector/requests_inspector.dart';

import '../../config/app_environment.dart';

Future<void> setupNetworkModule(
  GetIt getIt, {
  required EnvironmentConfig config,
}) async {
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<TokenStore>(
    () => SecureTokenStore(storage: getIt<FlutterSecureStorage>()),
  );

  // Disable token refresh interceptor in dev mode.
  // When 401 occurs, transition to error state immediately instead of requesting /auth/refresh.
  final isDev = AppConfig.instance.isDev;

  await network_di.setupNetworking(
    config: config,
    tokenProvider: () => getIt<TokenStore>().readAccess(),
    refreshTokenProvider: isDev
        ? null
        : () => getIt<TokenStore>().readRefresh(),
    refreshTokenFunction: isDev
        ? null
        : (_) async {
            final result = await getIt<AuthManager>().refreshIfNeeded();
            return result.when(ok: (t) => t?.accessToken, err: (_) => null);
          },
    onTokenRefreshed: isDev
        ? null
        : (accessToken, refreshToken) {
            final tokens = AuthTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            unawaited(getIt<TokenStore>().write(tokens));
            if (getIt.isRegistered<AuthManager>()) {
              unawaited(getIt<AuthManager>().saveTokens(tokens));
            }
          },
    extraInterceptors: kDebugMode ? [RequestsInspectorInterceptor()] : null,
  );
}
