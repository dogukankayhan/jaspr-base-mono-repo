import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:jaspr_kit_auth/jaspr_kit_auth.dart';
import 'package:jaspr_kit_network/jaspr_kit_network.dart';
import 'package:kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:kit_auth/auth/manager/auth_manager.dart';
import 'package:kit_network/core/config/api_config.dart';
import 'package:kit_network/core/config/environment_config.dart';
import 'package:kit_network/core/network/analytics/analytics_manager.dart';
import 'package:kit_network/core/network/api/api_manager.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/client/dio_client.dart';
import 'package:kit_network/core/network/queue/request_queue.dart';
import 'package:kit_network/core/network/serializer/json_serializer.dart';

/// Web counterpart of mobile's network module + flutter_kit_network's
/// `setupNetworking`: same kit_network pieces, browser adapters instead of
/// flutter_secure_storage / connectivity_plus / sqflite.
void setupNetworkModule(GetIt getIt, {required EnvironmentConfig config}) {
  getIt.registerLazySingleton<TokenStore>(BrowserTokenStore.new);
  getIt.registerLazySingleton<NetworkInfo>(() => const BrowserNetworkInfo());
  getIt.registerSingleton<EnvironmentConfig>(config);

  final analytics = DefaultAnalyticsManager(
    providers: [if (config.isDevelopment) ConsoleAnalyticsProvider()],
  );
  getIt.registerSingleton<AnalyticsManager>(analytics);

  final apiConfig = ApiConfig.fromEnvironmentConfig(config);
  // Refresh flow only outside dev — same rule as apps/mobile.
  final withRefresh = !config.isDevelopment;

  getIt.registerLazySingleton<ApiManager>(
    () => DioApiManager(
      client: DioClient(
        apiConfig,
        authTokenProvider: () => getIt<TokenStore>().readAccess(),
        refreshTokenProvider: withRefresh
            ? () => getIt<TokenStore>().readRefresh()
            : null,
        refreshTokenFunction: withRefresh
            ? (_) async {
                final result = await getIt<AuthManager>().refreshIfNeeded();
                return result.when(ok: (t) => t?.accessToken, err: (_) => null);
              }
            : null,
        onTokenRefreshed: withRefresh
            ? (accessToken, refreshToken) {
                final tokens = AuthTokens(
                  accessToken: accessToken,
                  refreshToken: refreshToken,
                );
                unawaited(getIt<TokenStore>().write(tokens));
                if (getIt.isRegistered<AuthManager>()) {
                  unawaited(getIt<AuthManager>().saveTokens(tokens));
                }
              }
            : null,
        networkInfo: getIt<NetworkInfo>(),
      ),
      serializer: const JsonSerializer(),
      requestQueue: RequestQueue(maxConcurrent: 3),
      analyticsManager: analytics,
    ),
  );

  // Interceptor-free instance for the refresh call — see the long comment in
  // flutter_kit_network's service_locator for why it must stay separate.
  getIt.registerLazySingleton<ApiManager>(
    () => DioApiManager(
      client: DioClient(apiConfig, networkInfo: getIt<NetworkInfo>()),
      serializer: const JsonSerializer(),
      requestQueue: RequestQueue(maxConcurrent: 1),
      analyticsManager: analytics,
    ),
    instanceName: 'refreshApiManager',
  );
}
