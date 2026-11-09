import 'package:app_shared/data/repository/pokemon_repository_impl.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:kit_network/core/config/api_config.dart';
import 'package:kit_network/core/config/environment_config.dart';
import 'package:kit_network/core/di/locator.dart';
import 'package:kit_network/core/network/api/api_manager.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/client/dio_client.dart';
import 'package:kit_network/core/network/queue/request_queue.dart';
import 'package:kit_network/core/network/serializer/json_serializer.dart';

/// DI for the **server** process.
///
/// ⚠️ One server process answers *every* visitor, so only public, user-neutral
/// things may be singletons here: the HTTP client and the Pokémon repository
/// (its cache is public data). No AuthManager, TokenStore or favorites —
/// those are per-user and live only in the browser (client_injection.dart).
abstract final class ServerInjection {
  static void init({required String baseUrl}) {
    final config = ApiConfig.fromEnvironmentConfig(
      EnvironmentConfig.production(baseUrl: baseUrl),
    );
    // Same kit_network stack as mobile/web; Dio uses its dart:io adapter here.
    getIt.registerLazySingleton<ApiManager>(
      () => DioApiManager(
        client: DioClient(config),
        serializer: const JsonSerializer(),
        requestQueue: RequestQueue(maxConcurrent: 6),
      ),
    );
    getIt.registerLazySingleton<PokemonRepository>(
      () => PokemonRepositoryImpl(getIt<ApiManager>()),
    );
  }
}
