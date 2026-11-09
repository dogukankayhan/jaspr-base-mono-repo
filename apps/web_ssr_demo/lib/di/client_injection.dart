import 'package:app_shared/data/repository/favorites_repository_impl.dart';
import 'package:app_shared/data/repository/pokemon_repository_impl.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:jaspr_kit_network/jaspr_kit_network.dart';
import 'package:kit_network/core/config/api_config.dart';
import 'package:kit_network/core/config/environment_config.dart';
import 'package:kit_network/core/di/locator.dart';
import 'package:kit_network/core/network/api/api_manager.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/client/dio_client.dart';
import 'package:kit_network/core/network/queue/request_queue.dart';
import 'package:kit_network/core/network/serializer/json_serializer.dart';

import '../components/browser_favorites_datasource.dart';

/// DI for the **browser** — what the @client islands need after hydration
/// (loading more pages, searching, favorites). Same shape as apps/web.
abstract final class ClientInjection {
  static void init({required String baseUrl}) {
    final config = ApiConfig.fromEnvironmentConfig(
      EnvironmentConfig.production(baseUrl: baseUrl),
    );
    getIt.registerLazySingleton<NetworkInfo>(() => const BrowserNetworkInfo());
    getIt.registerLazySingleton<ApiManager>(
      () => DioApiManager(
        client: DioClient(config, networkInfo: getIt<NetworkInfo>()),
        serializer: const JsonSerializer(),
        requestQueue: RequestQueue(maxConcurrent: 3),
      ),
    );
    getIt.registerLazySingleton<PokemonRepository>(
      () => PokemonRepositoryImpl(getIt<ApiManager>()),
    );
    getIt.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        localDataSource: BrowserFavoritesDataSource(),
        pokemonRepository: getIt<PokemonRepository>(),
      ),
    );
  }
}
