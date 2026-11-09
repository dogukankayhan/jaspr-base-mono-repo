import 'package:app_shared/data/repository/favorites_repository_impl.dart';
import 'package:app_shared/data/repository/pokemon_repository_impl.dart';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';

import '../../data/datasource/browser_favorites_datasource.dart';

/// Identical to mobile's pokemon module — the repositories come from
/// app_shared; only the favorites storage adapter differs.
void setupPokemonModule(GetIt getIt) {
  getIt.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(getIt<ApiManager>()),
  );

  // Holds a broadcast stream of favorite ids → single shared instance.
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      localDataSource: BrowserFavoritesDataSource(),
      pokemonRepository: getIt<PokemonRepository>(),
    ),
  );
}
